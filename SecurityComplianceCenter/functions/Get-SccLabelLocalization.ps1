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
		
		$culture = Get-Culture
		[System.Collections.ArrayList]$labelsProcessed = @()
	}
	process
	{
		foreach ($labelName in $Name)
		{
			$labels = Get-CachedLabel -Id $labelName -Refresh
			
			foreach ($label in $labels)
			{
				if ($label.Name -in $labelsProcessed) { continue }
				$null = $labelsProcessed.Add($label.Name)
				
				if ($label.DisplayName -notlike $DisplayName) { continue }
				
				$friendlyName = $label.DisplayName
				$identity = $label.Name
				if ($label.ParentID)
				{
					$friendlyName = '{0}\{1}' -f (Get-CachedLabel -Id $label.ParentID).DisplayName, $label.DisplayName
					$identity = '{0}\{1}' -f (Get-CachedLabel -Id $label.ParentID).Name, $label.Name
				}
				
				$localeData = $label.LocaleSettings | ConvertFrom-Json
				foreach ($localeDatum in $localeData)
				{
					foreach ($entry in $localeDatum.Settings)
					{
						if ($Language -and $entry.Key -notin $Language) { continue }
						
						[pscustomobject]@{
							PSTypeName   = 'SecurityComplianceCenter.Label.Locale'
							FriendlyName = $friendlyName
							LabelID	     = $label.Guid
							FQLN     	 = $identity
							LabelName    = $label.Name
							Type		 = $culture.TextInfo.ToTitleCase($localeDatum.LocaleKey)
							Language	 = $entry.Key
							Text		 = $entry.Value
							Label	     = $label
						}
					}
				}
			}
		}
	}
}