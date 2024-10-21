function Ram {
    # Bilgisayar bilgilerini al
    $bilgisayarBilgisi = Get-ComputerInfo
    $toplamBellekGB = [math]::Round($bilgisayarBilgisi.CsTotalPhysicalMemory / 1GB, 2)

    # Boş bellek bilgisini al ve GB cinsinden hesapla
    $bosBellekMB = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory
    $bosBellekGB = [math]::Round($bosBellekMB / 1MB, 2)

    # Kullanılan belleği hesapla
    $kullanilanBellekGB = $toplamBellekGB - $bosBellekGB

    Write-Host "┌─────────────────── RAM Bilgileri ────────────────────┐" -ForegroundColor Cyan
    Write-Host "│ Toplam Bellek: $toplamBellekGB GB                       " -ForegroundColor Yellow
    Write-Host "│ Kullanılan Bellek: $kullanilanBellekGB GB               " -ForegroundColor Red
    Write-Host "│ Boş Bellek: $bosBellekGB GB                           " -ForegroundColor Gray
    Write-Host "└───────────────────────────────────────────────────────┘" -ForegroundColor Cyan

    # En çok RAM kullanan 5 programı listele
    $topProgramsRam = Get-Process | Where-Object { $_.WS -ne $null -and $_.WS -gt 0 } | Sort-Object WS -Descending | Select-Object -First 5

    Write-Host "┌───────────── En Çok RAM Kullanan 5 Program ─────────────┐" -ForegroundColor Cyan
    foreach ($program in $topProgramsRam) {
        $programRamGB = [math]::Round($program.WS / 1GB, 2)
        $programPercentage = ($programRamGB / $toplamBellekGB) * 100
        Write-Host "│ $($program.Name): $($programRamGB) GB " -NoNewline -ForegroundColor Yellow
        Write-Host (" (%{0:N2}) " -f $programPercentage) -ForegroundColor Red
    }
    Write-Host "└───────────────────────────────────────────────────────┘" -ForegroundColor Cyan
}

function CPU {
    # Systeminfo komutu ile doğru sistem başlatma zamanını al
    $systemInfo = systeminfo | Select-String "System Boot Time"
    $bootTimeStr = $systemInfo.ToString().Split(":", 2)[1].Trim()

    # Türkiye tarih formatına göre tarih ve saat bilgisini parse et
    try {
        $lastBootTime = [datetime]::ParseExact($bootTimeStr, "dd.MM.yyyy, HH:mm:ss", [Globalization.CultureInfo]::GetCultureInfo("tr-TR"))
    } catch {
        Write-Host "Tarih formatı yanlış. Lütfen formatı kontrol edin: '$bootTimeStr'" -ForegroundColor Red
        return
    }
    
    $uptime = (Get-Date) - $lastBootTime
    $uptimeString = "{0} gün, {1} saat, {2} dakika" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

    # CPU kullanım yüzdesini al
    $cpuLoad = (Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average).Average

    # Toplam çekirdek sayısını al
    $coreCount = (Get-WmiObject Win32_Processor).NumberOfCores

    Write-Host "┌─────────────────── CPU Bilgileri ────────────────────┐" -ForegroundColor Gray
    Write-Host "│ CPU Kullanımı: $cpuLoad%                              " -ForegroundColor Green
    Write-Host "│ CPU Çalışma Süresi: $uptimeString                     " -ForegroundColor Green
    Write-Host "│ Toplam Çekirdek Sayısı: $coreCount                    " -ForegroundColor Green
    Write-Host "└───────────────────────────────────────────────────────┘" -ForegroundColor Gray

    # En çok CPU kullanan 10 programı listele
    $totalCpuTime = (Get-Process | Measure-Object -Property CPU -Sum).Sum
    $topPrograms = Get-Process | Where-Object { $_.CPU -ne $null -and $_.CPU -gt 0 } | Sort-Object CPU -Descending | Select-Object -First 10

    Write-Host "┌───────────── En Çok CPU Kullanan 10 Program ─────────────┐" -ForegroundColor Cyan
    foreach ($program in $topPrograms) {
        $programPercentage = ($program.CPU / $totalCpuTime) * 100
        Write-Host "│= $($program.Name): $($program.CPU) saniye" -NoNewline -ForegroundColor Yellow
        Write-Host (" (%{0:N2}) " -f $programPercentage) -ForegroundColor Red
    }
    Write-Host "└───────────────────────────────────────────────────────┘" -ForegroundColor Cyan
}

