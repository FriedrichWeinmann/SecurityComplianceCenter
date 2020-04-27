Register-PSFTeppScriptblock -Name 'SecurityComplianceCenter.LabelName' -ScriptBlock {
	(Get-Label).Name
}
Register-PSFTeppArgumentCompleter -Command Get-Label -Parameter Identity -Name 'SecurityComplianceCenter.LabelName'
Register-PSFTeppArgumentCompleter -Command Set-Label -Parameter Identity -Name 'SecurityComplianceCenter.LabelName'
Register-PSFTeppArgumentCompleter -Command Remove-Label -Parameter Identity -Name 'SecurityComplianceCenter.LabelName'
Register-PSFTeppArgumentCompleter -Command Get-SccLabelLocalization -Parameter Name -Name 'SecurityComplianceCenter.LabelName'
Register-PSFTeppArgumentCompleter -Command Set-SccLabelLocalization -Parameter Name -Name 'SecurityComplianceCenter.LabelName'

