﻿@{
	# Script module or binary module file associated with this manifest
	RootModule	      = 'SecurityComplianceCenter.psm1'
	
	# Version number of this module.
	ModuleVersion	  = '1.1.0'
	
	# ID used to uniquely identify this module
	GUID			  = '86d8860e-52a8-48f7-a5eb-f1ba7cded2bc'
	
	# Author of this module
	Author		      = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName	      = ' '
	
	# Copyright statement for this module
	Copyright		  = 'Copyright (c) 2020 Friedrich Weinmann'
	
	# Description of the functionality provided by this module
	Description	      = 'Interact with the SCC through PowerShell'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.1.59' }
		@{ ModuleName = 'ExchangeOnlineManagement'; ModuleVersion = '0.4368.1' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\SecurityComplianceCenter.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\SecurityComplianceCenter.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\SecurityComplianceCenter.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-SCC'
		'Get-SccLabelLocalization'
		'Import-SccLabelLocalizationXml'
		'Set-SccLabelLocalization'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport   = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport   = 'cscc'
	
	# List of all modules packaged with this module
	ModuleList	      = @()
	
	# List of all files packaged with this module
	FileList		  = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData	      = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}