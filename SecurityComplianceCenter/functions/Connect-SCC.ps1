function Connect-SCC {
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

	.PARAMETER AppId
		The AppId parameter specifies the application ID of the service principal that's used in certificate based
		authentication (CBA). A valid value is the GUID of the application ID (service principal). For example,
		`36ee4c6c-0812-40a2-b820-b22ebd02bce3`.

		For more information, see App-only authentication for unattended scripts in the Exchange Online PowerShell
		module (https://aka.ms/exo-cba).
	
	.PARAMETER CommandName
		The CommandName parameter specifies the comma separated list of commands to import into the session. Use this
		parameter for applications or scripts that use a specific set of cmdlets. Reducing the number of cmdlets in
		the session helps improve performance and reduces the memory footprint of the application or script.

	.PARAMETER FormatTypeName
		The FormatTypeName parameter specifies the output format of the cmdlet.

	.PARAMETER Certificate
		Certificate to use together with an AppId for certificate-based authentication.
		Can be either X509Certificate2 object or the thumbprint of one available in the certificate store.
		Will fail if a private key is unavailable!
	
	.EXAMPLE
		PS C:\> Connect-SCC
	
		Connects to the Securit & Compliance Center
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
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
		$Credential,

		[string]
		$AppId,

		[string[]]
		$CommandName,

		[string[]]
		$FormatTypeName,

		[Fred.PowerShell.Certificate.Parameter.CertificateParameter]
		$Certificate
	)
	
	begin {
		$settings = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\' -ErrorAction Ignore
		if ($settings -and 0 -eq $settings.AllowBasic) {
			Write-PSFMessage -Level Warning -String 'Connect-SCC.Basic.Disabled'
		}

		if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$null)) {
			$PSBoundParameters['OutBuffer'] = 1
		}
		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -ReferenceCommand Connect-IPPSSession
		$parameters.ConnectionUri = switch ("$ExchangeEnvironmentName") {
			O365China { 'https://ps.compliance.protection.partner.outlook.cn/powershell-liveid' }
			O365USGovDoD { 'https://l5.ps.compliance.protection.office365.us/powershell-liveid/' }
			O365USGovGCCHigh { 'https://ps.compliance.protection.office365.us/powershell-liveid/' }
			default { Get-PSFConfigValue -FullName 'SecurityComplianceCenter.Connection.Uri' }
		}
		if (-not $AzureADAuthorizationEndpointUri) {
			$parameters.AzureADAuthorizationEndpointUri = switch ("$ExchangeEnvironmentName") {
				O365China { 'https://login.chinacloudapi.cn/common' }
				O365USGovDoD { 'https://login.microsoftonline.us/common' }
				O365USGovGCCHigh { 'https://login.microsoftonline.us/common' }
				default { 'https://login.microsoftonline.com/common' }
			}
		}

		try {
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Connect-IPPSSession', [System.Management.Automation.CommandTypes]::Function)
			$scriptCmd = { & $wrappedCmd @parameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline()
			$steppablePipeline.Begin($PSCmdlet) 2>$null
		}
		catch {
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
	
	process {
		$module = Get-Module ExchangeOnlineManagement
		try {
			# Disable the verbose banner on screen
			& $module { function script:Write-Host {} }
			$steppablePipeline.Process($_)
		}
		catch {
			try { $steppablePipeline.End() }
			catch { }
			$PSCmdlet.ThrowTerminatingError($_)
		}
		finally {
			# Ugly, but removes the temporary Write-Host override to prevent affecting outside of our own command
			$utilityHost = [PSFramework.Utility.UtilityHost]
			if ($PSVersionTable.PSVersion.Major -gt 5) {
				$state = $utilityHost::GetPrivateField("<SessionState>k__BackingField",$module)
				$stateInternal = $utilityHost::GetPrivateProperty("Internal",$state)
				$moduleScope = $utilityHost::GetPrivateField('<ModuleScope>k__BackingField', $stateInternal)
			}
			else {
				$state = $utilityHost::GetPrivateField("_sessionState",$module)
				$stateInternal = $utilityHost::GetPrivateProperty("Internal",$state)
				$moduleScope = $utilityHost::GetPrivateField('_moduleScope', $stateInternal)
			}
			$functions = $utilityHost::GetPrivateField('_functions', $moduleScope)
			$null = $functions.Remove("Write-Host")
		}
	}
	
	end {
		try {
			$steppablePipeline.End()
		}
		catch {
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
}