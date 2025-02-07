<#
	@brief: Common PowerShell configuration for all platforms

	@detaisl:
	- Locale configuration
	- Environment configuration
	- Alias configuration
	- Prompt configuration
	- PSReadline configuration

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
Remove-Module -Name PSReadline

# Set environment variables

Set-Item -Path "env:GPG_TTY" -Value "$(tty)" # configure GPG_TTY such that gpg-agent can find the tty for passphrase input. @note, use `Get-Command -Name tty` to check whether the command is available

# Set global variables

Set-Variable -Name "Global:PD_ERROR_STAT" -Value $true

Set-Variable -Name "Global:PD_PROMPT_PATH" -Value "N/A" # @todo

Set-Variable -Name "Global:PD_PROMPT_MACHINE" -Value ([Environment]::MachineName)

Set-Variable -Name "Global:PD_PROMPT_USER" -Value ([Environment]::UserName)

# Set-Item -Path "variable:$Global:PD_ERROR_STAT" -Value $true

# /// Alias configuration

# /// Prompt configuration
# ////////////////////////////////////////////////////////////

# Prompt function
Function prompt {
	$stat = $Global:custom_error_status -and $? # @todo
	# Line 2 (time and status)
	$line_2 = @(
		'|-',
		'[',
		(Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"), # ISO 8601 format
		']',
		'[',
		($stat ? 'o' : 'x'),
		']'
	) -join ''
	# Line 3 (empty)
	$line_3 = ''
	# Line 0 ([env][name@machine:path][git])
	$line_0 = @(
		'|-',
		'[',
		$Global:custom_conda_prompt, # @todo
		']',
		'[',
		(
			$Global:PD_PROMPT_USER +
			'@' + $Global:PD_PROMPT_MACHINE + ':' + 
			$(pwd) # @todo
		),
		']',
		'[',
		$Global:custom_git_info.git_prompt,
		']'
	) -join ''
	# Line 1 (command)
	$line_1 = @(
		':',
		' '
	) -join ''

	$Global:custom_error_status = $true

	return @(
		$line_2,
		$line_3,
		$line_0,
		$line_1
	) -join [System.Environment]::newline
}

# /// PSReadline configuration
# ////////////////////////////////////////////////////////////

# Re-load PSReadline
Import-Module -Name PSReadline

# Set PSReadline options
$PSReadLineOptions = @{
	EditMode = "Emacs";
	HistoryNoDuplicates = $true;
	HistorySearchCursorMovesToEnd = $true
}
Set-PSReadLineOption @PSReadLineOptions
