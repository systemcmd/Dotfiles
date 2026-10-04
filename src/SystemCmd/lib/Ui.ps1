# SystemCmd.UI — terminal-native rendering engine. Reusable ANSI components that
# degrade to plain ASCII when the terminal lacks colour/unicode. No GUI, ever.

$script:SystemCmdEsc = [char]27
$script:SystemCmdUiCache = $null

# Colour palette (role -> RGB) plus a 4-bit fallback for non-truecolor terminals.
$script:SystemCmdThemes = @{
    shadow = @{
        accent = @(88, 214, 184);  title = @(240, 246, 252); dim = @(123, 135, 152)
        add    = @(126, 231, 135);  del   = @(255, 123, 114); mod = @(227, 179, 65)
        ok     = @(126, 231, 135);  warn  = @(227, 179, 65);  err = @(255, 123, 114)
        info   = @(121, 192, 255);  muted = @(86, 97, 111)
    }
}
$script:SystemCmdFallback = @{
    accent = 36; title = 97; dim = 90; add = 32; del = 31; mod = 33
    ok = 32; warn = 33; err = 31; info = 34; muted = 90
}

function Reset-SystemCmdUi { $script:SystemCmdUiCache = $null }

function Get-SystemCmdUi {
    param([switch]$Refresh)
    if ($Refresh) { $script:SystemCmdUiCache = $null }
    if ($script:SystemCmdUiCache) { return $script:SystemCmdUiCache }

    $caps = Get-SystemCmdCapabilities
    $unicode = $caps.Unicode
    $glyphs = if ($unicode) {
        @{ TL = '╭'; TR = '╮'; BL = '╰'; BR = '╯'; H = '─'; V = '│'; Dot = '●'; Ring = '◉'
           Check = '✓'; Cross = '✗'; Arrow = '❯'; Tri = '›'; Plus = '+'; Minus = '-'; Bar = '│' }
    } else {
        @{ TL = '+'; TR = '+'; BL = '+'; BR = '+'; H = '-'; V = '|'; Dot = '*'; Ring = 'o'
           Check = 'v'; Cross = 'x'; Arrow = '>'; Tri = '>'; Plus = '+'; Minus = '-'; Bar = '|' }
    }

    $cfg = try { Get-SystemCmdConfig } catch { $null }
    $themeName = if ($cfg -and $cfg.PSObject.Properties['theme']) { [string]$cfg.theme } else { 'shadow' }
    if (-not $script:SystemCmdThemes.ContainsKey($themeName)) { $themeName = 'shadow' }

    $script:SystemCmdUiCache = [pscustomobject]@{
        Caps    = $caps
        Glyphs  = $glyphs
        Theme   = $themeName
        Palette = $script:SystemCmdThemes[$themeName]
    }
    return $script:SystemCmdUiCache
}

function Remove-SystemCmdAnsi {
    param([string]$Text)
    if (-not $Text) { return '' }
    return [regex]::Replace($Text, "$([char]27)\[[0-9;]*m", '')
}

function Measure-SystemCmdWidth {
    param([string]$Text)
    return (Remove-SystemCmdAnsi $Text).Length
}

function Format-SystemCmdText {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text, [string]$Role = 'title', [switch]$Bold)
    $ui = Get-SystemCmdUi
    if (-not $ui.Caps.Color) { return $Text }
    $e = $script:SystemCmdEsc
    $prefix = ''
    if ($ui.Caps.TrueColor -and $ui.Palette.ContainsKey($Role)) {
        $rgb = $ui.Palette[$Role]
        $prefix = "$e[38;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m"
    } elseif ($script:SystemCmdFallback.ContainsKey($Role)) {
        $prefix = "$e[$($script:SystemCmdFallback[$Role])m"
    }
    if ($Bold) { $prefix = "$e[1m$prefix" }
    if (-not $prefix) { return $Text }
    return "$prefix$Text$e[0m"
}

# Truncate/pad a string to exactly $Width visible cells, preserving ANSI SGR codes.
function Format-SystemCmdFit {
    param([string]$Text, [Parameter(Mandatory)][int]$Width)
    if ($Width -lt 0) { $Width = 0 }
    $e = $script:SystemCmdEsc
    $sb = [System.Text.StringBuilder]::new()
    $visible = 0; $i = 0; $n = $Text.Length; $truncated = $false
    while ($i -lt $n) {
        $ch = $Text[$i]
        if ($ch -eq $e) {
            $j = $i
            while ($j -lt $n -and $Text[$j] -ne 'm') { [void]$sb.Append($Text[$j]); $j++ }
            if ($j -lt $n) { [void]$sb.Append($Text[$j]); $j++ }
            $i = $j
            continue
        }
        if ($visible -ge $Width) { $truncated = $true; break }
        [void]$sb.Append($ch); $visible++; $i++
    }
    if ($truncated) { [void]$sb.Append("$e[0m") }
    if ($visible -lt $Width) { [void]$sb.Append((' ' * ($Width - $visible))) }
    return $sb.ToString()
}

