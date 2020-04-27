function Get-CachedLabel
{
<#
	.SYNOPSIS
		Retrieves label information by its ID property.
	
	.DESCRIPTION
		Retrieves label information by its ID property.
		Caches results in order to improve performance.
	
	.PARAMETER Id
		The ID of the Label to search.
		Only when using the true ID (Guid property on the label object) will it use caching.
	
	.PARAMETER Refresh
		Force refreshing the data, even if a acached copy is available.
	
	.EXAMPLE
		PS C:\> Get-CachedLabel -Id $label.ParentID
	
		Returns the parent object of the label stored in $label
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Id,
		
		[switch]
		$Refresh
	)
	
	process
	{
		if (-not $Refresh -and $script:labelCache[$Id]) { return $script:labelCache[$Id] }
		try { $labels = Get-Label -Identity $Id -ErrorAction Stop }
		catch { throw }
		
		foreach ($label in $labels)
		{
			$script:labelCache["$($label.Guid)"] = $label
		}
		
		return $labels
	}
}