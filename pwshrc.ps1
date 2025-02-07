<# 
	@brief: 
	PowerShell profile script that is loaded at start time.

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
	- updated on 2024-03-13
#>

# Get the execution path
# ////////////////////////////////////////////////////////////
$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target) { # It is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
}
else {
	$script_dir = $entry_point.Directory.FullName
}

# Load workspace settings
# ////////////////////////////////////////////////////////////
# @todo

# Load external modules
# ////////////////////////////////////////////////////////////

# Common functions for all platforms
. ([System.IO.Path]::Combine(
	$script_dir,
	'conf',
	'common-pwsh-conf.ps1'
))

# Clean up
# ////////////////////////////////////////////////////////////

# Remove variables
Remove-Item -Path "variable:entry_point"
Remove-Item -Path "variable:script_dir"