function Get-SystemCmdBadge {
    param([Parameter(Mandatory)][string]$Text, [string]$Role = 'info')
    return (Format-SystemCmdText -Text " $Text " -Role $Role)
}

# Build a bordered panel (array of strings). Title is embedded in the top border.
function Get-SystemCmdPanel {
    param([string]$Title = '', [string[]]$Lines = @(), [int]$Width = 0)
    $ui = Get-SystemCmdUi
    $g = $ui.Glyphs
    $term = $ui.Caps.Width
    $lineWidths = @(0)
    foreach ($l in $Lines) { $lineWidths += (Measure-SystemCmdWidth $l) }
    $titleLabel = if ($Title) { " $Title " } else { '' }
    $contentWidth = ($lineWidths | Measure-Object -Maximum).Maximum
    $titleWidth = (Measure-SystemCmdWidth $titleLabel) + 2
    if ($titleWidth -gt $contentWidth) { $contentWidth = $titleWidth }
    if ($Width -gt 0) { $contentWidth = $Width }
    $maxContent = $term - 4
    if ($maxContent -lt 8) { $maxContent = 8 }
    if ($contentWidth -gt $maxContent) { $contentWidth = $maxContent }

    $totalInner = $contentWidth + 2
    $out = New-Object System.Collections.Generic.List[string]

    if ($titleLabel) {
        $coloredTitle = Format-SystemCmdText -Text $titleLabel.Trim() -Role 'title' -Bold
        $used = 1 + (Measure-SystemCmdWidth $titleLabel)   # leading H + label
        $dash = $totalInner - $used
        if ($dash -lt 0) { $dash = 0 }
        $out.Add((Format-SystemCmdText -Text $g.TL -Role 'muted') + (Format-SystemCmdText -Text "$($g.H) " -Role 'muted') + $coloredTitle + ' ' + (Format-SystemCmdText -Text ($g.H * ([Math]::Max(0, $dash))) -Role 'muted') + (Format-SystemCmdText -Text $g.TR -Role 'muted'))
    } else {
        $out.Add((Format-SystemCmdText -Text ($g.TL + ($g.H * $totalInner) + $g.TR) -Role 'muted'))
    }

    foreach ($l in $Lines) {
        $body = Format-SystemCmdFit -Text $l -Width $contentWidth
        $v = Format-SystemCmdText -Text $g.V -Role 'muted'
        $out.Add("$v $body $v")
    }

    $out.Add((Format-SystemCmdText -Text ($g.BL + ($g.H * $totalInner) + $g.BR) -Role 'muted'))
    return $out.ToArray()
}

function Show-SystemCmdPanel {
    param([string]$Title = '', [string[]]$Lines = @(), [int]$Width = 0)
    Get-SystemCmdPanel -Title $Title -Lines $Lines -Width $Width | ForEach-Object { Write-Host $_ }
}

# A label/value row for HUD panels, right-padded to $Width visible cells.
function Format-SystemCmdRow {
    param([string]$Label, [string]$Value, [int]$LabelWidth = 10, [int]$Width = 36)
    $labelText = Format-SystemCmdText -Text ($Label.PadRight($LabelWidth)) -Role 'dim'
    $valueText = Format-SystemCmdText -Text $Value -Role 'title'
    return (Format-SystemCmdFit -Text "$labelText $valueText" -Width $Width)
}

# Read a single key without echo; returns a normalised string like 'Up','Enter','q'.
function Read-SystemCmdKey {
    try {
        $k = [Console]::ReadKey($true)
    } catch { return $null }
    switch ($k.Key) {
        'UpArrow' { return 'Up' }
        'DownArrow' { return 'Down' }
        'LeftArrow' { return 'Left' }
        'RightArrow' { return 'Right' }
        'Enter' { return 'Enter' }
        'Escape' { return 'Esc' }
        default { if ($k.KeyChar) { return [string]$k.KeyChar } else { return [string]$k.Key } }
    }
}
