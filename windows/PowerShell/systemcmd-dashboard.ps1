function New-SystemCmdProgressBar {
    param([int]$Value, [int]$Max = 100, [int]$Width = 18)
    $pct    = if ($Max -gt 0) { [math]::Min(100, [int](100 * $Value / $Max)) } else { 0 }
    $filled = [int]($Width * $pct / 100)
    $empty  = $Width - $filled
    $color  = if ($pct -lt 60) { 85 } elseif ($pct -lt 85) { 214 } else { 167 }
    $bar    = "`e[38;5;${color}m$('█' * $filled)`e[38;5;236m$('░' * $empty)`e[0m"
    return "$bar `e[38;5;245m${pct}%`e[0m"
}

function Get-SystemCmdDashData {
    $d = @{ cpu = $null; ramUsed = $null; ramTotal = $null; gpuLoad = $null; gpuVramUsed = $null; gpuVramTotal = $null;
            diskFree = $null; diskTotal = $null; battPct = $null; battCharging = $null;
            netUp = $null; netDown = $null; topProcs = @() }

    if (-not $script:SystemCmdIsWindows) { return $d }

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $d.ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $d.ramUsed  = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
    } catch {}

    try {
        $proc = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $d.cpu = $proc.LoadPercentage
    } catch {}

    try {
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $d.diskTotal = [math]::Round($disk.Size / 1GB, 0)
        $d.diskFree  = [math]::Round($disk.FreeSpace / 1GB, 1)
    } catch {}

    try {
        $batt = Get-CimInstance Win32_Battery -ErrorAction Stop | Select-Object -First 1
        if ($batt) {
            $d.battPct      = $batt.EstimatedChargeRemaining
            $d.battCharging = $batt.BatteryStatus -eq 2
        }
    } catch {}

    try {
        $d.topProcs = Get-Process -ErrorAction Stop |
            Sort-Object CPU -Descending |
            Select-Object -First 5 |
            ForEach-Object { @{ Name = $_.Name.Substring(0, [math]::Min(14, $_.Name.Length)); CPU = [math]::Round($_.CPU ?? 0, 1); RAM = [math]::Round($_.WorkingSet64 / 1MB, 0) } }
    } catch {}

    # GPU — nvidia-smi varsa
    try {
        if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
            $nv = & nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>$null
            if ($nv) {
                $parts = $nv -split ','
                $d.gpuLoad      = [int]$parts[0].Trim()
                $d.gpuVramUsed  = [math]::Round([int]$parts[1].Trim() / 1024, 1)
                $d.gpuVramTotal = [math]::Round([int]$parts[2].Trim() / 1024, 1)
            }
        }
    } catch {}

    return $d
}

