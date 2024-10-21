function Pil {
    $battery = Get-WmiObject -Class Win32_Battery
    $batteryStatus = switch ($battery.BatteryStatus) {
        1 {"Boşalıyor"}
        2 {"Bağlı, şarj oluyor"}
        3 {"Tam şarjlı"}
        4 {"Düşük"}
        5 {"Kritik"}
        6 {"Şarj oluyor"}
        7 {"Şarj etme"}
        8 {"Kısmen şarjlı"}
        Default {"Bilinmiyor"}
    }

    $batteryPercent = $battery.EstimatedChargeRemaining
    $batteryLifeRemaining = $battery.EstimatedRunTime

    # Kalan Süre Dönüşümü
    function Convert-Time {
        param([int]$TotalMinutes)
        $TimeSpan = New-TimeSpan -Minutes $TotalMinutes

        $years = [math]::Floor($TimeSpan.TotalDays / 365)
        $months = [math]::Floor(($TimeSpan.TotalDays % 365) / 30)
        $weeks = [math]::Floor(($TimeSpan.TotalDays % 30) / 7)
        $days = [math]::Floor($TimeSpan.TotalDays % 7)
        $hours = $TimeSpan.Hours
        $minutes = $TimeSpan.Minutes
        $seconds = $TimeSpan.Seconds

        $output = ""
        if ($years -gt 0) { $output += "$years yıl " }
        if ($months -gt 0) { $output += "$months ay " }
        if ($weeks -gt 0) { $output += "$weeks hafta " }
        if ($days -gt 0) { $output += "$days gün " }
        if ($hours -gt 0) { $output += "$hours saat " }
        if ($minutes -gt 0) { $output += "$minutes dakika " }
        if ($seconds -gt 0) { $output += "$seconds saniye" }

        return $output.Trim()
    }

    $formattedTime = Convert-Time -TotalMinutes $batteryLifeRemaining

    Write-Host "Pil Yüzdesi: $batteryPercent%" -ForegroundColor Yellow
    Write-Host "Kalan Süre: $formattedTime" -ForegroundColor Green
    Write-Host "Pil Durumu: $batteryStatus" -ForegroundColor Cyan
}


function ip {
    param(
        [switch]$SadeceIcIP,
        [switch]$SadeceDisIP
    )

    if (-not $SadeceDisIP) {
        $icIP = Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" }

        Write-Host "İç IP Bilgileri:"
        foreach ($ip in $icIP) {
            Write-Host "Arayüz: $($ip.InterfaceAlias)" -ForegroundColor Cyan
            Write-Host "IP Adresi: $($ip.IPAddress)" -ForegroundColor Yellow
        }
    }

    if (-not $SadeceIcIP) {
        try {
            $disIP = Invoke-RestMethod http://httpbin.org/ip
            Write-Host "┌─────────────────── Dış IP ────────────────────┐" -ForegroundColor Cyan
            Write-Host "                $($disIP.origin)" -ForegroundColor Red
            Write-Host "└───────────────────────────────────────────────┘" -ForegroundColor Cyan

        } catch {
            Write-Host "Dış IP adresi alınamadı." -ForegroundColor Red
        }
    }
}