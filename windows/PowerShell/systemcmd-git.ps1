# ── Git iş akışı kısayolları ──────────────────────────────────────────────────

function Test-SystemCmdGitRepo {
    $result = git rev-parse --is-inside-work-tree 2>$null
    return ($LASTEXITCODE -eq 0 -and $result -eq 'true')
}

function Get-SystemCmdBatCommand {
    if (Get-Command -Name bat -ErrorAction SilentlyContinue) { return 'bat' }
    if (Get-Command -Name batcat -ErrorAction SilentlyContinue) { return 'batcat' }
    return $null
}

# ── gco — branch/tag checkout ─────────────────────────────────────────────────
function gco {
    if (-not (Test-SystemCmdGitRepo)) { return }

    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf bulunamadi.' -ForegroundColor Yellow
        return
    }

    $fzfColor = if (Get-Command -Name Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { $null }

    $fzfArgs = @(
        '--prompt', 'checkout > ',
        '--preview', 'git log --oneline -10 {}',
        '--ansi',
        '--border',
        '--layout', 'reverse'
    )
    if ($fzfColor) { $fzfArgs += '--color', $fzfColor }

    $branch = git branch -a --format '%(refname:short)' 2>$null |
        & fzf @fzfArgs

    if ([string]::IsNullOrWhiteSpace($branch)) { return }

    $branch = $branch.Trim()

    try {
        git checkout $branch 2>&1 | ForEach-Object {
            Write-Host "`e[38;5;85m$_`e[0m"
        }
    } catch {
        Write-Host ("`e[38;5;167mgco hatasi: {0}`e[0m" -f $_.Exception.Message)
    }
}

# ── glog — interaktif git log ─────────────────────────────────────────────────
function glog {
    if (-not (Test-SystemCmdGitRepo)) { return }

    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf bulunamadi.' -ForegroundColor Yellow
        return
    }

    $fzfColor = if (Get-Command -Name Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { $null }

    $fzfArgs = @(
        '--prompt', 'log > ',
        '--preview', 'git show --stat --color=always {1}',
        '--ansi',
        '--border',
        '--layout', 'reverse'
    )
    if ($fzfColor) { $fzfArgs += '--color', $fzfColor }

    $selected = git log --oneline --color=always 2>$null |
        & fzf @fzfArgs

    if ([string]::IsNullOrWhiteSpace($selected)) { return }

    $hash = ($selected -split '\s+', 2)[0].Trim()
    if ([string]::IsNullOrWhiteSpace($hash)) { return }

    $batCmd = Get-SystemCmdBatCommand
    if ($batCmd) {
        try {
            git show --color=always $hash | & $batCmd --color=always --style=plain --paging=always
        } catch {
            git show --color=always $hash
        }
    } else {
        git show --color=always $hash
    }
}

# ── gstash — stash gezgini ────────────────────────────────────────────────────
function gstash {
    if (-not (Test-SystemCmdGitRepo)) { return }

    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf bulunamadi.' -ForegroundColor Yellow
        return
    }

    $stashList = git stash list 2>$null
    if (-not $stashList) {
        Write-Host "`e[38;5;244mHicbir stash bulunamadi.`e[0m"
        return
    }

    $fzfColor = if (Get-Command -Name Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { $null }

    $fzfArgs = @(
        '--prompt', 'stash > ',
        '--preview', 'git stash show -p {1} --color=always',
        '--expect', 'ctrl-d,ctrl-a',
        '--border',
        '--layout', 'reverse',
        '--ansi'
    )
    if ($fzfColor) { $fzfArgs += '--color', $fzfColor }

    $output = $stashList | & fzf @fzfArgs

    if (-not $output) { return }

    $lines = @($output)

    # fzf --expect: ilk satır tetikleyen tuş (boşsa Enter), ikinci satır seçim
    $key       = if ($lines.Count -ge 2) { $lines[0].Trim() } else { '' }
    $selection = if ($lines.Count -ge 2) { $lines[1] } else { $lines[0] }

    if ([string]::IsNullOrWhiteSpace($selection)) { return }

    # stash@{N} çıkar (ilk alan)
    $stashRef = ($selection -split '\s+', 2)[0].Trim() -replace ':$', ''
    if ([string]::IsNullOrWhiteSpace($stashRef)) { return }

    switch ($key) {
        'ctrl-d' {
            Write-Host ("`e[38;5;167mDusuruldu: $stashRef`e[0m")
            git stash drop $stashRef 2>&1 | ForEach-Object { Write-Host "`e[38;5;244m$_`e[0m" }
        }
        'ctrl-a' {
            git stash apply $stashRef 2>&1 | ForEach-Object { Write-Host "`e[38;5;85m$_`e[0m" }
        }
        default {
            # Enter — sadece göster
            git stash show -p $stashRef --color=always
        }
    }
}

