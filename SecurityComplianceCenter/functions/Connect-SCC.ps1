function Connect-SCC
{
<#
	.SYNOPSIS
		Establishes a Modern Auth connection with the Security & Compliance Center.
	
	.DESCRIPTION
		Establishes a Modern Auth connection with the Security & Compliance Center.
	
		Behind the scenes, it uses the ExchangeOnlineManagement module's Connect-ExchangeOnline command.
	
	.PARAMETER AzureADAuthorizationEndpointUri
		The AzureADAuthorizationEndpointUri parameter specifies the Azure AD Authorization endpoint Uri that can issue OAuth2 access tokens.
	
	.PARAMETER ExchangeEnvironmentName
		The ExchangeEnvironmentName specifies the Exchange Online environment. Valid values are:

		- O365China
		- O365Default (this is the default value)
		- O365GermanyCloud
		- O365USGovDoD
		- O365USGovGCCHigh
	
	.PARAMETER PSSessionOption
		The PSSessionOption parameter specifies the PowerShell session options to use in your connection to SCC.
		Use the "New-PSSessionOption" cmdlet to generate them.
		Useful for example to configure a proxy.
	
	.PARAMETER BypassMailboxAnchoring
		The BypassMailboxAnchoring switch bypasses the use of the mailbox anchoring hint.
	
	.PARAMETER DelegatedOrganization
		The DelegatedOrganization parameter specifies the customer organization that you want to manage (for example, contosoelectronics.onmicrosoft.com).
		This parameter only works if the customer organization has agreed to your delegated management via the CSP program.

		After you successfully authenticate, the cmdlets in this session are mapped to the customer organization, and all operations in this session are done on the customer organization.
	
	.PARAMETER Prefix
		Add a module prefix to the imported commands.
	
	.PARAMETER UserPrincipalName
		The UserPrincipalName parameter specifies the account that you want to use to connect (for example, fred@contoso.onmicrosoft.com).
		Using this parameter allows you to skip the first screen in authentication prompt.
	
	.PARAMETER Credential
		The credentials to use when connecting to SCC.
		Needed for unattended automation.
		If this parameter is omitted, you will be prompted interactively.
	
	.EXAMPLE
		PS C:\> Connect-SCC
	
		Connects to the Securit & Compliance Center
#>
	[Alias('cscc')]
	[CmdletBinding()]
	param (
		[string]
		$AzureADAuthorizationEndpointUri,
		
		[Microsoft.Exchange.Management.RestApiClient.ExchangeEnvironment]
		$ExchangeEnvironmentName,
		
		[System.Management.Automation.Remoting.PSSessionOption]
		$PSSessionOption,
		
		[switch]
		$BypassMailboxAnchoring,
		
		[string]
		$DelegatedOrganization,
		
		[string]
		$Prefix,
		
		[string]
		$UserPrincipalName,
		
		[PSCredential]
		$Credential
	)
	
	begin
	{
		if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$null))
		{
			$PSBoundParameters['OutBuffer'] = 1
		}
		$parameters = @{
			ShowBanner = $false
			ConnectionUri = Get-PSFConfigValue -FullName 'SecurityComplianceCenter.Connection.Uri'
		}
		$parameters += $PSBoundParameters | ConvertTo-PSFHashtable
		
		try
		{
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Connect-ExchangeOnline', [System.Management.Automation.CommandTypes]::Function)
			$scriptCmd = { & $wrappedCmd @parameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline()
			$steppablePipeline.Begin($PSCmdlet)
		}
		catch
		{
			throw
		}
	}
	
	process
	{
		try
		{
			$steppablePipeline.Process($_)
		}
		catch
		{
			throw
		}
	}
	
	end
	{
		try
		{
			$steppablePipeline.End()
		}
		catch
		{
			throw
		}
	}
}