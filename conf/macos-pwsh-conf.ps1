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
