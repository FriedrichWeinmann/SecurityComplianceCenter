# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	
	'Set-SccLabelLocalization.Label.NoIdentity.Error' = 'No label identity was specified. Please specify at least one of "-Name", "-FriendlyName" or "-Identity"' # 
	'Set-SccLabelLocalization.Label.NotFound.Error'   = 'No label was found that matched: {0} | {1} | {2}' # 
	'Set-SccLabelLocalization.Processing'			  = 'Processing localization update for {0}' # $targetLabel.FriendlyName
	'Set-SccLabelLocalization.Skipping.AlreadySet'    = 'Skipping update to {0}, as "-Default" was specified and {1} > {2} is already set' # $targetLabel.FriendlyName, $Type, $Language
	'Set-SccLabelLocalization.Updating'			      = 'Updating {1} in language {2} on {0}' # $targetLabel.FriendlyName, $Type, $Language
	'Set-SccLabelLocalization.Updating.Bulk'		  = 'Executing bulk update of all localization changes to {0}' # $labelObject.FriendlyName
	'Set-SccLabelLocalization.Updating.Bulk.Failed'   = 'Failed to update localization settings on {0}' # $labelObject.FriendlyName
}