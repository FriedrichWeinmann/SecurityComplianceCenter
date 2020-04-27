# Security Compliance Center

## Synopsis

This module is designed to help you connect to and work with the O365 Security & Compliance Center service.

## Getting Started

Installing the module:

```powershell
# For all users on the computer (Requires elevation)
Install-Module SecurityComplianceCenter

# Just for you
Install-Module SecurityComplianceCenter -Scope CurrentUser
```

To connect to the SCC service, all you need to do is:

```powershell
Connect-SCC
```

This uses modern authentication and supports MFA.
However it does _not_ support Service Principal Authentication (using a certificate), which is a limit within the service itself.

> Note: In the background, the ExchangeOnlineManagement module is used for the connection Details.
> This makes it impossible to connect to both services at the same time at this time.

## Examples

This module provides tools to automate localization of Unified Labels, including the import of localization exports from the AIP portal.

> List all current localization entries

```powershell
Get-SCCLabelLocalization
```

> Update a single localization entry

```powershell
Set-SccLabelLocalization -Name Confidential -Language 'de-DE' -Type DisplayName -Text 'Vertraulich'
```

> Import all localization XML as exported from AIP

```powershell
Import-SccLabelLocalizationXml -Path .\*.xml | Set-SccLabelLocalization
```
