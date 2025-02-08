<#
	@file: ohmypwsh/conf/macos-pwsh-conf.ps1

	@brief: macOS-specific PowerShell configuration

	@detaisl:
	- Environment configuration
	- Function definition
	- Alias configuration

	@author:
	- madpang

	@date:
	- created on 2021-08-09
	- updated on 2025-02-02
#>

# === Environment setup

Set-Item -Path "env:GPG_TTY" -Value "$(tty)" # configure GPG_TTY such that gpg-agent can find the tty for passphrase input. @note, use `Get-Command -Name tty` to check whether the command is available

# === Function definition

# @brief: Mount remote shared storage to local file system
# @note:
# - `UrlEncode` is used to encode the volume name to handle no-ASCII characters (e.g. Japanese)
# - This function utilizes the macOS built-in (BSD) `mount`, make sure the path is properly set
# @see: `man mount`
Function Mount-RemoteVolume {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$MountPoint,    # mount point
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$HostID,        # host identifier, IP or hostname
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$VolumeID,      # shared volume identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$VolumeType,    # protocol of the shared volume
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$UserID,        # user identifier
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$UserPSW        # passphrase
	)
	try {
		# Abort if the mount point already exists, since it may be local workspace
		if (Test-Path $MountPoint -PathType Container) {
			throw [System.AccessViolationException]::new("Mount point '$MountPoint' already exists! Please take care!")
		}
		# Currently only support SMB protocol for shared volume mounting
		if ($VolumeType -ne "smbfs") { 
			throw [System.ArgumentException]::New("Volume type '$VolumeType' is not supported in this version.")
		}
		# Call system comamnd `mount`
		$mount_target = "//${UserID}:${UserPSW}@${HostID}/$([System.Web.HttpUtility]::UrlEncode($VolumeID))"
		New-Item -ItemType Directory -Path $MountPoint -ErrorAction Stop 1>$null
		mount -t smbfs $mount_target $MountPoint 2>$null
		$exitCode = $LASTEXITCODE
		if ($exitCode -eq 0) {
			Write-Output "Successfully created mount point at '$MountPoint'."
		} else {
			throw [System.ApplicationException]::new("Failed to mount at '$MountPoint'.")
		}
	} catch [System.ApplicationException] {
		# Clean up
		if (Test-Path $MountPoint -PathType Container) {
			Remove-Item -Path $MountPoint -Recurse -Force -ErrorAction SilentlyContinue
		}
		$PSCmdlet.ThrowTerminatingError($PSItem)
	} catch {
		$PSCmdlet.ThrowTerminatingError($PSItem)
	}
}

# @brief: Un-mount remote shared storage from local file system
# @note:
# - This function utilizes the macOS built-in (BSD) `umount`, make sure the path is properly set
# @details:
# The manpage of `umount` suggests using `diskutil`, due to the complexity of the macOS file system.
# @see:
# - `man diskutil`
# - `man umount`
Function Remove-RemoteVolume {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $false)][string]$MountPoint   # mount point
	)
	if (-not (Test-Path $MountPoint -PathType Container)) { # Abort if the mount point does not exist
		Write-Error "The specified mount point '$MountPoint' does not exist or is not a valid directory."
		return
	}
	try {
		diskutil unmount $MountPoint 2>$null
		$exitCode = $LASTEXITCODE
		if ($exitCode -eq 0) {
			# Successfully unmounted; clean up the directory
			Remove-Item -Path $MountPoint -ErrorAction Stop
			Write-Output "Successfully unmounted '$MountPoint' and cleaned up the directory."
		} else {
			# Fallback check: Is the directory empty?
			if (-not (Test-Path ([IO.Path]::Combine($MountPoint, '*')))) {
				# If it is an empty folder, delete the directory
				Remove-Item -Path $MountPoint -ErrorAction Stop
				Write-Output "Unmount failed, but '$MountPoint' was empty and has been cleaned up."
			} else {
				throw "Failed to unmount '$MountPoint' (exit code: $exitCode), and it is NON-EMPTY."
			}
		}
	} catch {
		Write-Error $_.Exception.Message
	}
}
