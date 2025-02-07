<#
	@brief: Common PowerShell configuration for all platforms

	@detaisl:
	- Locale settings
	- Environment setup
	- PSReadline configuration
	- prompt configuration

	@author:
	- madpang

	@date:
	- created on 2021-08-05
	- updated on 2024-03-14
#>

# /// Locale settings
[cultureinfo]::CurrentCulture = 'ja-JP'

# /// Environment setup
# ////////////////////////////////////////////////////////////

# Unload PSReadline (@note, ince PSReadline is automatically loaded, we unload it first to do some configuration)
Remove-Module PSReadline

# Set environment variables
Set-Item -Path "env:GPG_TTY" -Value "$(tty)" # @note, use `Get-Command -Name tty` to check whether the command is available

# /// PSReadline configuration
