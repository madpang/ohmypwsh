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
	- updated on 2024-11-23

	@todo:
	- [x] Rearrange prompt function
	- [i] Light theme
	- [ ] Limit prompt length
#>

# /////////////////// Locale settings //////////////////////////
[cultureinfo]::CurrentCulture = 'ja-JP'

# ///////////////// Environment setup //////////////////////////

# Unload PSReadline (@note, ince PSReadline is automatically loaded, we unload it first to do some configuration)
Remove-Module -Name PSReadline

# Set global variables (prefix with `Global:` is equivalent to set `-Scope Global`)

Set-Variable -Name "Global:PD_ERROR_STAT" -Value $true -Visibility Private

Set-Variable -Name "Global:PD_PROMPT_PATH" -Value "N/A" # @todo

Set-Variable -Name "Global:PD_PROMPT_MACHINE" -Value ([Environment]::MachineName) -Visibility Private

Set-Variable -Name "Global:PD_PROMPT_USER" -Value ([Environment]::UserName) -Visibility Private

New-Variable `
	-Name "PD_COLOR_PALLETE" `
	-Value @{
		'Licorice'   = '#000000';
		'Lead'       = '#212121';
		'Tin'        = '#919191'
		'Silver'     = '#D6D6D6';
		'Snow'       = '#FFFFFF';
		'Cayenne'    = '#941100';
		'Ocean'      = '#005493';
		'Midnight'   = '#011993';
		'Lemon'      = '#FFFB00'
		'Banana'     = '#FFFC79';
		'Salmon'     = '#FF7E79';
		'Spindrift'  = '#73FCD6';
		'Sky'        = '#76D6FF';
		'Strawberry' = '#FF2F92';
	} `
	-Scope Global `
	-Visibility Public `
	-Option ReadOnly

New-Variable `
	-Name "PD_PROMPT_COLOR" `
	-Value @{
		'BG_USER'    = '255;255;255';
		'FG_USER'    = '0;0;0';
		'BG_MACHINE' = '255;255;255';
		'FG_MACHINE' = '0;0;0';
		'BG_PATH'    = '255;255;255';
		'FG_PATH'    = '0;0;0';
		'BG_AUX'     = '255;255;255';
		'FG_AUX'     = '0;0;0';
	} `
	-Scope Global `
	-Visibility Private

# Set-Item -Path "variable:$Global:PD_ERROR_STAT" -Value $true

# /////////////////// Utility functions ////////////////////////

# @brief: convert #RRGGBB to ANSI escape sequence
function Convert-HexColorToANSI {
	[OutputType([String])]
	param (
		[Parameter(Mandatory = $True, Position = 0)][string]$hex_color
	)

	# Validate input format
	if ($hex_color -notmatch '^#([A-Fa-f0-9]{6})$') {
		throw "Invalid color format. Please use #RRGGBB."
	}

	# Extract the RGB values from the hex color
	$r = [Convert]::ToInt32($hex_color.Substring(1, 2), 16)
	$g = [Convert]::ToInt32($hex_color.Substring(3, 2), 16)
	$b = [Convert]::ToInt32($hex_color.Substring(5, 2), 16)

	return "${r};${g};${b}"
}

# /// Prompt configuration
# //////////////////////////////////////////////////////////////

# @brief: Prompt function
function prompt {
	$stat = $Global:custom_error_status -and $? # @todo
	# Line 2 (time and status)
	$line_2 = @(
		'|-',
		'[',
		(Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"), # ISO 8601 format
		']',
		'[',
		($stat ? 'o' : 'x'),
		']',
		'[',
		$Global:custom_git_prompt,
		']'
	) -join ''
	# Line 3 (empty)
	$line_3 = ''
	# Line 0 ([env][name@machine:path][git])
	$line_0 = @(
		'|-',
		'[',
		(
			("`e[48;2;$($Global:PD_PROMPT_COLOR['BG_USER']);38;2;$($Global:PD_PROMPT_COLOR['FG_USER'])m" + $Global:PD_PROMPT_USER) +
			("`e[48;2;$($Global:PD_PROMPT_COLOR['BG_AUX']);38;2;$($Global:PD_PROMPT_COLOR['FG_AUX'])m" + '@') +
			("`e[48;2;$($Global:PD_PROMPT_COLOR['BG_MACHINE']);38;2;$($Global:PD_PROMPT_COLOR['FG_MACHINE'])m" + $Global:PD_PROMPT_MACHINE) +
			("`e[48;2;$($Global:PD_PROMPT_COLOR['BG_AUX']);38;2;$($Global:PD_PROMPT_COLOR['FG_AUX'])m" + ':') +
			("`e[48;2;$($Global:PD_PROMPT_COLOR['BG_PATH']);38;2;$($Global:PD_PROMPT_COLOR['FG_PATH'])m" + $(pwd)) +
			"`e[0m"
		),
		']',
		'[',
		$Global:custom_env_prompt, # @todo
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

# Set PSReadline options (@note: HistoryNoDuplicates and HistorySearchCursorMovesToEnd are of type SwitchParameter)
Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -HistorySearchCursorMovesToEnd
# Set PSReadline key handlers
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# /// Alias configuration
# ////////////////////////////////////////////////////////////

# Remove all aliases @todo
# Remove-Item -Path "alias:*" -Force
Remove-Item -Path "alias:pwd" -Force
