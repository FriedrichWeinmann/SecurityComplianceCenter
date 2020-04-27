function Import-SccLabelLocalizationXml
{
<#
	.SYNOPSIS
		Imports label data from an export-xml of classic AIP label localization.
	
	.DESCRIPTION
		Imports label data from an export-xml of classic AIP label localization.
	
		This only parses the XML files and generates PowerShell objects containing the relevant data.
		To apply the localization data thus generated, use Set-SccLabelLocalization.
	
	.PARAMETER Path
		Path(s) to the XML file(s) to import / parse.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Import-SccLabelLocalizationXml -Path .\de-DE.xml
	
		Imports the localization data stored in de-DE.xml
	
	.EXAMPLE
		PS C:\> Import-SccLabelLocalizationXml -Path .\*.xml | Set-SccLabelLocalization
	
		Imports all localization XML in the current folder and applies the localization data to the online labels in SCC.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		$defaultProcessed = @{ }
	}
	process
	{
		foreach ($pathItem in $Path)
		{
			try { $resolvedPaths = Resolve-PSFPath -Path $pathItem -Provider FileSystem }
			catch { Stop-PSFFunction -String 'Import-SccLabelLocalizationXml.InvalidPath.Error' -StringValues $pathItem -Target $pathItem -EnableException $EnableException -ContinueLabel -ErrorRecord $_ }
			
			foreach ($fileItem in $resolvedPaths)
			{
				try { [xml]$xmlData = Get-Content -Path $fileItem -ErrorAction Stop -Encoding utf8 }
				catch { Stop-PSFFunction -String 'Import-SccLabelLocalizationXml.Content.Error' -StringValues $fileItem -Target $fileItem -EnableException $EnableException -ContinueLabel -ErrorRecord $_ }
				$language = $xmlData.Language.Id
				if (-not $language) { Stop-PSFFunction -String 'Import-SccLabelLocalizationXml.Content.BadDocument' -StringValues $fileItem -Target $fileItem -EnableException $EnableException -ContinueLabel -Category InvalidData }
				
				Write-PSFMessage -String 'Import-SccLabelLocalizationXml.Processing' -StringValues $fileItem -Target $fileItem
				
				#region Process Entries
				foreach ($entry in $xmlData.Language.LocItem)
				{
					if ($entry.ID -notmatch '^labelGroups/Sensitivity/labels/.+/(DisplayName|Description)$') { continue }
					
					$type = 'Tooltip'
					if ($entry.ID -Match 'DisplayName$') { $type = 'DisplayName' }
					[PSCustomObject]@{
						Name = ($entry.ID -split "/")[-2]
						Identity = $entry.ID.Replace("labelGroups/Sensitivity/labels/", "").Replace("subLabels/", "").Replace("/", "\") -replace '\\(DisplayName|Description)$'
						Type = $type
						Language = $language
						Text = $entry.LocalizedText
					}
					
					if ($defaultProcessed[$entry.ID]) { continue }
					
					[PSCustomObject]@{
						Name = ($entry.ID -split "/")[-2]
						Identity = $entry.ID.Replace("labelGroups/Sensitivity/labels/", "").Replace("subLabels/", "").Replace("/", "\") -replace '\\(DisplayName|Description)$'
						Type = $type
						Language = 'default'
						Text = $entry.defaultText
					}
					
					$defaultProcessed[$entry.ID] = $true
				}
				#endregion Process Entries
			}
		}
	}
}