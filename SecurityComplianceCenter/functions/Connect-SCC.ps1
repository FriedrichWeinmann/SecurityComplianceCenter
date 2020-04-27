function Connect-SCC
{
	<#
		.ForwardHelpTargetName Connect-ExchangeOnline
		.ForwardHelpCategory Function
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