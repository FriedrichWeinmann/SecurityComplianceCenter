function Enable-SccAuthentication
{
	<#
	.SYNOPSIS
		Enables using modern authentication to connect to Security & Compliance Center.
	
	.DESCRIPTION
		Enables using modern authentication to connect to Security & Compliance Center.
		In some environments, policies exist that prevent the use of basic authentication for PowerShell CLIENTS.

		Connect-SCC does NOT use basic authentication, but WinRM cannot tell the difference between basic authentication and modern authentication.
		This command overrides the policy, but requires elevation ("Run as Administrator") to perform the override.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Enable-SccAuthentication

		Enables using modern authentication to connect to Security & Compliance Center.
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[switch]
		$EnableException
	)

	process {
		$settings = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\' -ErrorAction Ignore
		if (-not $settings) { return }
		if ($settings.PSObject.Properties.Name -notcontains 'AllowBasic') { return }
		if ($settings.AllowBasic -ne 0) { return }

		if (-not (Test-PSFPowerShell -Elevated))
		{
			Stop-PSFFunction -String 'Enable-SccAuthentication.NotElevated' -EnableException $EnableException -Category SecurityError
			return
		}

		Invoke-PSFProtectedCommand -ActionString 'Enable-SccAuthentication.Enabling' -Target $env:COMPUTERNAME -ScriptBlock {
			Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\' -Name AllowBasic -Value 1 -ErrorAction Stop
		} -EnableException $EnableException -PSCmdlet $PSCmdlet
	}
}