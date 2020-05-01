function Get-SccLabelLocalization
{
<#
	.SYNOPSIS
		Reads localization data from existing labels.
	
	.DESCRIPTION
		Reads localization data from existing labels.
	
	.PARAMETER Name
		Filter by name or by ID.
	
	.PARAMETER DisplayName
		Filter by the displayname of the label
	
	.PARAMETER Language
		Constrain results by the language you are interested about.
	
	.EXAMPLE
		PS C:\> Get-SCCLabelLocalization
	
		Return all localization data for all labels
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name = '*',
		
		[string]
		$DisplayName = '*',
		
		[string[]]
		$Language
	)
	
	begin
	{
		Assert-SccConnection -Cmdlet $PSCmdlet
		
		$allLabels = Get-EnrichedLabel
	}
	process
	{
		foreach ($label in $allLabels)
		{
			$found = $false
			foreach ($labelName in $Name) {
				if ($label.Name -like $labelName) { $found = $true }
			}
			if (-not $found) { continue }

			if ($label.DisplayName -notlike $DisplayName) { continue }

			foreach ($languageKey in $label.LS.DisplayName.Keys) {
				if ($Language -and $languageKey -notin $Language) { continue }

				[pscustomobject]@{
					PSTypeName   = 'SecurityComplianceCenter.Label.Locale'
					FriendlyName = $label.friendlyName
					LabelID	     = $label.Guid
					FQLN     	 = $label.FQLN
					LabelName    = $label.Name
					Type		 = 'DisplayName'
					Language	 = $languageKey
					Text		 = $label.LS.DisplayName[$languageKey]
					Label	     = $label
				}
			}
			
			foreach ($languageKey in $label.LS.Tooltip.Keys) {
				if ($Language -and $languageKey -notin $Language) { continue }

				[pscustomobject]@{
					PSTypeName   = 'SecurityComplianceCenter.Label.Locale'
					FriendlyName = $label.friendlyName
					LabelID	     = $label.Guid
					FQLN     	 = $label.FQLN
					LabelName    = $label.Name
					Type		 = 'Tooltip'
					Language	 = $languageKey
					Text		 = $label.LS.Tooltip[$languageKey]
					Label	     = $label
				}
			}
		}
	}
}