# ── gwip — hızlı wip commit ───────────────────────────────────────────────────
function gwip {
    if (-not (Test-SystemCmdGitRepo)) { return }

    try {
        git add -A 2>&1 | Out-Null
        $msg = 'wip: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm')
        git commit -m $msg 2>&1 | ForEach-Object { Write-Host "`e[38;5;85m$_`e[0m" }
    } catch {
        Write-Host ("`e[38;5;167mgwip hatasi: {0}`e[0m" -f $_.Exception.Message)
    }
}

# ── gunwip — son wip commit'i geri al ────────────────────────────────────────
function gunwip {
    if (-not (Test-SystemCmdGitRepo)) { return }

    try {
        $lastMsg = git log -1 --format='%s' 2>$null
        if ($lastMsg -notlike 'wip:*') {
            Write-Host "`e[38;5;214mSon commit bir wip degil: $lastMsg`e[0m"
            return
        }
        git reset HEAD~1 --soft 2>&1 | ForEach-Object { Write-Host "`e[38;5;85m$_`e[0m" }
        Write-Host "`e[38;5;85mWip commit geri alindi (soft reset).`e[0m"
    } catch {
        Write-Host ("`e[38;5;167mgunwip hatasi: {0}`e[0m" -f $_.Exception.Message)
    }
}

# ── gst — renkli git status ───────────────────────────────────────────────────
function gst {
    if (-not (Test-SystemCmdGitRepo)) { return }

    git -c color.status=always status -s
}

# ── gbd — branch sil (fzf çoklu seçim) ──────────────────────────────────────
function gbd {
    if (-not (Test-SystemCmdGitRepo)) { return }

    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf bulunamadi.' -ForegroundColor Yellow
        return
    }

    $currentBranch = git branch --show-current 2>$null

    $branches = git branch --format '%(refname:short)' 2>$null |
        Where-Object { $_.Trim() -ne $currentBranch.Trim() -and -not [string]::IsNullOrWhiteSpace($_) }

    if (-not $branches) {
        Write-Host "`e[38;5;244mSilinebilecek baska branch yok.`e[0m"
        return
    }

    $fzfColor = if (Get-Command -Name Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { $null }

    $fzfArgs = @(
        '--prompt', 'branch sil > ',
        '--multi',
        '--preview', 'git log --oneline -10 {}',
        '--ansi',
        '--border',
        '--layout', 'reverse'
    )
    if ($fzfColor) { $fzfArgs += '--color', $fzfColor }

    $selected = $branches | & fzf @fzfArgs

    if (-not $selected) { return }

    $toDelete = @($selected | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($toDelete.Count -eq 0) { return }

    Write-Host ''
    Write-Host "`e[38;5;167mSilinecek branch'ler:`e[0m"
    foreach ($b in $toDelete) {
        Write-Host "  `e[38;5;167m- $b`e[0m"
    }

    Write-Host ''
    $confirm = Read-Host 'Silmek icin "evet" yaz'
    if ($confirm.Trim().ToLower() -ne 'evet') {
        Write-Host "`e[38;5;244mIptal edildi.`e[0m"
        return
    }

    foreach ($b in $toDelete) {
        try {
            git branch -d $b.Trim() 2>&1 | ForEach-Object { Write-Host "`e[38;5;85m$_`e[0m" }
        } catch {
            Write-Host ("`e[38;5;167m$b silinemedi: {0}`e[0m" -f $_.Exception.Message)
        }
    }
}