function Invoke-SystemCmdDashboard {
    if (-not $script:SystemCmdIsWindows) {
        Write-Host 'Dashboard su an sadece Windows destekliyor.' -ForegroundColor Yellow
        return
    }

    $refreshMs = 2000
    try {
        $cfg = Get-SystemCmdConfig
        if ($cfg.dashboard.refreshMs) { $refreshMs = $cfg.dashboard.refreshMs }
    } catch {}

    # Alternatif ekran
    [Console]::Write("`e[?1049h`e[?25l")

    $prevData = $null

    try {
        while ($true) {
            $w    = [Console]::WindowWidth
            $data = Get-SystemCmdDashData

            [Console]::SetCursorPosition(0, 0)

            $title  = ' ◆ SYSTEMCMD DASHBOARD '
            $border = '═' * [math]::Max(0, ($w - $title.Length) / 2)
            Write-Host "`e[38;5;141m$border$title$border`e[0m"
            Write-Host ''

            # CPU
            $cpuBar = if ($null -ne $data.cpu) { New-SystemCmdProgressBar -Value $data.cpu } else { "`e[38;5;244m─`e[0m" }
            Write-Host "  `e[38;5;214m⚡ CPU   `e[0m $cpuBar"

            # RAM
            if ($null -ne $data.ramUsed) {
                $ramBar = New-SystemCmdProgressBar -Value $data.ramUsed -Max $data.ramTotal -Width 18
                Write-Host "  `e[38;5;141m🧠 RAM   `e[0m $ramBar  `e[38;5;244m$($data.ramUsed)/$($data.ramTotal)GB`e[0m"
            }

            # GPU
            if ($null -ne $data.gpuLoad) {
                $gpuBar = New-SystemCmdProgressBar -Value $data.gpuLoad
                Write-Host "  `e[38;5;45m🎮 GPU   `e[0m $gpuBar  `e[38;5;244m$($data.gpuVramUsed)/$($data.gpuVramTotal)GB VRAM`e[0m"
            }

            # Disk
            if ($null -ne $data.diskFree) {
                $diskUsed = $data.diskTotal - $data.diskFree
                $diskBar  = New-SystemCmdProgressBar -Value $diskUsed -Max $data.diskTotal
                Write-Host "  `e[38;5;214m💾 DISK  `e[0m $diskBar  `e[38;5;244m$($data.diskFree)GB bos / $($data.diskTotal)GB`e[0m"
            }

            # Batarya
            if ($null -ne $data.battPct) {
                $battBar    = New-SystemCmdProgressBar -Value $data.battPct
                $chargeTxt  = if ($data.battCharging) { "`e[38;5;85m sarj oluyor`e[0m" } else { '' }
                Write-Host "  `e[38;5;82m🔋 PIL   `e[0m $battBar$chargeTxt"
            }

            Write-Host ''
            Write-Host "  `e[38;5;244m$('─' * [math]::Max(0,$w-4))`e[0m"
            Write-Host ''

            # Top prosesler
            if ($data.topProcs.Count -gt 0) {
                Write-Host "  `e[38;5;117m✦ TOP PROSESLER`e[0m"
                foreach ($p in $data.topProcs) {
                    $name = $p.Name.PadRight(16)
                    $cpu  = "$($p.CPU)s".PadLeft(8)
                    $ram  = "$($p.RAM)MB".PadLeft(8)
                    Write-Host "    `e[38;5;245m$name`e[0m `e[38;5;214m$cpu CPU`e[0m `e[38;5;141m$ram RAM`e[0m"
                }
                Write-Host ''
            }

            # Son komutlar
            try {
                $histPath = (Get-PSReadLineOption).HistorySavePath
                if (Test-Path $histPath) {
                    $recentCmds = Get-Content $histPath -Tail 20 |
                        Where-Object { $_ -and -not $_.StartsWith('#') } |
                        Select-Object -Last 5
                    if ($recentCmds) {
                        Write-Host "  `e[38;5;214m◆ SON KOMUTLAR`e[0m"
                        foreach ($cmd in $recentCmds) {
                            $short = if ($cmd.Length -gt $w-8) { $cmd.Substring(0,$w-11) + '…' } else { $cmd }
                            Write-Host "    `e[38;5;244m$short`e[0m"
                        }
                        Write-Host ''
                    }
                }
            } catch {}

            Write-Host "  `e[38;5;244m$('─' * [math]::Max(0,$w-4))`e[0m"
            Write-Host "  `e[38;5;244mQ: cik   R: hemen yenile   ${refreshMs}ms araliklarla guncelleniyor`e[0m"

            # Klavye girisi bekle (non-blocking)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            while ($sw.ElapsedMilliseconds -lt $refreshMs) {
                if ([Console]::KeyAvailable) {
                    $key = [Console]::ReadKey($true)
                    if ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q' -or $key.Key -eq 'Escape') { return }
                    if ($key.KeyChar -eq 'r' -or $key.KeyChar -eq 'R') { break }
                }
                Start-Sleep -Milliseconds 100
            }
        }
    } finally {
        # Ekranı geri yükle
        [Console]::Write("`e[?1049l`e[?25h")
    }
}
