# Changelog

## 1.1.8 (2020-05-13)

- New: Command Enable-SccAuthentication - configures WinRM to allow modern authentication when policies forbid the use of basic authentication.
- Upd: Import-SccLabelLocalizationXml - added validation for invalid characters among the imported XML.
- Upd: Set-SccLabelLocalization - added input validation for invalid characters
- Upd: Connect-SCC - added detection for disabled basic auth in WinRM client

## 1.1.4 (2020-05-04)

- Fix: Import-SccLabelLocalizationXml - invalid parameter on Stop-PSFFunction causes unexpected errors without proper handling

## 1.1.3 (2020-05-01)

- Fix: Get-SccLabelLocalization - Fails with Watson report

## 1.1.2 (2020-04-29)

- Fix: Set-SccLabelLocalization - A bad entry would prevent subsequent updates to a label in non-cached mode

## 1.1.1 (2020-04-28)

- Fix: Set-SccLabelLocalization - A bad entry would prevent subsequent updates to a label in non-cached mode
- Fix: Set-SccLabelLocalization - Tries to write too long localization strings

## 1.1.0 (2020-04-27)

- New: Import-SccLabelLocalizationXml - imports the localization XML exported from the AIP portal

## 1.0.0 (2020-04-27)

- Initial Release