<# 
	@brief:
	Entry point for a PowerShell profile script that is loaded at start time.

	@details:
	To use this script,
	- copy it to the default profile location for the OS,
	- or create a symlink to this file from the default profile location.

	@details:
	This script will load external modules.

	@author:
	- madpang

	@date:
	- created on 2021-06-08
	- updated on 2025-01-16
#>

# === Get the execution path

$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target)
{
	# If it is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
} else {
	# If it is called directly
	$script_dir = $entry_point.Directory.FullName
}

# === Load workspace settings
# @todo

# === Load external modules

# --- Common setup for all platforms
. ([System.IO.Path]::Combine(
	$script_dir,
	'conf',
	'common-pwsh-conf.ps1'
))

# --- Platform specific setup
. ([IO.Path]::Combine(
	$script_dir,
	'conf',
	($IsMacOS ? 'macos' : ($IsWindows ? 'windows' : 'linux')) + '-pwsh-conf.ps1'
))

# --- Device specific setup

$device_specific_conf = [IO.Path]::Combine(
	$script_dir,
	'conf',
	'device-00' + '-pwsh-conf.ps1' # @todo: ([Environment]::MachineName) + '-pwsh-conf.ps1'
)
# load device specific configuration if it exists
if (Test-Path -Path $device_specific_conf -PathType Leaf)
{
	. $device_specific_conf
}

# === Clean up

# Remove temporary variables
Remove-Item -Path "Variable:entry_point"
Remove-Item -Path "Variable:script_dir"
Remove-Item -Path "Variable:device_specific_conf"
