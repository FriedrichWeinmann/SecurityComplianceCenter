Register-PSFTeppScriptblock -Name 'SecurityComplianceCenter.Int.CultureKeys' -ScriptBlock {
	[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).Name
}
Register-PSFTeppArgumentCompleter -Command Set-SccLabelLocalization -Parameter Language -Name 'SecurityComplianceCenter.Int.CultureKeys'