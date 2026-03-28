function Show-SystemCmdVersion {
    $versionFile = Join-Path $script:SystemCmdRoot 'VERSION'
    $version = if (Test-Path $versionFile) { Get-Content $versionFile -Raw -ErrorAction SilentlyContinue } else { $null }

    $gitVersion = $null
    try {
        Push-Location $script:SystemCmdRoot
        $gitVersion = git describe --tags --always 2>$null
        Pop-Location
    } catch { Pop-Location -ErrorAction SilentlyContinue }

    Write-Host ''
    Write-Host "`e[38;5;141m✶ systemcmd`e[0m"
    if ($gitVersion) { Write-Host "  `e[38;5;117mGit:`e[0m `e[38;5;245m$($gitVersion.Trim())`e[0m" }
    if ($version)    { Write-Host "  `e[38;5;117mSurum:`e[0m `e[38;5;245m$($version.Trim())`e[0m" }
    Write-Host "  `e[38;5;117mKonum:`e[0m `e[38;5;245m$script:SystemCmdRoot`e[0m"
    Write-Host "  `e[38;5;117mPowerShell:`e[0m `e[38;5;245m$($PSVersionTable.PSVersion)`e[0m"
    Write-Host ''
}

function Update-SystemCmd {
    Write-Host "`e[38;5;141m✶ systemcmd guncelleniyor…`e[0m"

    # Git ile guncelle
    $isGit = $false
    try {
        Push-Location $script:SystemCmdRoot
        $status = git status 2>$null
        $isGit  = $LASTEXITCODE -eq 0
    } catch {}

    if ($isGit) {
        Write-Host "  `e[38;5;244mGit pull yapiliyor…`e[0m"
        try {
            git pull origin main 2>&1 | ForEach-Object {
                Write-Host "  `e[38;5;245m$_`e[0m"
            }
            Write-Host "  `e[38;5;85m✓ Guncellendi`e[0m"
        } catch {
            Write-Host "  `e[38;5;167m✗ Git pull basarisiz: $_`e[0m"
        } finally {
            Pop-Location -ErrorAction SilentlyContinue
        }
    } else {
        Pop-Location -ErrorAction SilentlyContinue
        Write-Host "  `e[38;5;214m⚠ Git reposu degil. Manuel guncelleme gerekiyor.`e[0m"
        return
    }

    # Profili yeniden yukle
    Write-Host "  `e[38;5;244mProfil yeniden yukleniyor…`e[0m"
    try {
        . $PROFILE
        Write-Host "  `e[38;5;85m✓ Profil yuklendi`e[0m"
    } catch {
        Write-Host "  `e[38;5;167m✗ Profil yuklenemedi: $($_.Exception.Message)`e[0m"
    }
    Write-Host ''
}

function Measure-SystemCmdLoadTime {
    Write-Host ''
    Write-Host "`e[38;5;141m◆ Profil yukleme suresi analizi`e[0m"
    Write-Host "`e[38;5;244m$('─' * 50)`e[0m"

    $scripts = @(
        'systemcmd-tools.ps1',
        'systemcmd-menu.ps1',
        'cloudhelp.ps1',
        'systemcmd-prompt.ps1',
        'systemcmd-config.ps1',
        'systemcmd-welcome.ps1',
        'systemcmd-git.ps1',
        'systemcmd-ssh.ps1',
        'systemcmd-env.ps1',
        'systemcmd-ai.ps1',
        'systemcmd-run.ps1',
        'systemcmd-stats.ps1',
        'systemcmd-dashboard.ps1',
        'systemcmd-update.ps1'
    )

    $totalMs = 0
    $results = @()

    foreach ($script in $scripts) {
        $path = Join-Path $script:SystemCmdRoot $script
        if (-not (Test-Path $path)) { continue }

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $content = Get-Content $path
            $null    = [System.Management.Automation.ScriptBlock]::Create($content -join "`n")
        } catch {}
        $sw.Stop()

        $results += [PSCustomObject]@{ File = $script; Ms = $sw.ElapsedMilliseconds }
        $totalMs += $sw.ElapsedMilliseconds
    }

    $maxMs  = ($results | Measure-Object Ms -Maximum).Maximum
    $bar    = 24

    foreach ($r in $results | Sort-Object Ms -Descending) {
        $filled = if ($maxMs -gt 0) { [int]($bar * $r.Ms / $maxMs) } else { 0 }
        $empty  = $bar - $filled
        $color  = if ($r.Ms -lt 20) { 85 } elseif ($r.Ms -lt 60) { 214 } else { 167 }
        $msStr  = "$($r.Ms)ms".PadLeft(6)
        $barStr = "`e[38;5;${color}m$('█' * $filled)`e[38;5;236m$('░' * $empty)`e[0m"
        $name   = $r.File.PadRight(28)
        Write-Host "  `e[38;5;245m$name`e[0m $barStr `e[38;5;${color}m$msStr`e[0m"
    }

    Write-Host "  `e[38;5;244m$('─' * 50)`e[0m"
    Write-Host "  `e[38;5;117mToplam:`e[0m `e[38;5;245m${totalMs}ms`e[0m"
    Write-Host ''

    if ($totalMs -gt 500) {
        Write-Host "  `e[38;5;214m⚠ Profil yavaş yükleniyor. Büyük ms değerli dosyaları inceleyin.`e[0m"
    }
    Write-Host ''
}
