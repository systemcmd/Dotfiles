function bios {
    try {
        $biosInfo = Get-WmiObject Win32_BIOS

        Clear-Host
        Write-Host "===B=i=l=m=e=d==i=k=l=e=r=i=n=d=e============G=i=z=l=i=y=i=m===============" -ForegroundColor Black
        Write-Host "BIOS Bilgileri:" -ForegroundColor Cyan

        Write-Host "Üretici: " -NoNewline
        Write-Host $biosInfo.Manufacturer -ForegroundColor Yellow

        Write-Host "BIOS Sürümü: " -NoNewline
        Write-Host $biosInfo.SMBIOSBIOSVersion -ForegroundColor Yellow

        Write-Host "Açıklama: " -NoNewline
        Write-Host $biosInfo.Description -ForegroundColor Yellow

        switch ($biosInfo.Status) {
            "OK" { $biosDurumu = "İyi" }
            "Degraded" { $biosDurumu = "Düşmüş" }
            "Error" { $biosDurumu = "Hata" }
            default { $biosDurumu = $biosInfo.Status }
        }

        Write-Host "BIOS Durumu: " -NoNewline
        Write-Host $biosDurumu -ForegroundColor Yellow

        # Yayın Tarihini biçimlendir
        $formattedReleaseDate = [Management.ManagementDateTimeConverter]::ToDateTime($biosInfo.ReleaseDate)
        $displayDate = $formattedReleaseDate.ToString("dd/MM/yyyy HH:mm:ss")

        Write-Host "Çıkış Tarihi: " -NoNewline
        Write-Host $displayDate -ForegroundColor Yellow
    }
    catch {
        Write-Host "BIOS bilgileri alınırken bir hata oluştu: $_" -ForegroundColor Red
    }
}


