function Assert-SccConnection
{
<#
	.SYNOPSIS
		Asserts, that a proper connection to SCC has been established.
	
	.DESCRIPTION
		Asserts, that a proper connection to SCC has been established.
		Will terminate the calling function in fire and blood.
	
		Use this during the begin block of all functions interacting with SCC.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling function.
	
	.EXAMPLE
		PS C:\> Assert-SccConnection -Cmdlet $PSCmdlet
	
		Terminates the calling function, if no connection to SCC has been established.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if (Test-Path function:\Get-Label) { return }
		
		$exception = [System.InvalidOperationException]::new('No connection to the Security and Compliance Center detected! Please run "Connect-SCC" to establish a connection!')
		$errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, "SccNotConnected", 'ConnectionError', $null)
		$Cmdlet.ThrowTerminatingError($errorRecord)
	}
}