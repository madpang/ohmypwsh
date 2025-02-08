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
		'Lemon'      = '#FFFB00';
		'Spring'     = '#00F900';
		'Turquoise'  = '#00FDFF';
		'Salmon'     = '#FF7E79';
		'Banana'     = '#FFFC79';
		'Flora'      = '#73FA79';
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

# @brief: Switch the light/dark theme for the prompt
# @details:
# There are two major parts for the thme
# 1. The PSReadLine coloring
# 2. The custom prompt coloring
# 3. console coloring
# @param[in]: $Theme - the theme name
# @param[out]: None
# @note: This utility function is not a real function in the rigorous functional programming sense, since it has side effects.
function Switch-Theme {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Dark", "Light")]
        [string]$Theme
    )
    if ($Theme -eq "Dark") {

		$Global:PD_PROMPT_COLOR = @{
			'BG_USER'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Ocean']);
			'FG_USER'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'BG_MACHINE' = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'FG_MACHINE' = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Licorice']);
			'BG_PATH'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Cayenne']);
			'FG_PATH'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'BG_AUX'     = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Licorice']);
			'FG_AUX'     = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
		}

		Set-PSReadLineOption -Color @{
			'Default'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']))m";
			'Command'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Lemon']))m";
			'Operator'               = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Lemon']))m";
			'Parameter'              = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']))m";
			ContinuationPrompt       = $PSStyle.Foreground.FromRGB(0x0000FF)
			Emphasis                 = $PSStyle.Foreground.FromRGB(0x287BF0)
			Error                    = $PSStyle.Foreground.FromRGB(0xE50000)
			InlinePrediction         = $PSStyle.Foreground.FromRGB(0x93A1A1)
			Keyword                  = $PSStyle.Foreground.FromRGB(0x00008b)
			ListPrediction           = $PSStyle.Foreground.FromRGB(0x06DE00)
			Member                   = $PSStyle.Foreground.FromRGB(0x000000)
			Number                   = $PSStyle.Foreground.FromRGB(0x800080)			
			String                   = $PSStyle.Foreground.FromRGB(0x8b0000)
			Type                     = $PSStyle.Foreground.FromRGB(0x008080)
			Variable                 = $PSStyle.Foreground.FromRGB(0xff4500)
			ListPredictionSelected   = $PSStyle.Background.FromRGB(0x93A1A1)
			Selection                = $PSStyle.Background.FromRGB(0x00BFFF)
			'Comment'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Tin']))m";
		}

		$PSStyle.Formatting.TableHeader = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']))m";
		$PSStyle.FileInfo.Directory = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Turquoise']))m";
		$PSStyle.FileInfo.SymbolicLink = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Silver']))m";

    } elseif ($Theme -eq "Light") {

		$Global:PD_PROMPT_COLOR = @{
			'BG_USER'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Ocean']);
			'FG_USER'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'BG_MACHINE' = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Licorice']);
			'FG_MACHINE' = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'BG_PATH'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Cayenne']);
			'FG_PATH'    = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Snow']);
			'BG_AUX'     = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Silver']);
			'FG_AUX'     = (Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Licorice']);
		}

		Set-PSReadLineOption -Color @{
			'Default'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Licorice']))m";
			'Command'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Midnight']))m";
			'Operator'               = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Midnight']))m";
			ContinuationPrompt       = $PSStyle.Foreground.FromRGB(0x0000FF)
			Emphasis                 = $PSStyle.Foreground.FromRGB(0x287BF0)
			Error                    = $PSStyle.Foreground.FromRGB(0xE50000)
			InlinePrediction         = $PSStyle.Foreground.FromRGB(0x93A1A1)
			Keyword                  = $PSStyle.Foreground.FromRGB(0x00008b)
			ListPrediction           = $PSStyle.Foreground.FromRGB(0x06DE00)
			Member                   = $PSStyle.Foreground.FromRGB(0x000000)
			Number                   = $PSStyle.Foreground.FromRGB(0x800080)
			Parameter                = $PSStyle.Foreground.FromRGB(0x000080)
			String                   = $PSStyle.Foreground.FromRGB(0x8b0000)
			Type                     = $PSStyle.Foreground.FromRGB(0x008080)
			Variable                 = $PSStyle.Foreground.FromRGB(0xff4500)
			ListPredictionSelected   = $PSStyle.Background.FromRGB(0x93A1A1)
			Selection                = $PSStyle.Background.FromRGB(0x00BFFF)
			'Comment'                = "`e[38;2;$((Convert-HexColorToANSI $Global:PD_COLOR_PALLETE['Tin']))m";
		}

	}
	Write-Host "Switched to $Theme theme."
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
