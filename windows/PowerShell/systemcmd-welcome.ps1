# ── Karşılama ekranı ──────────────────────────────────────────────────────────
function Show-SystemCmdWelcome {
    if ($env:SYSTEMCMD_WELCOME_SHOWN) {
        return
    }

    try {
        if (Get-Command -Name Get-SystemCmdConfig -ErrorAction SilentlyContinue) {
            $cfg = Get-SystemCmdConfig
            if ($cfg.welcome.enabled -eq $false) {
                return
            }
        }
    } catch {}

    Write-Host ''

    # ── Bilgi satırı ─────────────────────────────────────────────────────────
    $psVersion = $PSVersionTable.PSVersion.ToString()
    $osPart    = if ($script:SystemCmdIsWindows) { 'Windows' } else { 'Linux' }

    Write-Host "  `e[38;5;117m$env:USERNAME`e[38;5;244m @ $env:COMPUTERNAME`e[0m  `e[38;5;244mPS $psVersion  |  $osPart`e[0m"

    # ── RAM ve Disk (CPU/BAT gösterilmez) ────────────────────────────────────
    if ($script:SystemCmdIsWindows) {
        $hwParts = [System.Collections.Generic.List[string]]::new()

        try {
            $os      = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
            $usedGB  = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
            $hwParts.Add("`e[38;5;244mRAM`e[0m `e[38;5;51m${usedGB}/${totalGB}GB`e[0m")
        } catch {}

        try {
            $disk   = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
            $freeD  = [math]::Round($disk.FreeSpace / 1GB, 1)
            $totalD = [math]::Round($disk.Size      / 1GB, 0)
            $hwParts.Add("`e[38;5;244mDISK`e[0m `e[38;5;45m${freeD}/${totalD}GB`e[0m")
        } catch {}

        if ($hwParts.Count -gt 0) {
            Write-Host ('  ' + ($hwParts -join '  '))
        }
    }

    Write-Host ''
    $env:SYSTEMCMD_WELCOME_SHOWN = '1'
}
