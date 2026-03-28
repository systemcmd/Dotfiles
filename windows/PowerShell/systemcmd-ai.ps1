# ── AI / Claude Code kısayolları ──────────────────────────────────────────────

function Invoke-SystemCmdAi {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    if (-not (Get-Command -Name claude -ErrorAction SilentlyContinue)) {
        Write-Host "`e[38;5;167m✗ 'claude' komutu bulunamadi. Kurulum: https://claude.ai/code`e[0m"
        return
    }

    if ($Args.Count -eq 0) {
        & claude
    } else {
        & claude @Args
    }
}

function Show-SystemCmdAiHelp {
    Write-Host ''
    Write-Host "`e[38;5;141m◆ Claude Code — hizli referans`e[0m"
    Write-Host "`e[38;5;244m$('─' * 54)`e[0m"

    $entries = @(
        @{ Cmd = 'ai';                    Desc = 'Claude Code interaktif mod' },
        @{ Cmd = 'ai "sorun"';            Desc = 'Dogrudan soru sor' },
        @{ Cmd = 'ai -p "komut"';         Desc = 'Tek seferlik print modu' },
        @{ Cmd = 'cloudhelp';             Desc = 'Tam referans menusu (fzf)' }
    )

    foreach ($e in $entries) {
        $cmd  = $e.Cmd.PadRight(26)
        Write-Host "  `e[38;5;117m$cmd`e[0m `e[38;5;245m$($e.Desc)`e[0m"
    }

    Write-Host ''

    if (Get-Command -Name claude -ErrorAction SilentlyContinue) {
        Write-Host "  `e[38;5;85m✓ claude kurulu`e[0m"
    } else {
        Write-Host "  `e[38;5;167m✗ claude bulunamadi — https://claude.ai/code`e[0m"
    }

    Write-Host ''
}

Set-Alias -Name ai -Value Invoke-SystemCmdAi -Option AllScope -Scope Global -Force
