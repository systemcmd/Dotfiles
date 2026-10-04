# SystemCmd.Platform — OS identity, config, and terminal capability detection.
# All OS/terminal branching lives here so the rest of the module stays portable.

function Get-SystemCmdPlatform {
    if ($IsWindows) { return 'Windows' }
    if ($IsMacOS) { return 'macOS' }
    if ($IsLinux) { return 'Linux' }
    return 'Unknown'
}

function Get-SystemCmdConfigPath {
    $base = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } elseif ($IsWindows) { Join-Path $HOME '.systemcmd' } else { Join-Path $HOME '.config' }
    if (-not $IsWindows) { $base = Join-Path $base 'systemcmd' }
    return Join-Path $base 'config.json'
}

function Get-SystemCmdConfig {
    $defaults = [ordered]@{ language = 'tr'; theme = 'shadow'; promptMode = 'normal'; livePane = @{ enabled = $true; autoOpen = $true; position = 'right'; size = 35 }; dashboard = @{ refreshMs = 2000 }; run = @{ autoDetect = $true } }
    $path = Get-SystemCmdConfigPath
    if (-not (Test-Path -LiteralPath $path)) { return [pscustomobject]$defaults }
    try { return (Get-Content -LiteralPath $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop) }
    catch { return [pscustomobject]$defaults }
}

function Set-SystemCmdConfig {
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Values)
    $path = Get-SystemCmdConfigPath
    $dir = Split-Path -Parent $path
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $config = Get-SystemCmdConfig
    foreach ($key in $Values.Keys) { $config | Add-Member -NotePropertyName $key -NotePropertyValue $Values[$key] -Force }
    $config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding utf8
}

# Switch the console to UTF-8 so box-drawing/status glyphs render (opt-in; the
# profile bridge or `systemcmd` installer calls this). Safe no-op on failure.
function Enable-SystemCmdUtf8 {
    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $global:OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        if (Get-Command Reset-SystemCmdUi -ErrorAction SilentlyContinue) { Reset-SystemCmdUi }
        return $true
    } catch { return $false }
}

function Get-SystemCmdTerminalWidth {
    # Robust terminal width even when the host is redirected.
    try {
        $w = $Host.UI.RawUI.WindowSize.Width
        if ($w -and $w -gt 0) { return [int]$w }
    } catch { }
    try {
        $w = [Console]::WindowWidth
        if ($w -and $w -gt 0) { return [int]$w }
    } catch { }
    if ($env:COLUMNS -and ($env:COLUMNS -as [int])) { return [int]$env:COLUMNS }
    return 80
}

<#
.SYNOPSIS
Detect what the current terminal supports, so the UI can degrade gracefully.
Signals used: NO_COLOR, COLORTERM, WT_SESSION, TERM, TERM_PROGRAM, host redirection.
#>
function Get-SystemCmdCapabilities {
    $isWt = [bool]$env:WT_SESSION
    $termProgram = $env:TERM_PROGRAM
    $colorterm = "$($env:COLORTERM)".ToLowerInvariant()
    $term = "$($env:TERM)".ToLowerInvariant()

    $noColor = [bool]$env:NO_COLOR
    $interactive = $false
    try { $interactive = [Environment]::UserInteractive -and -not [Console]::IsOutputRedirected } catch { $interactive = [Environment]::UserInteractive }

    $color = (-not $noColor) -and ($interactive -or $isWt)

    $trueColor = $color -and (
        $colorterm -eq 'truecolor' -or $colorterm -eq '24bit' -or $isWt -or
        $termProgram -in @('iTerm.app', 'vscode', 'WezTerm', 'Apple_Terminal', 'ghostty') -or
        $term -match '256color'
    )

    # Unicode: on Windows, box-drawing glyphs only survive if the console output
    # encoding is UTF-8 (codepage 65001). WT alone is not enough — pwsh must emit UTF-8.
    # Otherwise we fall back to ASCII (Enable-SystemCmdUtf8 switches the console to UTF-8).
    if ($IsWindows) {
        try { $unicode = ([Console]::OutputEncoding.CodePage -eq 65001) } catch { $unicode = $false }
    } else {
        $unicode = $true
    }

    $hyperlinks = $color -and ($isWt -or $termProgram -in @('iTerm.app', 'WezTerm', 'vscode', 'ghostty'))

    [pscustomobject]@{
        Platform    = Get-SystemCmdPlatform
        Color       = [bool]$color
        TrueColor   = [bool]$trueColor
        Unicode     = [bool]$unicode
        Ascii       = -not [bool]$unicode
        Hyperlinks  = [bool]$hyperlinks
        Interactive = [bool]$interactive
        Width       = Get-SystemCmdTerminalWidth
    }
}
