<# 
	@file: ohmypwsh/pwshrc.ps1

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
	- updated on 2025-01-26
#>

# === Get the execution path

$_entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $_entry_point.Target)
{
	# If it is called via a symbolic link
	$_script_dir = Split-Path $_entry_point.Target -Parent
} else {
	# If it is called directly
	$_script_dir = $_entry_point.Directory.FullName
}

# === Load workspace settings
# @todo

# === Load external modules

# --- Common setup for all platforms
. ([System.IO.Path]::Combine(
	$_script_dir,
	'conf',
	'common-pwsh-conf.ps1'
))

# --- Platform specific setup
. ([IO.Path]::Combine(
	$_script_dir,
	'conf',
	($IsMacOS ? 'macos' : ($IsWindows ? 'windows' : 'linux')) + '-pwsh-conf.ps1'
))

# --- Device specific setup

$_device_info_file = "~/.ohmypwsh.d/device-info" # plain text file of device information

if (Test-Path -Path $_device_info_file -PathType Leaf) {
	# Extract the JSON content marked by '+++ JSON' and '+++'
	$_json = @()
	$_flag = $false
	Get-Content -Path $_device_info_file | ForEach-Object {
		if ('+++' -eq $_)
		{
			$_flag = $false
		}
		if ($_flag)
		{
			$_json += $_
		}
		if ('+++ JSON' -eq $_)
		{
			$_flag = $true
		}
	}
	$_device_info = ConvertFrom-Json ($_json -join [System.Environment]::NewLine) -AsHashtable -ErrorAction Stop
	if ($null -ne $_device_info[[Environment]::MachineName]) {
		$_device_specific_conf = [IO.Path]::Combine(
			$_script_dir,
			'conf',
			$_device_info[[Environment]::MachineName].ConfPath
		)
		# Load device specific configuration if it exists
		if (Test-Path -Path $_device_specific_conf -PathType Leaf)
		{
			. $_device_specific_conf
		}
	}
}

# === Clean up

# Remove temporary variables that starts with '_'
Remove-Variable -Name "_*"
