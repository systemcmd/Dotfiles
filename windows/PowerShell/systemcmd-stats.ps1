function Show-SystemCmdStats {
    $histPath = $null
    try {
        if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
            $histPath = (Get-PSReadLineOption).HistorySavePath
        }
    } catch {}

    if (-not $histPath -or -not (Test-Path $histPath)) {
        Write-Host 'Gecmis dosyasi bulunamadi.' -ForegroundColor Red
        return
    }

    $lines = Get-Content $histPath -ErrorAction SilentlyContinue
    if (-not $lines) { Write-Host 'Gecmis bos.' -ForegroundColor DarkGray; return }

    # Sadece komut satirlarini al (# ile baslayan timestamp satirlarini atla)
    $cmds = $lines | Where-Object { $_ -and -not $_.StartsWith('#') }
    $total = $cmds.Count

    # Kök komut frekans sayimi
    $freq = @{}
    foreach ($c in $cmds) {
        $root = ($c.Trim() -split '\s+')[0].ToLower()
        if ($root) { $freq[$root] = ($freq[$root] ?? 0) + 1 }
    }

    # Tam komut frekans (ilk 60 karakter)
    $fullFreq = @{}
    foreach ($c in $cmds) {
        $key = $c.Trim()
        if ($key.Length -gt 60) { $key = $key.Substring(0, 60) + '…' }
        if ($key) { $fullFreq[$key] = ($fullFreq[$key] ?? 0) + 1 }
    }

    $top10root = $freq.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
    $top10full = $fullFreq.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
    $maxCount  = ($top10root | Measure-Object Value -Maximum).Maximum
    $barWidth  = 20

    $line = '─' * 62

    Write-Host ''
    Write-Host "`e[38;5;141m◆ systemcmd istatistikleri`e[0m"
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host "  `e[38;5;245mToplam kayitli komut:`e[0m `e[38;5;117m$total`e[0m"
    Write-Host ''

    # Favori dosyasi
    $favPath = $env:SYSTEMCMD_HISTORY_FAVORITES_PATH
    if (-not $favPath) { $favPath = Join-Path $HOME '.systemcmd-history-favorites.json' }
    if (Test-Path $favPath) {
        try {
            $favs = (Get-Content $favPath | ConvertFrom-Json).Count
            Write-Host "  `e[38;5;245mFavori komut:`e[0m `e[38;5;214m$favs`e[0m"
        } catch {}
    }

    Write-Host ''
    Write-Host "  `e[38;5;214m★ En cok kullanilan araclar`e[0m"
    Write-Host "  `e[38;5;244m$('─' * 50)`e[0m"

    foreach ($entry in $top10root) {
        $pct    = if ($maxCount -gt 0) { [int]($barWidth * $entry.Value / $maxCount) } else { 0 }
        $empty  = $barWidth - $pct
        $bar    = "`e[38;5;85m$('█' * $pct)`e[38;5;236m$('░' * $empty)`e[0m"
        $cmd    = $entry.Key.PadRight(18)
        $cnt    = "$($entry.Value)".PadLeft(5)
        Write-Host "  `e[38;5;117m$cmd`e[0m $bar `e[38;5;244m$cnt`e[0m"
    }

    Write-Host ''
    Write-Host "  `e[38;5;117m✦ En cok tekrarlanan komutlar`e[0m"
    Write-Host "  `e[38;5;244m$('─' * 50)`e[0m"

    $i = 1
    foreach ($entry in $top10full) {
        $num = "$i.".PadLeft(3)
        $cnt = "($($entry.Value)x)"
        Write-Host "  `e[38;5;244m$num`e[0m `e[38;5;245m$($entry.Key)`e[0m `e[38;5;244m$cnt`e[0m"
        $i++
    }

    # Frecency istatistigi
    $frecPath = Join-Path $HOME '.systemcmd' 'frecency.json'
    if (Test-Path $frecPath) {
        try {
            $frec     = Get-Content $frecPath | ConvertFrom-Json -AsHashtable
            $topDirs  = $frec.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5
            Write-Host ''
            Write-Host "  `e[38;5;214m▣ En cok ziyaret edilen klasorler (z)`e[0m"
            Write-Host "  `e[38;5;244m$('─' * 50)`e[0m"
            foreach ($d in $topDirs) {
                $short = $d.Key -replace [regex]::Escape($HOME), '~'
                $short = $short -replace '\\', '/'
                Write-Host "  `e[38;5;117m$($d.Value.ToString().PadLeft(4))x`e[0m `e[38;5;245m$short`e[0m"
            }
        } catch {}
    }

    Write-Host ''
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host ''
}
