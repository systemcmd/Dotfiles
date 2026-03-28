# ── Zamanlama ─────────────────────────────────────────────────────────────────
$script:SystemCmdCmdStartTime = $null
$script:SystemCmdHoloFrame    = 0

# ── Hologram paleti — cyan → mavi → mor → pembe ───────────────────────────────
$script:SystemCmdHoloPalette = [int[]]@(
    51, 45, 39, 33, 27,
    57, 93, 129, 165, 201,
    199, 165, 129, 93, 57,
    27, 33, 39, 45, 51
)

function Get-SystemCmdHoloText {
    param(
        [string]$Text,
        [int]$Frame = 0
    )

    $pal  = $script:SystemCmdHoloPalette
    $plen = $pal.Length
    $sb   = [System.Text.StringBuilder]::new()

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $col = $pal[($Frame + $i) % $plen]
        [void]$sb.Append("`e[38;5;${col}m")
        [void]$sb.Append($Text[$i])
    }
    [void]$sb.Append("`e[0m")
    return $sb.ToString()
}

# ── Prompt fonksiyonu ─────────────────────────────────────────────────────────
function prompt {
    # Geçen süre
    $elapsed = ''
    if ($script:SystemCmdCmdStartTime) {
        $ms = ([datetime]::Now - $script:SystemCmdCmdStartTime).TotalMilliseconds
        if ($ms -gt 1500) {
            $elapsed = [math]::Round($ms / 1000, 1).ToString() + 's'
        }
        $script:SystemCmdCmdStartTime = $null
    }

    # Yol — ~ ile kısalt, uzunsa son 2 klasör
    $loc = ($PWD.Path -replace [regex]::Escape($HOME), '~') -replace '\\', '/'
    if ($loc.Length -gt 40) {
        $parts = $loc -split '/'
        if ($parts.Count -gt 3) {
            $loc = [char]0x2026 + '/' + ($parts[-2] + '/' + $parts[-1])
        }
    }

    # Git dal
    $branch = ''
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try { $branch = git branch --show-current 2>$null } catch {}
    }

    # Hologram kayar — her prompt çağrısında bir adım ilerler
    $script:SystemCmdHoloFrame = ($script:SystemCmdHoloFrame + 2) % $script:SystemCmdHoloPalette.Length
    $holoLabel = Get-SystemCmdHoloText -Text 'systemcmd' -Frame $script:SystemCmdHoloFrame
    $holoDot   = Get-SystemCmdHoloText -Text ([char]0x2736) -Frame $script:SystemCmdHoloFrame

    # ── Satır 1 ───────────────────────────────────────────────────────────────
    Write-Host ''
    Write-Host -NoNewline "$holoDot $holoLabel  `e[38;5;117m$loc`e[0m"

    if ($branch) {
        Write-Host -NoNewline "  `e[38;5;214m$branch`e[0m"
    }
    if ($elapsed) {
        Write-Host -NoNewline "  `e[38;5;244m$elapsed`e[0m"
    }
    Write-Host ''

    # ── Satır 2 ───────────────────────────────────────────────────────────────
    $holoArrow = Get-SystemCmdHoloText -Text '❯' -Frame ($script:SystemCmdHoloFrame + 5)
    return "$holoArrow "
}

# ── Enter tuşu — yalnızca zamanlama, animasyon yok ───────────────────────────
if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        param($key, $arg)

        $line = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()

        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $script:SystemCmdCmdStartTime = [datetime]::Now
        }
    }
}
