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
