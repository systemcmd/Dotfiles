function Invoke-SystemctlToolkit {
 $commands += @(
@{ Name = "systemctl list-units --type=service --state=running"; Description = "Şu anda çalışan hizmetleri listele"; Details = "Sistemde aktif olarak çalışan tüm servisleri listeler."; Usage = "systemctl list-units --type=service --state=running" }
@{ Name = "systemctl --failed"; Description = "Başarısız olmuş hizmetleri listele"; Details = "Hatalı veya çökmüş servisleri listeler."; Usage = "systemctl --failed" },
@{ Name = "systemctl --user"; Description = "Kullanıcı oturumuna ait servisleri yönet"; Details = "Kendi kullanıcı oturumuna ait servislerin yönetimi için kullanılır."; Usage = "systemctl --user" },
@{ Name = "systemctl --user list-units --type=service"; Description = "Kullanıcıya ait çalışan servisleri göster"; Details = "Kullanıcıya ait çalışan sistemd servislerini listeler."; Usage = "systemctl --user list-units --type=service" },
@{ Name = "systemctl list-dependencies graphical.target"; Description = "Grafik hedefine bağlı tüm servisleri göster"; Details = "GUI başlatılırken hangi servislerin çalıştığını listeler."; Usage = "systemctl list-dependencies graphical.target" },
@{ Name = "systemctl list-dependencies multi-user.target"; Description = "Çok kullanıcılı hedefin servislerini göster"; Details = "Terminal tabanlı sistem açılışında çalışan servisleri listeler."; Usage = "systemctl list-dependencies multi-user.target" },
@{ Name = "systemctl is-active <hizmet>"; Description = "Hizmetin aktif olup olmadığını kontrol et"; Details = "Belirtilen hizmet çalışıyorsa 'active', değilse 'inactive' sonucu döner."; Usage = "systemctl is-active nginx" },
@{ Name = "systemctl is-enabled <hizmet>"; Description = "Hizmetin sistem açılışında etkin olup olmadığını kontrol et"; Details = "Hizmet etkinleştirilmişse 'enabled', değilse 'disabled' sonucu döner."; Usage = "systemctl is-enabled nginx" },
@{ Name = "systemctl is-system-running"; Description = "Sistemin çalışma durumunu göster"; Details = "Sistem çalışıyorsa 'running', kurtarma modundaysa 'rescue' gibi sonuçlar verir."; Usage = "systemctl is-system-running" },
@{ Name = "systemctl reenable <hizmet>"; Description = "Hizmeti yeniden etkinleştir"; Details = "Önce devre dışı bırakır sonra tekrar etkinleştirir."; Usage = "systemctl reenable nginx" },
@{ Name = "systemctl preset <hizmet>"; Description = "Hizmet varsayılan yapılandırmasına göre ayarlanır"; Details = "Dağıtıma göre gelen varsayılan etkinleştirme ayarlarını uygular."; Usage = "systemctl preset nginx" },
@{ Name = "systemctl preset-all"; Description = "Tüm birimleri varsayılan ayarlarına döndür"; Details = "Sistemdeki tüm birim dosyaları için preset ayarlarını uygular."; Usage = "systemctl preset-all" },
@{ Name = "systemctl condrestart <hizmet>"; Description = "Hizmet çalışıyorsa yeniden başlat"; Details = "Çalışan hizmeti yeniden başlatır, duruyorsa hiçbir şey yapmaz."; Usage = "systemctl condrestart nginx" },
@{ Name = "systemctl try-restart <hizmet>"; Description = "Hizmeti varsa yeniden başlat"; Details = "Hizmet varsa yeniden başlatılır, yoksa hata vermez."; Usage = "systemctl try-restart nginx" },
@{ Name = "systemctl force-reload <hizmet>"; Description = "Hizmeti zorla yeniden yükle"; Details = "Yeniden yüklemenin desteklendiği hizmetlerde yapılandırma zorla yüklenir."; Usage = "systemctl force-reload nginx" },
@{ Name = "systemctl reload-or-restart <hizmet>"; Description = "Yeniden yükle veya yeniden başlat"; Details = "Hizmet yeniden yüklemeyi destekliyorsa yükler, değilse yeniden başlatır."; Usage = "systemctl reload-or-restart nginx" },
@{ Name = "systemctl reload-or-try-restart <hizmet>"; Description = "Yeniden yükle veya yeniden başlatmayı dene"; Details = "Hizmet çalışıyorsa yeniden yüklemeyi dener, değilse yeniden başlatmayı dener."; Usage = "systemctl reload-or-try-restart nginx" },
@{ Name = "systemctl snapshot"; Description = "Geçici hedef dosyası oluştur"; Details = "Geçerli çalıştırma durumunu geçici bir hedef olarak kaydeder."; Usage = "systemctl snapshot" },
@{ Name = "systemctl list-machines"; Description = "Kapsayıcı ve uzak makineleri listele"; Details = "Sisteme bağlı tüm makineleri listeler."; Usage = "systemctl list-machines" },
@{ Name = "systemctl start graphical.target"; Description = "Grafik kullanıcı arayüzü başlat"; Details = "GUI ortamını başlatmak için kullanılır."; Usage = "systemctl start graphical.target" },
@{ Name = "systemctl isolate graphical.target"; Description = "Grafik hedefe geçiş yap"; Details = "Grafik oturuma geçiş yapar, diğer hedefleri sonlandırır."; Usage = "systemctl isolate graphical.target" },
@{ Name = "systemctl set-property <hizmet> <özellik>=<değer>"; Description = "Hizmet özelliklerini değiştir"; Details = "Çalışan bir hizmetin kaynak sınırlarını günceller."; Usage = "systemctl set-property nginx MemoryMax=500M" },
@{ Name = "systemctl reboot --force"; Description = "Sistemi zorla yeniden başlat"; Details = "Sistemi systemd üzerinden zorla yeniden başlatır."; Usage = "systemctl reboot --force" },
@{ Name = "systemctl poweroff --force"; Description = "Sistemi zorla kapat"; Details = "Sistemi systemd üzerinden zorla kapatır."; Usage = "systemctl poweroff --force" },
@{ Name = "systemctl suspend-then-hibernate"; Description = "Önce askıya al sonra hazırda beklet"; Details = "Sistem önce askıya alınır, ardından hazırda bekletmeye geçer."; Usage = "systemctl suspend-then-hibernate" },
@{ Name = "systemctl hibernate"; Description = "Sistemi hazırda beklet"; Details = "Sistem belleği diske yazar ve kapanır."; Usage = "systemctl hibernate" },
@{ Name = "systemctl isolate rescue.target"; Description = "Kurtarma moduna geç"; Details = "Sistemi sadece temel hizmetlerin çalıştığı kurtarma moduna geçirir."; Usage = "systemctl isolate rescue.target" },
@{ Name = "systemctl isolate emergency.target"; Description = "Acil moda geç"; Details = "Sistemi tek kullanıcı moduna geçirir, en düşük seviye erişim sağlar."; Usage = "systemctl isolate emergency.target" },
@{ Name = "systemctl start multi-user.target"; Description = "Çok kullanıcılı hedefi başlat"; Details = "Metin modunda çok kullanıcılı ortamı başlatır."; Usage = "systemctl start multi-user.target" },
@{ Name = "systemctl isolate multi-user.target"; Description = "Çok kullanıcılı moda geç"; Details = "Sistemi sadece çok kullanıcılı hedef moduna geçirir."; Usage = "systemctl isolate multi-user.target" },
@{ Name = "systemctl isolate default.target"; Description = "Varsayılan moda geç"; Details = "Varsayılan olarak belirlenen hedef moduna geçiş yapar."; Usage = "systemctl isolate default.target" },
@{ Name = "systemctl list-dependencies default.target"; Description = "Varsayılan hedefin bağımlılıklarını göster"; Details = "Varsayılan hedefe bağlı tüm birimleri listeler."; Usage = "systemctl list-dependencies default.target" },
@{ Name = "systemctl list-units --type=service"; Description = "Tüm hizmetlerin anlık durumunu listele"; Details = "Çalışan, durdurulmuş ve bekleyen tüm hizmetleri gösterir."; Usage = "systemctl list-units --type=service" },
@{ Name = "systemctl list-units --type=service --all"; Description = "Etkin ya da etkin olmayan tüm servisleri göster"; Details = "Hem çalışan hem durdurulmuş servisleri dahil eder."; Usage = "systemctl list-units --type=service --all" },
@{ Name = "systemctl list-unit-files --type=service --state=static"; Description = "Statik servisleri göster"; Details = "Başlatılamayan ama diğer servislerce kullanılan servislerdir."; Usage = "systemctl list-unit-files --type=service --state=static" },
@{ Name = "systemctl list-unit-files --type=service --state=indirect"; Description = "Dolaylı etkinleştirilen servisleri göster"; Details = "Bazı hedeflere bağlı olan ama doğrudan etkin olmayan servisler."; Usage = "systemctl list-unit-files --type=service --state=indirect" }
@{ Name = "systemctl list-unit-files --type=service --state=enabled"; Description = "Sistem açılışında otomatik başlayacak hizmetleri listele"; Details = "Etkinleştirilmiş (enabled) servisleri listeler."; Usage = "systemctl list-unit-files --type=service --state=enabled" },
@{ Name = "systemctl list-unit-files --type=service --state=disabled"; Description = "Sistem açılışında başlamayacak servisleri listele"; Details = "Devre dışı (disabled) durumdaki servisleri listeler."; Usage = "systemctl list-unit-files --type=service --state=disabled" },
@{ Name = "systemctl list-unit-files --type=service --state=masked"; Description = "Maskelenmiş (başlatılamaz) servisleri listele"; Details = "Maskelenmiş servisler başlatılamaz, bu komut onları listeler."; Usage = "systemctl list-unit-files --type=service --state=masked" },
@{ Name = "systemctl list-units --type=mount"; Description = "Tüm bağlama noktalarını listele"; Details = "Sistemdeki tüm bağlama (mount) birimlerini gösterir."; Usage = "systemctl list-units --type=mount" },
@{ Name = "systemctl list-units --type=automount"; Description = "Tüm otomatik bağlamaları listele"; Details = "Sistemdeki otomatik bağlama yapılandırmalarını listeler."; Usage = "systemctl list-units --type=automount" },
@{ Name = "systemctl list-units --type=timer"; Description = "Zamanlayıcıları listele"; Details = "Sistemde etkin olan tüm zamanlayıcıları listeler."; Usage = "systemctl list-units --type=timer" },
@{ Name = "systemctl list-units --type=socket"; Description = "Tüm socket birimlerini listele"; Details = "Socket birimleri üzerinden çalışan servis yapılarını gösterir."; Usage = "systemctl list-units --type=socket" },
@{ Name = "systemctl list-timers --all"; Description = "Tüm zamanlayıcıları göster (aktif ve pasif)"; Details = "Çalışan ve çalışmayan zamanlayıcıları birlikte gösterir."; Usage = "systemctl list-timers --all" },
@{ Name = "systemctl show <hizmet> -p SubState"; Description = "Alt çalışma durumunu göster"; Details = "Hizmetin detaylı çalıştırılma alt durumunu verir."; Usage = "systemctl show nginx -p SubState" },
@{ Name = "systemctl show <hizmet> -p ExecMainStatus"; Description = "Ana işlem çıkış kodunu göster"; Details = "Hizmetin son ana işleminin çıkış durumunu gösterir."; Usage = "systemctl show nginx -p ExecMainStatus" },
@{ Name = "systemctl list-jobs --all"; Description = "Tüm aktif ve bekleyen işler"; Details = "Çalışan ve sırada bekleyen systemd işleri listelenir."; Usage = "systemctl list-jobs --all" },
@{ Name = "systemctl isolate graphical.target --no-block"; Description = "Grafik hedefe geçişi beklemeden başlat"; Details = "Geçiş işlemini başlatır ama tamamlanmasını beklemez."; Usage = "systemctl isolate graphical.target --no-block" },
@{ Name = "journalctl"; Description = "Tüm sistem günlüklerini görüntüle"; Details = "Varsayılan olarak tüm günlükleri tarih sırasına göre gösterir."; Usage = "journalctl" },
@{ Name = "journalctl -xe"; Description = "Hataları detaylı ve son olaylarla birlikte göster"; Details = "Sistemdeki son kritik olayları detaylı şekilde listeler."; Usage = "journalctl -xe" },
@{ Name = "journalctl -f"; Description = "Günlükleri canlı olarak takip et"; Details = "Gerçek zamanlı log akışını izlemek için kullanılır."; Usage = "journalctl -f" },
@{ Name = "journalctl -r"; Description = "Ters sırayla günlükleri göster"; Details = "En yeni kayıtları en üstte olacak şekilde listeler."; Usage = "journalctl -r" },
@{ Name = "journalctl -u <hizmet>"; Description = "Belirli bir hizmetin günlüklerini göster"; Details = "Yalnızca ilgili hizmetin log kayıtlarını listeler."; Usage = "journalctl -u nginx" },
@{ Name = "journalctl -u <hizmet> --since today"; Description = "Bugünden itibaren hizmetin günlüklerini göster"; Details = "İlgili hizmetin sadece bugünkü kayıtlarını getirir."; Usage = "journalctl -u nginx --since today" },
@{ Name = "journalctl --since yesterday"; Description = "Dünden itibaren günlükleri göster"; Details = "Sistemin dünden itibaren oluşturduğu logları listeler."; Usage = "journalctl --since yesterday" },
@{ Name = "journalctl -p err..alert"; Description = "Belirli öncelikteki günlükleri göster"; Details = "Yalnızca 'error' ile 'alert' arasındaki kritik öncelikli loglar gösterilir."; Usage = "journalctl -p err..alert" },
@{ Name = "journalctl --disk-usage"; Description = "Günlüklerin disk kullanımını göster"; Details = "Günlüklerin sistemde ne kadar alan kapladığını listeler."; Usage = "journalctl --disk-usage" },
@{ Name = "journalctl --list-boots"; Description = "Tüm sistem önyüklemelerini listele"; Details = "Sistemin önceki açılışlarına dair kimlik ve zaman bilgisini gösterir."; Usage = "journalctl --list-boots" },
@{ Name = "journalctl -b"; Description = "Geçerli önyüklemeden itibaren günlükleri göster"; Details = "Sistemin şu anki açılışından bu yana olan logları getirir."; Usage = "journalctl -b" },
@{ Name = "journalctl -b -1"; Description = "Bir önceki önyüklemenin günlüklerini göster"; Details = "Sistem önceki açılışından bu yana oluşan logları listeler."; Usage = "journalctl -b -1" },
@{ Name = "journalctl --vacuum-size=100M"; Description = "Günlükleri boyuta göre temizle"; Details = "Günlükler 100 MB'dan büyükse otomatik olarak silinir."; Usage = "journalctl --vacuum-size=100M" },
@{ Name = "journalctl --vacuum-time=7d"; Description = "Günlükleri zamana göre temizle"; Details = "7 günden eski loglar silinir."; Usage = "journalctl --vacuum-time=7d" },
@{ Name = "journalctl --no-pager"; Description = "Sayfalayıcı kullanmadan tüm günlükleri göster"; Details = "Çıktı doğrudan terminale akıtılır, sayfalama yapılmaz."; Usage = "journalctl --no-pager" },
@{ Name = "journalctl -o json"; Description = "Günlükleri JSON formatında göster"; Details = "Her bir log girdisi JSON nesnesi olarak yazdırılır."; Usage = "journalctl -o json" },
@{ Name = "journalctl -n 50"; Description = "Son 50 günlük kaydını göster"; Details = "Varsayılan olarak son N kaydı listeler."; Usage = "journalctl -n 50" },
@{ Name = "journalctl -u <hizmet> -n 20"; Description = "Bir hizmete ait son 20 kaydı göster"; Details = "Hizmete ait en son 20 log girdisi gösterilir."; Usage = "journalctl -u nginx -n 20" },
@{ Name = "journalctl -k"; Description = "Sadece çekirdek günlüklerini göster"; Details = "Dmesg benzeri biçimde çekirdek logları gösterilir."; Usage = "journalctl -k" },
@{ Name = "journalctl _PID=<pid>"; Description = "Belirli bir işlem ID'sine ait günlükleri göster"; Details = "İşlem ID'si ile ilişkili tüm log girdileri listelenir."; Usage = "journalctl _PID=1234" },
@{ Name = "journalctl _UID=1000"; Description = "Belirli kullanıcı kimliğine ait günlükleri göster"; Details = "Belirli UID'ye sahip kullanıcıya ait log kayıtlarını getirir."; Usage = "journalctl _UID=1000" },
@{ Name = "loginctl"; Description = "Kullanıcı oturumlarını yöneten araç"; Details = "Sistemde oturum açmış kullanıcıları ve oturumlarını gösterir."; Usage = "loginctl" },
@{ Name = "loginctl list-sessions"; Description = "Tüm kullanıcı oturumlarını listele"; Details = "Sistemde açık olan tüm oturumları ve kullanıcıları listeler."; Usage = "loginctl list-sessions" },
@{ Name = "loginctl show-session <id>"; Description = "Belirli bir oturum hakkında detaylı bilgi"; Details = "Oturum ID’sine göre oturumun tüm özelliklerini gösterir."; Usage = "loginctl show-session 2" },
@{ Name = "hostnamectl"; Description = "Sistem ana bilgisayar adını görüntüle veya değiştir"; Details = "Sistemin hostname, donanım ve OS bilgilerini gösterir."; Usage = "hostnamectl" },
@{ Name = "hostnamectl set-hostname <ad>"; Description = "Ana bilgisayar adını değiştir"; Details = "Sistemin hostname’ini kalıcı olarak değiştirir."; Usage = "hostnamectl set-hostname sunucu1" },
@{ Name = "timedatectl"; Description = "Tarih, saat ve zaman dilimi yapılandırması"; Details = "Sistem saatini ve zaman dilimini görüntüler veya ayarlar."; Usage = "timedatectl" },
@{ Name = "timedatectl set-timezone <zone>"; Description = "Zaman dilimini ayarla"; Details = "Sistemin zaman dilimini değiştirir (örneğin Europe/Istanbul)."; Usage = "timedatectl set-timezone Europe/Istanbul" },
@{ Name = "timedatectl set-ntp true"; Description = "NTP ile saat senkronizasyonunu etkinleştir"; Details = "Network Time Protocol (NTP) ile otomatik saat senkronizasyonunu açar."; Usage = "timedatectl set-ntp true" },
@{ Name = "busctl list"; Description = "D-Bus üzerinden çalışan servisleri listele"; Details = "Sistemde D-Bus üzerinden erişilebilen tüm servisleri listeler."; Usage = "busctl list" },
@{ Name = "busctl introspect <hizmet> <yol>"; Description = "D-Bus servisini incele"; Details = "Belirli bir D-Bus hizmetinin yöntemlerini ve arayüzlerini gösterir."; Usage = "busctl introspect org.freedesktop.hostname1 /org/freedesktop/hostname1" },
@{ Name = "localectl"; Description = "Sistem yerel ayarlarını göster"; Details = "Dil, klavye düzeni ve yerel ayar bilgilerini gösterir."; Usage = "localectl" },
@{ Name = "localectl status"; Description = "Geçerli yerel ayar durumunu görüntüle"; Details = "Dil ve klavye yapılandırmasının özetini sunar."; Usage = "localectl status" },
@{ Name = "localectl set-locale LANG=tr_TR.UTF-8"; Description = "Sistem dili ayarla"; Details = "Sistemin dilini kalıcı olarak Türkçe yapar."; Usage = "localectl set-locale LANG=tr_TR.UTF-8" },
@{ Name = "localectl set-keymap tr"; Description = "Klavye düzenini değiştir"; Details = "Klavye düzenini Türkçe (Q veya F) olarak ayarlar."; Usage = "localectl set-keymap tr" },
@{ Name = "coredumpctl"; Description = "Çökmüş işlemlerle ilgili bilgi göster"; Details = "Çökmüş uygulamaların core dump verilerini listeler."; Usage = "coredumpctl" },
@{ Name = "coredumpctl list"; Description = "Core dump listesini göster"; Details = "Sistem üzerinde oluşmuş tüm core dump dosyalarını listeler."; Usage = "coredumpctl list" },
@{ Name = "coredumpctl info <PID>"; Description = "Belirli bir işlem için core dump bilgisi göster"; Details = "Verilen PID’ye ait çökme bilgilerini detaylı olarak listeler."; Usage = "coredumpctl info 1234" },
@{ Name = "systemd-analyze"; Description = "Sistem açılış analizini yap"; Details = "Sistem açılış süresini ve işlem sürelerini gösterir."; Usage = "systemd-analyze" },
@{ Name = "systemd-analyze blame"; Description = "En çok zaman alan servisleri göster"; Details = "Açılışta en çok süre tüketen hizmetleri listeler."; Usage = "systemd-analyze blame" },
@{ Name = "systemd-analyze critical-chain"; Description = "Açılıştaki kritik hizmet zincirini göster"; Details = "Kritik hizmetler arasındaki bağımlılık zincirini listeler."; Usage = "systemd-analyze critical-chain" }
)


    $fzfInput = $commands | ForEach-Object {
        "$([char]27)[38;5;75m$($_.Name)$([char]27)[0m`t$([char]27)[38;5;244m⯈ $($_.Description)$([char]27)[0m"
    } | Out-String

    $fzfOutputFile = [System.IO.Path]::GetTempFileName()

    $fzfInput | fzf --height 70% --layout=reverse --border --ansi --color=fg:#00FFFF,bg:#1C1C1C,hl:#FFD700 --color=fg+:#FFFFFF,bg+:#262626,hl+:#7FFF00 --color=info:#00FF00,prompt:#00FF00,pointer:#FF0000,marker:#FF69B4,spinner:#00FF00,header:#00FF00 > $fzfOutputFile

    $selected = Get-Content -Path $fzfOutputFile

    if ($selected) {
        $selectedItem = $commands | Where-Object { $_.Name -eq ($selected -split "`t")[0] }
        if ($selectedItem -ne $null) {
            $selectedCommand = $selectedItem.Name
            $selectedDescription = $selectedItem.Description
            Clear-Host
            $prompt = " > "
            Write-Host "$prompt$selectedCommand   >  $selectedDescription" -ForegroundColor Cyan
            Write-Host "=========================================" -ForegroundColor Green
            Write-Host "Detaylı Bilgi:" -ForegroundColor Yellow
            Write-Host $selectedItem.Details -ForegroundColor White
            Write-Host "-----------------------------------------" -ForegroundColor DarkYellow
            Write-Host "Kullanım Alanı:" -ForegroundColor Magenta
            Write-Host $selectedItem.Usage -ForegroundColor White
            Write-Host "=========================================" -ForegroundColor Green
        }
    }

    Remove-Item -Path $fzfOutputFile
}

# Alias tanımı (terminalde sadece 'systemctlhelp' yazınca çalışsın)
Set-Alias -Name 'ctl' -Value 'Invoke-SystemctlToolkit'
