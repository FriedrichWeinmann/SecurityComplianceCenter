# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Import-SccLabelLocalizationXml.Content.BadDocument' = 'Not an export file from AIP: {0}' # $fileItem
	'Import-SccLabelLocalizationXml.Content.Error'       = 'Not a legal XML document: {0}' # $fileItem
	'Import-SccLabelLocalizationXml.DisplayName.TooLong' = 'Too long displayname detected for {0} in language {1} | {2} | The maximum length is 64 characters, this displayname cannot be imported! Specified string: {3}' # ($entry.ID -split "/")[-2], $language, $entry.defaultText, $entry.LocalizedText
	'Import-SccLabelLocalizationXml.InvalidPath.Error'   = 'Not a legal filesystem path: {0}' # $pathItem
	'Import-SccLabelLocalizationXml.Processing'          = 'Processing localization data from {0}' # $fileItem
	'Import-SccLabelLocalizationXml.Tooltip.TooLong'     = 'Too long tooltip detected for {0} in language {1} | {2} | The maximum length is 1000 characters, this tooltip cannot be imported! Specified string: {3}' # ($entry.ID -split "/")[-2], $language, $entry.defaultText, $entry.LocalizedText
	'Set-SccLabelLocalization.Label.NoIdentity.Error'    = 'No label identity was specified. Please specify at least one of "-Name", "-FriendlyName" or "-Identity"' # 
	'Set-SccLabelLocalization.Label.NotFound.Error'      = 'No label was found that matched: {0} | {1} | {2}' # $Name, $FriendlyName, $Identity
	'Set-SccLabelLocalization.Processing'                = 'Processing localization update for {0}' # $targetLabel.FriendlyName
	'Set-SccLabelLocalization.Skipping.AlreadySet'       = 'Skipping update to {0}, as "-Default" was specified and {1} > {2} is already set' # $targetLabel.FriendlyName, $Type, $Language
	'Set-SccLabelLocalization.Text.DisplayName.TooLong'  = 'The specified displayname for {0} ({1}) is too long. Maximum length is 64 characters. Text specified: {2}' # $targetLabel.FriendlyName, $Language, $Text
	'Set-SccLabelLocalization.Text.Tooltip.TooLong'      = 'The specified tooltip for {0} ({1}) is too long. Maximum length is 1000 characters. Text specified: {2}' # $targetLabel.FriendlyName, $Language, $Text
	'Set-SccLabelLocalization.Updating'                  = 'Updating {1} in language {2} on {0}' # $targetLabel.FriendlyName, $Type, $Language
	'Set-SccLabelLocalization.Updating.Bulk'             = 'Executing bulk update of all localization changes to {0}' # $labelObject.FriendlyName
	'Set-SccLabelLocalization.Updating.Bulk.Failed'      = 'Failed to update localization settings on {0}' # $labelObject.FriendlyName
}