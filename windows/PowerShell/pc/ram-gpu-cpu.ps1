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
    try {
        # Kullanılabilir ve "Bilgisayarım" kısmında görünen sürücüleri al
        $volumes = Get-Volume | Where-Object { 
            $_.DriveType -eq "Fixed" -and $_.DriveLetter -ne $null -and $_.FileSystemLabel -ne $null 
        }

        if (-not $volumes) {
            Write-Host "Bilgisayarınızda görüntülenebilir bir disk bulunamadı." -ForegroundColor Red
            return
        }

        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "          AKTIF DISK DETAYLARI            " -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Cyan

        $diskCounter = 1

        $volumes | ForEach-Object {
            $driveLetter = $_.DriveLetter
            $totalSpaceGB = [math]::Round($_.Size / 1GB, 2)
            $freeSpaceGB = [math]::Round($_.SizeRemaining / 1GB, 2)
            $usedSpaceGB = $totalSpaceGB - $freeSpaceGB
            $usedPercentage = [math]::Round(($usedSpaceGB / $totalSpaceGB) * 100, 0)
            $volumeLabel = $_.FileSystemLabel

            # Diskin fiziksel bilgilerini al
            $physicalDisk = Get-PhysicalDisk | Where-Object {
                $_.DeviceID -match $_.ObjectId.Split(":")[-1]
            }
            $diskName = $physicalDisk.FriendlyName

            # Kullanım çubuğu
            $barLength = 30
            $filledBars = [math]::Round(($usedPercentage / 100) * $barLength)
            $emptyBars = $barLength - $filledBars
            $usageBar = ("█" * $filledBars) + ("░" * $emptyBars)

            # Bilgileri göster
            Write-Host "`nDisk Adı    : $diskCounter      $diskName" -ForegroundColor Green
            Write-Host "Etiket       : $volumeLabel" -ForegroundColor Cyan
            Write-Host "Disk Harfi   : $driveLetter" -ForegroundColor Yellow
            Write-Host "Toplam Alan  : $totalSpaceGB GB" -ForegroundColor Blue
            Write-Host "Kullanılan   : $usedSpaceGB GB ($usedPercentage%)" -ForegroundColor Red
            Write-Host "Boş Alan     : $freeSpaceGB GB" -ForegroundColor Gray
            Write-Host "Kullanım     : [$usageBar]" -ForegroundColor Yellow
            Write-Host "==========================================" -ForegroundColor Cyan

            # Disk sırasını artır
            $diskCounter++
        }
    } catch {
        Write-Host "Bir hata oluştu: $_" -ForegroundColor Red
    }
}

