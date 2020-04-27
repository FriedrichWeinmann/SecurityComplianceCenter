function Import-SccLabelLocalizationXml {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)

	begin {
		$defaultProcessed = @{ }
	}
	process {
		foreach ($pathItem in $Path) {
			try { $resolvedPaths = Resolve-PSFPath -Path $pathItem -Provider FileSystem }
			catch {
				#TODO: Add error handling
			}

			foreach ($fileItem in $resolvedPaths) {
				try { [xml]$xmlData = Get-Content -Path $fileItem -ErrorAction Stop -Encoding utf8 }
				catch {
					#TODO: Add error handling
				}
				$language = $xmlData.Language.Id
				if (-not $language) {
					#TODO: Add error handling
				}
				
				foreach ($entry in $xmlData.Language.LocItem)
				{
					if ($entry.ID -notmatch '^labelGroups/Sensitivity/labels/.+/(DisplayName|Description)$') { continue }
	
					$type = 'Tooltip'
					if ($entry.ID -Match 'DisplayName$') { $type = 'DisplayName' }
					[PSCustomObject]@{
						Name = ($entry.ID -split "/")[-2]
						Identity = $entry.ID.Replace("labelGroups/Sensitivity/labels/", "").Replace("subLabels/", "").Replace("/","\") -replace '\\(DisplayName|Description)$'
						Type = $type
						Language = $language
						Text = $entry.LocalizedText
					}
	
					if ($defaultProcessed[$entry.ID]) { continue }
	
					[PSCustomObject]@{
						Name = ($entry.ID -split "/")[-2]
						Identity = $entry.ID.Replace("labelGroups/Sensitivity/labels/", "").Replace("subLabels/", "").Replace("/","\") -replace '\\(DisplayName|Description)$'
						Type = $type
						Language = 'default'
						Text = $entry.defaultText
					}
	
					$defaultProcessed[$entry.ID] = $true
				}
			}
		}
	}
}