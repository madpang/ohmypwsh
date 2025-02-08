<#
	@file: ohmypwsh/conf/device-00-pwsh-conf.ps1

	@brief: Device-specific PowerShell configuration

	@author:
	- madpang

	@date:
	- created on 2021-08-09
	- updated on 2025-01-19
#>

# === Function definition

# @brief: Mount remote shared storage as a workspace
# @details: It is basically a wrapper around the platform-specific function `Mount-RemoteVolume`
Function Mount-Workspace {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)][string]$WkspID
	)
	$WKSP_INFO_FILE = "~/.ohmypwsh.d/workspace-info.asc" # GPG encrypted file of workspace information
	try {
		if (-not (Test-Path $WKSP_INFO_FILE -PathType Leaf)) {
			throw "Workspace information file '$WKSP_INFO_FILE' does not exist."
		}
		# Decrypt the GPG encrypted file
		$decrypted = gpg --decrypt $WKSP_INFO_FILE 2>$null
		if (-not $?) {
			throw "Failed to decrypt the workspace information file '$WKSP_INFO_FILE'."
		}
		# Extract the JSON content marked by '+++ JSON' and '+++'
		$json = @()
		$flag = $false
		$decrypted | ForEach-Object {
			if ('+++' -eq $_) {
				$flag = $false
			} # Prevent the boundary line from being included in the output
			if ($flag) {
				$json += $_
			}
			if ('+++ JSON' -eq $_) {
				$flag = $true
			} # Enable the NEXT line to be included in the output
		}
		$wksp_info = ConvertFrom-Json ($json -join [System.Environment]::NewLine) -AsHashtable -ErrorAction Stop
		# Mount the workspace using the retrieved information
		if ($null -eq $wksp_info[$WkspID]) {
			throw "Workspace $WkspID is not recognized, please confirm the information file at $WKSP_INFO_FILE."
		}
		# @note: the user should ensure the integrity of the workspace information
		Mount-RemoteVolume -WkspID $WkspID `
			-MountPoint $wksp_info[$WkspID].MountPoint `
			-HostID $wksp_info[$WkspID].HostID `
			-VolumeID $wksp_info[$WkspID].VolumeID `
			-VolumeType $wksp_info[$WkspID].VolumeType `
			-UserID $wksp_info[$WkspID].UserID `
			-UserPSW $wksp_info[$WkspID].UserPSW
	} catch {
		Write-Error $_.Exception.Message
	}
}

# @brief: Remove mounted workspace served by the remote shared storage
# @note:
# - This function utilizes the macOS built-in (BSD) `umount`, make sure the path is properly set
# @see:
# - `man umount`
Function Remove-Workspace {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$WkspID,      # workspace identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$MountPoint   # mount point
	)
	if ("W4:" -eq $WkspID) { # Currently only support W4:
		if (-not (Test-Path $MountPoint -PathType Container)) { # Abort if the mount point does not exist
			Write-Error "The specified mount point '$MountPoint' does not exist or is not mounted."
			return
		}
		try {
			# Call system command `umount`
			umount $MountPoint 2>$null
			if (-not $?) {
				# Fallback mechanism for force un-mounting
				diskutil unmount force $MountPoint
				if (-not $?) {
					throw "Failed to unmount '$WkspID' from '$MountPoint'."
				}
			}
			# Clean up
			Remove-Item -Path $MountPoint -ErrorAction Stop
			Write-Output "Successfully unmounted '$WkspID' from '$MountPoint' and cleaned up the directory."
		} catch {
			Write-Error $_.Exception.Message
		}
	} else {
		Write-Error "Workspace '$WkspID' is not supported in this version."
	}
}

Function Get-Secret {
	$content = Get-Content -Path '~/.ohmypwsh.d/workspace-info'
	$json = @()
	$flag = $false
	$content | ForEach-Object {
		if ('+++' -eq $_) {
			$flag = $false
		} # Prevent the boundary line from being included in the output
		if ($flag) {
			$json += $_
		}
		if ('+++ JSON' -eq $_) {
			$flag = $true
		} # Enable the NEXT line to be included in the output
	}
	return $json
}
