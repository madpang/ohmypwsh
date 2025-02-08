<#
	@file: ohmypwsh/conf/linux-pwsh-conf.ps1

	@brief: Linux-specific PowerShell configuration

	@detaisl:
	- Environment configuration
	- Alias configuration

	@author:
	- madpang

	@date:
	- created on 2021-12-20
	- updated on 2025-02-03
#>

# === Environment setup

Set-Item -Path "env:GPG_TTY" -Value "$(tty)" # configure GPG_TTY such that gpg-agent can find the tty for passphrase input. @note, use `Get-Command -Name tty` to check whether the command is available

# === Alias configuration

Set-Alias -Name "open" -Value "xdg-open" -Force
