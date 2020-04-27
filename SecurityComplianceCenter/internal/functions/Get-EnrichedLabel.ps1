function Get-EnrichedLabel
{
<#
	.SYNOPSIS
		Returns all labels with extended Metadata.
	
	.DESCRIPTION
		Returns all labels with extended Metadata:
	
		- LS: Locale Settings reprocessed to be easily accessible.
		- FriendlyName: <Parent>\<Child> notation with DisplayName
		- FQLN: <Parent>\<Child> notation with Name
	
	.EXAMPLE
		PS C:\> Get-EnrichedLabel
	
		Returns all labels with extended Metadata.
#>
	[CmdletBinding()]
	Param (
	
	)
	
	begin
	{
		Assert-SccConnection -Cmdlet $PSCmdlet
	}
	process
	{
		$allLabels = Get-Label
		foreach ($label in $allLabels)
		{
			$displayNameHash = @{ }
			$tooltipHash = @{ }
			foreach ($setting in (@($label.LocaleSettings | ConvertFrom-Json) | Where-Object LocaleKey -EQ "displayName").Settings) { $displayNameHash[$setting.Key] = $setting.Value }
			foreach ($setting in (@($label.LocaleSettings | ConvertFrom-Json) | Where-Object LocaleKey -EQ "tooltip").Settings) { $tooltipHash[$setting.Key] = $setting.Value }
			
			$locale = @{
				DisplayName = $displayNameHash
				Tooltip	    = $tooltipHash
			}
			Add-Member -InputObject $label -MemberType NoteProperty -Name LS -Value $locale
			
			if (-not $label.ParentID)
			{
				Add-Member -InputObject $label -MemberType NoteProperty -Name FriendlyName -Value $label.DisplayName
				Add-Member -InputObject $label -MemberType NoteProperty -Name FQLN -Value $label.Name
				$label
				continue
			}
			
			$parentLabel = $allLabels | Where-Object Guid -EQ $label.ParentID
			Add-Member -InputObject $label -MemberType NoteProperty -Name FriendlyName -Value ('{0}\{1}' -f $parentLabel.DisplayName, $label.DisplayName)
			Add-Member -InputObject $label -MemberType NoteProperty -Name FQLN -Value ('{0}\{1}' -f $parentLabel.Name, $label.Name)
			$label
		}
	}
}