function GPU {
    [xml]$smiOutput = & 'nvidia-smi' -q -x

    foreach ($gpu in $smiOutput.nvidia_smi_log.gpu) {
        Write-Host "┌───────────────── GPU: $($gpu.product_name) ─────────────────┐" -ForegroundColor Cyan
        Write-Host "│ İsim: $($gpu.product_name)" -ForegroundColor Yellow
        Write-Host "│ Toplam RAM (MiB): $($gpu.fb_memory_usage.total)" -ForegroundColor Green

        # Kullanılan ve boş RAM miktarını temizle
        $usedRam = [int]($gpu.fb_memory_usage.used -replace "[^\d]")
        $freeRam = [int]($gpu.fb_memory_usage.free -replace "[^\d]")
        $totalRam = [int]($gpu.fb_memory_usage.total -replace "[^\d]")

        Write-Host "│ Kullanılan RAM (MiB): $usedRam" -ForegroundColor Red
        Write-Host "│ Boş RAM (MiB): $freeRam" -ForegroundColor Gray

        # Kullanım ve bellek oranı hesaplamaları
        $usagePercent = [math]::Round(($gpu.utilization.gpu_util -replace "[^\d]").Trim() / 100, 2)
        $memoryPercent = [math]::Round($usedRam / $totalRam * 100, 2)
        Write-Host "│ GPU Kullanım Oranı (%): $usagePercent" -ForegroundColor Magenta
        Write-Host "│ Bellek Kullanım Oranı (%): $memoryPercent" -ForegroundColor Magenta

        # Hata durumu ve çözüm önerileri
        $errorStatus = $gpu.ecc_errors.outerxml -replace "<[^>]+>", "" # XML elementlerini temizle
        if ($errorStatus -eq "N/A" -or $errorStatus -eq "") {
            $errorStatus = "Belirsiz"
        }
        Write-Host "│ Hata Durumu: $errorStatus" -ForegroundColor Red

        if ($errorStatus -like "*error*") {
            Write-Host "│ Önerilen Çözüm: GPU sürücülerini güncelleyin ve sistem günlüklerini kontrol edin." -ForegroundColor Green
        } elseif ($errorStatus -like "*warning*") {
            Write-Host "│ Önerilen Çözüm: Sistemi yeniden başlatın ve durumu izleyin." -ForegroundColor Green
        } else {
            Write-Host "│ Önerilen Çözüm: Herhangi bir hata tespit edilmedi." -ForegroundColor Green
        }

        Write-Host "└───────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    }
}



function Disk {
    $volumeBilgileri = Get-Volume | Where-Object { $_.DriveType -eq "Fixed" }

    $volumeBilgileri | ForEach-Object {
        $driveLetter = $_.DriveLetter
        $bosAlan_GB = [math]::Round($_.SizeRemaining / 1GB, 2)
        $toplamAlan_GB = [math]::Round($_.Size / 1GB, 2)
        $kullanilanAlan_GB = $toplamAlan_GB - $bosAlan_GB
        $kullanilanYuzde = [math]::Round(($kullanilanAlan_GB / $toplamAlan_GB) * 100, 0)

        # Disk harfine göre fiziksel disk bilgisini al
        $physicalDisk = Get-PhysicalDisk | Where-Object { $_.ObjectId -match ".*$driveLetter.*" }
        $diskAdi = $physicalDisk.FriendlyName

        Write-Host "Disk Harfi: $driveLetter" -ForegroundColor Magenta
        Write-Host "Disk Adi: $diskAdi" -ForegroundColor Cyan
        Write-Host "Toplam Alan: " -NoNewline
        Write-Host "$toplamAlan_GB GB" -ForegroundColor Blue
        Write-Host "Kullanilan Alan: " -NoNewline
        Write-Host "$kullanilanAlan_GB GB" -ForegroundColor Red
        Write-Host "Bos Alan: " -NoNewline
        Write-Host "$bosAlan_GB GB" -ForegroundColor Gray

        # Basit bir progress bar gösterimi ve dolu/boş alan bilgisi
        $dolu = '-' * $kullanilanYuzde
        $bos = ' ' * (100 - $kullanilanYuzde)
        Write-Host "Kullanım: [$dolu$bos] $kullanilanYuzde% Dolu" -ForegroundColor Green
        Write-Host "============" -ForegroundColor Magenta
    }
}