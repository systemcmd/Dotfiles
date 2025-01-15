function Invoke-DockerToolkit {
    $dockerCommands = @(
        @{ Name = "docker ps"; Description = "Çalışan konteynerleri listele"; Details = "Bu komut, sistemde çalışan tüm konteynerlerin bir listesini gösterir."; Usage = "Kullanım Alanı: Konteynerlerin durumunu görmek için kullanılır.`n`nÖrnek Komut: docker ps -a`n`nAçıklama: Tüm konteynerleri (çalışan ve durdurulmuş) listelemek için `-a` bayrağını ekleyin." },
        @{ Name = "docker images"; Description = "Mevcut Docker imajlarını listele"; Details = "Bu komut, sistemde mevcut olan tüm Docker imajlarını listeler."; Usage = "Kullanım Alanı: İmajların detaylarını ve boyutlarını öğrenmek için kullanılır.`n`nÖrnek Komut: docker images`n`nAçıklama: REPOSITORY, TAG, IMAGE ID gibi bilgiler gösterilir." },
        @{ Name = "docker run"; Description = "Yeni bir konteyner başlat"; Details = "Bir Docker imajından yeni bir konteyner başlatır."; Usage = "Kullanım Alanı: Bir uygulamayı başlatmak için kullanılır.`n`nÖrnek Komut: docker run -it ubuntu`n`nAçıklama: `-it` bayrağı interaktif terminal başlatmak içindir.`n`nEk Örnek: docker run -d -p 8080:80 nginx`n`nAçıklama: `-d` ile arka planda çalıştırılır, `-p` ile port yönlendirilir." },
        @{ Name = "docker pull"; Description = "Docker Hub'dan imaj indir"; Details = "Bir Docker imajını Docker Hub'dan indirir."; Usage = "Kullanım Alanı: Docker Hub'dan yeni bir imaj indirmek için kullanılır.`n`nÖrnek Komut: docker pull nginx`n`nAçıklama: `n`nginx` imajının en son sürümünü indirir. Belirli bir sürüm için: docker pull nginx:1.19" },
        @{ Name = "docker build"; Description = "Docker imajı oluştur"; Details = "Bir Dockerfile'dan yeni bir Docker imajı oluşturur."; Usage = "Kullanım Alanı: Kendi uygulamalarınızı paketlemek için kullanılır.`n`nÖrnek Komut: docker build -t myapp .`n`nAçıklama: `-t` ile imaj adı belirlenir. Nokta (`.`) Dockerfile'ın bulunduğu dizini ifade eder." },
        @{ Name = "docker exec"; Description = "Çalışan konteynerde komut çalıştır"; Details = "Bir konteyner içinde belirtilen komutu çalıştırır."; Usage = "Kullanım Alanı: Çalışan bir konteyner içinde komut çalıştırmak için kullanılır.`n`nÖrnek Komut: docker exec -it mycontainer bash`n`nAçıklama: `mycontainer` içinde bir terminal başlatır." },
        @{ Name = "docker stop"; Description = "Bir konteyneri durdur"; Details = "Belirtilen bir konteyneri durdurur."; Usage = "Kullanım Alanı: Konteynerin çalışmasını durdurmak için kullanılır.`n`nÖrnek Komut: docker stop mycontainer`n`nAçıklama: `mycontainer` isimli konteyneri durdurur." },
        @{ Name = "docker rm"; Description = "Konteyneri sil"; Details = "Durdurulmuş bir konteyneri sistemden siler."; Usage = "Kullanım Alanı: Artık kullanılmayan konteynerleri temizlemek için kullanılır.`n`nÖrnek Komut: docker rm mycontainer`n`nEk Örnek: Birden fazla konteyneri silmek için: docker rm mycontainer1 mycontainer2" },
        @{ Name = "docker rmi"; Description = "Docker imajını sil"; Details = "Sistemdeki bir Docker imajını siler."; Usage = "Kullanım Alanı: Gereksiz Docker imajlarını temizlemek için kullanılır.`n`nÖrnek Komut: docker rmi myimage`n`nEk Örnek: Birden fazla imaj silmek için: docker rmi image1 image2" },
        @{ Name = "docker logs"; Description = "Konteyner loglarını göster"; Details = "Bir konteynerin çalışma loglarını görüntüler."; Usage = "Kullanım Alanı: Hata ayıklamak için kullanılır.`n`nÖrnek Komut: docker logs mycontainer`n`nEk Açıklama: `-f` bayrağı ile canlı log takibi yapılabilir." },
        @{ Name = "docker network"; Description = "Ağ yönetimi"; Details = "Docker ağlarını listelemek ve yönetmek için kullanılır."; Usage = "Kullanım Alanı: Docker konteynerleri arasındaki ağ bağlantılarını yönetmek için kullanılır.`n`nÖrnek Komut: docker network ls`n`nAçıklama: Docker'da tanımlı ağları listeler." },
        @{ Name = "docker volume"; Description = "Hacim yönetimi"; Details = "Docker hacimlerini listelemek ve yönetmek için kullanılır."; Usage = "Kullanım Alanı: Konteynerlerin veri paylaşımı için kullanılan hacimleri yönetmek için kullanılır.`n`nÖrnek Komut: docker volume ls`n`nAçıklama: Tüm Docker hacimlerini listeler." },
        @{ Name = "docker stats"; Description = "Konteyner kaynak kullanımını göster"; Details = "Çalışan konteynerlerin CPU, bellek, ağ ve disk kullanımını gerçek zamanlı olarak izler."; Usage = "Kullanım Alanı: Konteynerlerin kaynak kullanımını izlemek için kullanılır.`n`nÖrnek Komut: docker stats`n`nAçıklama: Çalışan tüm konteynerlerin kaynak kullanımlarını gösterir." },
        @{ Name = "docker inspect"; Description = "Konteyner veya imaj hakkında detaylı bilgi"; Details = "Belirtilen bir konteyner veya imaj hakkında JSON formatında detaylı bilgi verir."; Usage = "Kullanım Alanı: Konteyner veya imaj özelliklerini görmek için kullanılır.`n`nÖrnek Komut: docker inspect mycontainer`n`nAçıklama: İmaj ID, network ayarları gibi bilgileri gösterir." },
        @{ Name = "docker-compose"; Description = "Çoklu konteyner uygulamalarını yönet"; Details = "Docker Compose, birden fazla konteyneri tanımlamak ve yönetmek için kullanılır."; Usage = "Kullanım Alanı: Kompleks uygulamaları başlatmak için kullanılır.`n`nÖrnek Komut: docker-compose up -d`n`nAçıklama: Belirtilen `docker-compose.yml` dosyasına göre konteynerleri başlatır." },
        @{ Name = "docker cp"; Description = "Dosya kopyala"; Details = "Host sistem ile konteyner arasında dosya kopyalamak için kullanılır."; Usage = "Kullanım Alanı: Dosyaları taşıma ve yedekleme için kullanılır.`n`nÖrnek Komut: docker cp hostfile.txt mycontainer:/path/`n`nAçıklama: Host sistemdeki `hostfile.txt` dosyasını konteynere kopyalar." },
        @{ Name = "docker prune"; Description = "Temizlik yap"; Details = "Kullanılmayan veri ve konteynerleri temizler."; Usage = "Kullanım Alanı: Sistemde yer açmak ve gereksiz verileri kaldırmak için kullanılır.`n`nÖrnek Komut: docker system prune -a`n`nAçıklama: Tüm kullanılmayan konteyner, ağ ve imajları temizler." },
        @{ Name = "docker save"; Description = "İmajı dosyaya kaydet"; Details = "Bir Docker imajını bir dosyaya kaydeder."; Usage = "Kullanım Alanı: İmaj yedekleme ve paylaşım için kullanılır.`n`nÖrnek Komut: docker save -o myimage.tar myimage`n`nAçıklama: `myimage` adlı Docker imajını `myimage.tar` dosyasına kaydeder." }
    )

    # Menü için renkli giriş hazırlığı
    $fzfInput = $dockerCommands | ForEach-Object {
        "$([char]27)[38;5;57m$($_.Name)$([char]27)[0m`t$([char]27)[38;5;244m⯈ $($_.Description)$([char]27)[0m"
    } | Out-String

    $fzfOutputFile = [System.IO.Path]::GetTempFileName()

    $fzfInput | fzf --height 70% --layout=reverse --border --ansi --color=fg:#FFD700,bg:#1C1C1C,hl:#5F00AF --color=fg+:#FFD700,bg+:#262626,hl+:#7FFF00 --color=info:#00FF00,prompt:#00FF00,pointer:#FF0000,marker:#FF69B4,spinner:#00FF00,header:#00FF00 > $fzfOutputFile

    $selected = Get-Content -Path $fzfOutputFile

    if ($selected) {
        $selectedItem = $dockerCommands | Where-Object { $_.Name -eq ($selected -split "`t")[0] }
        $selectedCommand = $selectedItem.Name
        $selectedDescription = $selectedItem.Description
        Clear-Host
        $prompt = " > "
        Write-Host "$prompt$selectedCommand   >  $selectedDescription" -ForegroundColor Red
        Write-Host "=========================================" -ForegroundColor Green
        Write-Host "Detaylı Bilgi:" -ForegroundColor Cyan
        Write-Host $selectedItem.Details -ForegroundColor White
        Write-Host "-----------------------------------------" -ForegroundColor Yellow
        Write-Host "Kullanım Alanı:" -ForegroundColor Magenta
        Write-Host $selectedItem.Usage -ForegroundColor White
        Write-Host "=========================================" -ForegroundColor Green
    }

    Remove-Item -Path $fzfOutputFile
}

# Alias Oluşturma
New-Alias -Name 'dockerhelp' -Value 'Invoke-DockerToolkit'
