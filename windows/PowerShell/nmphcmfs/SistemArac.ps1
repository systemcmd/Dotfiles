function sistemarac {
    chcp 65001 | Out-Null
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf bulunamadı. Lütfen fzf'yi yükleyin." -ForegroundColor Red
        return
    }

    $Ω = @("Sistem Araçları Ekle", "Sistem Araçları Kaldır")
    $ℵ = ($Ω | fzf --prompt "Lütfen bir seçenek seçin: " | Out-String).Trim()
    Write-Host "Seçilen: $ℵ"

    function qX {
        param(
            [string]$content,
            [string]$filename
        )
        $path = Join-Path $env:TEMP $filename
        $content | Out-File -Encoding Unicode -FilePath $path
        Start-Process reg.exe -ArgumentList "import `"$path`"" -Verb RunAs -Wait
        Remove-Item $path -Force
    }

    function fE {
@'
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemTolls]
"MUIVerb"="Sistem araçları"
"SubCommands"="Computer;ControlPanel;CMD;Devices;appwiz.cpl;DiskCleanup;DiskDefragmenter;Regedit;MSCONFIG;Notepad;services.msc;UserAccountControlSettings;PowerOptions;SystemInformation;SystemRestore"
"icon"="SystemSettingsAdminFlows.exe"
"Position"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Computer]
@="Bu Bilgisayar"
"icon"="imageres.dll,-109"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Computer\command]
@="explorer.exe /e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ControlPanel]
@="Denetim Masası"
"icon"="control.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ControlPanel\command]
@="control.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskCleanup]
@="Disk Temizliği"
"icon"="cleanmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskCleanup\command]
@="cleanmgr.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskDefragmenter]
@="Disk Birleştirme"
"icon"="dfrgui.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskDefragmenter\command]
@="dfrgui.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services.msc]
@="Hizmetler"
"icon"="MMC.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services.msc\command]
@="MMC.exe services.msc"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\UserAccountControlSettings]
@="Kullanıcı Hesap Denetimi"
"icon"="UserAccountControlSettings.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\UserAccountControlSettings\command]
@="UserAccountControlSettings.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad]
@="Not Defteri"
"icon"="notepad.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad\command]
@="notepad.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd]
@="Komut İstemi"
"Icon"="CMD.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd\command]
@="cmd.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Regedit]
@="Kayıt Defteri"
"Icon"="regedit.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Regedit\command]
@="%SYSTEMROOT%\\regedit.exe"
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,72,00,65,00,67,00,65,00,64,00,69,00,74,00,2e,00,65,00,78,00,65,00,\
  00,00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig]
@="Başlangıç Yönetimi"
"Icon"="msconfig.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig\command]
@="msconfig.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Devices]
"Icon"="DeviceProperties.exe"
@="Aygıt Yöneticisi"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Devices\command]
@=hex(2):25,00,77,00,69,00,6e,00,64,00,69,00,72,00,25,00,5c,00,73,00,79,00,73,\
  00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,6d,00,63,00,2e,00,65,00,78,00,\
  65,00,20,00,2f,00,73,00,20,00,25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,\
  00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,\
  32,00,5c,00,64,00,65,00,76,00,6d,00,67,00,6d,00,74,00,2e,00,6d,00,73,00,63,\
  00,20,00,2f,00,73,00,00,00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemInformation]
@="Sistem Bilgisi"
"icon"="msinfo32.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemInformation\command]
@="msinfo32.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemRestore]
@="Sistem Geri Yükleme"
"icon"="rstrui.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemRestore\command]
@="rstrui.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\PowerOptions]
@="Güç Seçenekleri"
"Icon"="powercpl.dll,0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\PowerOptions\command]
@="control /name Microsoft.PowerOptions"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz.cpl]
@="Program Ekle Kaldır"
"Icon"="explorer.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz.cpl\command]
@="control.exe appwiz.cpl"
'@
    }

    function fK {
@'
Windows Registry Editor Version 5.00

[-HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemTolls]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Computer]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ControlPanel]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskCleanup]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\DiskDefragmenter]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services.msc]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\UserAccountControlSettings]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Regedit]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Devices]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemInformation]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SystemRestore]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\PowerOptions]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz.cpl]
'@
    }

    if ($ℵ -like "*Ekle*") {
        $content = fE
        qX $content "SistemAraclariEkle.reg"
        Write-Host "Sistem araçları başarıyla eklendi." -ForegroundColor Green
    }
    elseif ($ℵ -like "*Kaldır*") {
        $content = fK
        qX $content "SistemAraclariKaldir.reg"
        Write-Host "Sistem araçları başarıyla kaldırıldı." -ForegroundColor Green
    }
    else {
        Write-Host "Bilinmeyen seçim: $ℵ"
    }
}
