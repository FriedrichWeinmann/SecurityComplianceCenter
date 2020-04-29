function Set-SccLabelLocalization
{
<#
	.SYNOPSIS
		Updates localization of Labels.
	
	.DESCRIPTION
		Updates localization of Labels.
	
	.PARAMETER Name
		The (system) name of the label.
	
	.PARAMETER FriendlyName
		The friendly name of the label.
		This is the DisplayName in case of a top level Label.
		In case of a child label, it is <ParentDisplayName>\<DisplayName>
	
	.PARAMETER Identity
		The Identity - or FQLN - of a Label is similar to the FriendlyName, only using the Name properties instead.
		Thus it is the Name in case of a top level Label.
		In case of a child label, it is <ParentName>\<Name>
	
	.PARAMETER Language
		The language for which to update text.
	
	.PARAMETER Type
		The type of text to write:
		DisplayName or Tooltip.
	
	.PARAMETER Text
		The text to write.
	
	.PARAMETER Default
		By default, existing localization entries will be overwritten.
		With this parameter, already existing localization entries will be honored and only new strings added.
	
	.PARAMETER DelayWrite
		Defers updating labels until the end, collecting all changes and applies them in bulk.
		By default, each label text is written as it comes in.
		Caching all writes and executing them in bulk is a performance update, but risks changes to be lost in case of terminating errors.
	
	.PARAMETER NameMapping
		A hashtable mapping input Names to new names.
		Useful when importing into a tenant other than the source tenant where not all names match perfectly.
	
	.PARAMETER FriendlyNameMapping
		A hashtable mapping input FriendlyNames to new FriendlyNames.
		Useful when importing into a tenant other than the source tenant where not all names match perfectly.
	
	.PARAMETER IdentityMapping
		A hashtable mapping input Identities to new Identities.
		Useful when importing into a tenant other than the source tenant where not all names match perfectly.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Set-SccLabelLocalization -Name Confidential -Language 'de-DE' -Type DisplayName -Text 'Vertraulich'
	
		Adds a German localization to the "Confidential" label
	
	.EXAMPLE
		PS C:\> Import-Csv .\localizations.csv | Set-SccLabelLocalization
	
		Imports all localization data from the localizations.csv document.
		The document must contain some columns:
		- Language
		- Type
		- Text
		- At least one of: Name, FriendlyName, Identity, FQLN
	
	.EXAMPLE
		PS C:\> Import-SccLabelLocalizationXml -Path .\*.xml | Set-SccLabelLocalization
	
		Imports all localization XML in the current folder and applies the localization data to the online labels in SCC.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FriendlyName,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[Alias('FQLN')]
		[string]
		$Identity,
		
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Language,
		
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateSet('DisplayName', 'Tooltip')]
		[string]
		$Type,
		
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Text,
		
		[switch]
		$Default,
		
		[switch]
		$DelayWrite,
		
		[Hashtable]
		$NameMapping,
		
		[hashtable]
		$FriendlyNameMapping,
		
		[hashtable]
		$IdentityMapping,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Assert-SccConnection -Cmdlet $PSCmdlet
		
		#region Utility Functions
		function Write-Label
		{
			[CmdletBinding()]
			param (
				$LabelObject
			)
			
			$dnHash = @{
				localeKey = "displayName"
				Settings  = @()
			}
			foreach ($key in $LabelObject.LS.DisplayName.Keys)
			{
				$dnHash.Settings += [pscustomobject]@{
					Key   = $key
					Value = $LabelObject.LS.DisplayName[$key]
				}
			}
			
			$ttHash = @{
				localeKey = "tooltip"
				Settings  = @()
			}
			foreach ($key in $LabelObject.LS.Tooltip.Keys)
			{
				$ttHash.Settings += [pscustomobject]@{
					Key   = $key
					Value = $LabelObject.LS.Tooltip[$key]
				}
			}
			
			try
			{
				if ($dnHash.Settings.Count -gt 0) { Set-Label -Identity $LabelObject.Guid -LocaleSettings ($dnHash | ConvertTo-Json) -ErrorAction Stop -WarningAction SilentlyContinue }
				if ($ttHash.Settings.Count -gt 0) { Set-Label -Identity $LabelObject.Guid -LocaleSettings ($ttHash | ConvertTo-Json) -ErrorAction Stop -WarningAction SilentlyContinue }
			}
			catch { throw }
		}
		#endregion Utility Functions
		
		$allLabels = Get-EnrichedLabel
		$modifiedLabels = @{ }
	}
	process
	{
		:main foreach ($dummyVar in 1)
		{
			$targetItem = [PSCustomObject]($PSBoundParameters | ConvertTo-PSFHashtable)
			
			#region Find Target Label
			if (Test-PSFParameterBinding -ParameterName Name, FriendlyName, Identity -Not)
			{
				Stop-PSFFunction -String 'Set-SccLabelLocalization.Label.NoIdentity.Error' -EnableException $EnableException -Category InvalidArgument -Continue -Cmdlet $PSCmdlet -Target $targetItem
			}
			
			$targetLabel = $null
			if ($Name)
			{
				$resolvedName = $Name
				if ($NameMapping -and $NameMapping[$Name]) { $resolvedName = $NameMapping[$Name] }
				$targetLabel = $allLabels | Where-Object Name -EQ $resolvedName
			}
			if ($FriendlyName -and -not $targetLabel)
			{
				$resolvedFriendlyName = $FriendlyName
				if ($FriendlyNameMapping -and $FriendlyNameMapping[$FriendlyName]) { $resolvedFriendlyName = $FriendlyNameMapping[$FriendlyName] }
				$targetLabel = $allLabels | Where-Object FriendlyName -EQ $resolvedFriendlyName
			}
			if ($Identity -and -not $targetLabel)
			{
				$resolvedIdentity = $Identity
				if ($IdentityMapping -and $IdentityMapping[$Identity]) { $resolvedIdentity = $IdentityMapping[$Identity] }
				$targetLabel = $allLabels | Where-Object FQLN -EQ $resolvedIdentity
			}
			
			if (-not $targetLabel)
			{
				Stop-PSFFunction -String 'Set-SccLabelLocalization.Label.NotFound.Error' -StringValues $Name, $FriendlyName, $Identity -EnableException $EnableException -Category ObjectNotFound -Continue -Cmdlet $PSCmdlet -Target $targetItem
			}
			#endregion Find Target Label
			
			#region Validate Text
			switch ($Type)
			{
				'DisplayName' {
					if ($Text.Length -gt 64)
					{
						Stop-PSFFunction -String 'Set-SccLabelLocalization.Text.DisplayName.TooLong' -StringValues $targetLabel.FriendlyName, $Language, $Text -EnableException $EnableException -Category InvalidArgument -Continue -ContinueLabel main -Cmdlet $PSCmdlet -Target $targetItem
					}
				}
				'Tooltip' {
					if ($Text.Length -gt 1000)
					{
						Stop-PSFFunction -String 'Set-SccLabelLocalization.Text.Tooltip.TooLong' -StringValues $targetLabel.FriendlyName, $Language, $Text -EnableException $EnableException -Category InvalidArgument -Continue -ContinueLabel main -Cmdlet $PSCmdlet -Target $targetItem
					}
				}
			}
			
			Write-PSFMessage -String 'Set-SccLabelLocalization.Processing' -StringValues $targetLabel.FriendlyName -Target $targetItem
			#endregion Validate Text
			
			#region Process Updates
			if ($Default -and $targetLabel.LS."$Type".$Language)
			{
				Write-PSFMessage -String 'Set-SccLabelLocalization.Skipping.AlreadySet' -StringValues $targetLabel.FriendlyName, $Type, $Language -Target $targetItem
				continue
			}
			
			Invoke-PSFProtectedCommand -ActionString 'Set-SccLabelLocalization.Updating' -ActionStringValues $targetLabel.FriendlyName, $Type, $Language -ScriptBlock {
				$backupHash = $targetLabel.LS["$Type"].Clone()
				$targetLabel.LS["$Type"][$Language] = $Text
				if ($DelayWrite) { $modifiedLabels[$targetLabel.Name] = $targetLabel }
				else
				{
					try { Write-Label -LabelObject $targetLabel -ErrorAction Stop }
					catch
					{
						# Rollback the change that failed
						$targetLabel.LS["$Type"] = $backupHash
						throw
					}
				}
			} -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -Target $targetItem
			#endregion Process Updates
		}
	}
	end
	{
		#region Execute delayed write
		if ($DelayWrite)
		{
			foreach ($labelObject in $modifiedLabels.Values)
			{
				try
				{
					Write-PSFMessage -String 'Set-SccLabelLocalization.Updating.Bulk' -StringValues $labelObject.FriendlyName -Target $labelObject
					Write-Label -LabelObject $labelObject -ErrorAction Stop
				}
				catch { Stop-PSFFunction -String 'Set-SccLabelLocalization.Updating.Bulk.Failed' -StringValues $labelObject.FriendlyName -Target $labelObject -ErrorRecord $_ -EnableException $EnableException -Continue }
			}
		}
		#endregion Execute delayed write
	}
}