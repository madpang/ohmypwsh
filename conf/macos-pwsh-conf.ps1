<#
	@brief: macOS-specific PowerShell configuration

	@detaisl:
	- Environment configuration
	- Alias configuration

	@author:
	- madpang

	@date:
	- created on 2021-08-09
	- updated on 2024-11-24
#>

# /// Environment setup
# ////////////////////////////////////////////////////////////

# Set environment variables

Set-Item -Path "env:GPG_TTY" -Value "$(tty)" # configure GPG_TTY such that gpg-agent can find the tty for passphrase input. @note, use `Get-Command -Name tty` to check whether the command is available

# Define functions

# @brief: Mount remote shared storage to local file system
# @note:
# - `UrlEncode` is used to encode the volume name to handle no-ASCII characters (e.g. Japanese)
# - This function utilizes the macOS built-in (BSD) `mount`, make sure the path is properly set
# @see: `man mount`
Function Mount-RemoteVolume {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$WkspID,        # workspace identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$MountPoint,    # mount point
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$HostID,        # host identifier, IP or hostname
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$VolumeID,      # shared volume identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$VolumeType,    # protocol of the shared volume
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$UserID,        # user identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$UserPSW        # passphrase
	)
	if ("W4" -eq $WkspID) { # Currently only support W4:
		if (-not (Test-Path $MountPoint -PathType Container)) { # Abort if the mount point already exists, since it may be local workspace
			$mount_target = "//${UserID}:${UserPSW}@${HostID}/$([System.Web.HttpUtility]::UrlEncode($VolumeID))"
			try {
				New-Item -ItemType Directory -Path $MountPoint -ErrorAction Stop 1>$null
				# Call system comamnd `mount`
				if ("smbfs" -ne $VolumeType) { # Currently only support SMB protocol for shared volume mounting
					throw "Volume type '$VolumeType' is not supported in this version."
				}
				mount -t smbfs $mount_target $MountPoint
				if ($?) {
					Write-Output "Successfully created mount point '$MountPoint' for '$WkspID'."
				} else {
					throw "Failed to mount '$WkspID' at '$MountPoint'."
				}
			} catch {
				Write-Error $_.Exception.Message
				# Clean up
				if (Test-Path $MountPoint -PathType Container) {
					Remove-Item -Path $MountPoint -Recurse -Force -ErrorAction SilentlyContinue
				}
			}
		} else {
			Write-Error "Mount point '$WkspID' already exists! Please take care!"
		}
	} else {
		Write-Error "Workspace '$WkspID' is not supported in this version."
	}
}

# @brief: Un-mount remote shared storage from local file system
# @note:
# - This function utilizes the macOS built-in (BSD) `umount`, make sure the path is properly set
# @see:
# - `man umount`
# - `man diskutil`
Function Remove-RemoteVolume {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$WkspID,      # workspace identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$MountPoint   # mount point
	)
	if ("W4" -eq $WkspID) { # Currently only support W4:
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
