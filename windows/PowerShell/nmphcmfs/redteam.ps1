# Red Team Toolkit
function Invoke-RedTeam {
    $redTeamTools = @(
        # Privilege Escalation
        @{ Name = "BloodHound"; Description = "Aktif dizin saldırı analiz aracı"; Details = "BloodHound, Active Directory ortamlarında yönetici izinlerini takip etmek ve sızıntı yöntemlerini analiz etmek için kullanılan bir graf tabanlı aracıdır."; Usage = "Active Directory zafiyetlerini bulmak ve yöneticilik izinlerini analiz etmek için kullanılır." },
        @{ Name = "BeRoot"; Description = "Linux ve Windows için izin yükselme aracı"; Details = "BeRoot, çeşitli şifreleme ve konfigürasyon hatalarını tespit ederek izin yükselme imkanlarını analiz eder."; Usage = "Yerel çalışan kullanıcıda yönetici yetkilerine ulaşmak için kullanılır." },

        # Command and Control
        @{ Name = "Empire Project"; Description = "Post-exploitation framework"; Details = "Empire, PowerShell ve Python tabanlı bir komuta ve kontrol (C2) aracıdır."; Usage = "Penetrasyon testlerinde C2 için uzaktan komut çalıştırmak ve veri toplamak için kullanılır." },
        @{ Name = "Pupy"; Description = "Esnek post-exploitation aracı"; Details = "Pupy, Windows, Linux ve macOS için kullanılabilecek tüm platformlarda çalışabilen C2 aracıdır."; Usage = "Uzaktan Erişim Araçları (RAT) oluşturmak ve kullanıcı sistemlerine uzaktan erişim sağlamak için kullanılır." },
        @{ Name = "Cobalt Strike"; Description = "Komuta ve kontrol framework'u"; Details = "Cobalt Strike, profesyonel penetrasyon testleri ve Red Team faaliyetleri için geliştirilmiş bir sızma testi aracıdır."; Usage = "Yüksek düzeyli sızma testlerinde, uzaktan komut yürütmek ve sızılan sistemleri analiz etmek için kullanılır." },

        # Reconnaissance
        @{ Name = "Nmap"; Description = "Ağ tarama aracı"; Details = "Nmap, ağınızdaki cihazları tespit etmek ve port taramaları yapmak için kullanılır."; Usage = "Ağ taramaları yapmak ve cihazların zafiyetlerini tespit etmek için kullanılır." },
        @{ Name = "Shodan"; Description = "Cihaz arama motoru"; Details = "Shodan, internet üzerindeki cihazları ve hizmetleri tespit etmek için kullanılan bir arama motorudur."; Usage = "Ağa bağlı cihazların zafiyetlerini bulmak için kullanılır." },
        @{ Name = "crt.sh"; Description = "Sertifika arama hizmeti"; Details = "crt.sh, bir alan adı için kullanılan SSL sertifikalarını araştırmak için kullanılan bir araçtır."; Usage = "Hedef alan adının SSL sertifikalarını analiz etmek için kullanılır." },
        @{ Name = "RustScan"; Description = "Hızlı port tarama aracı"; Details = "RustScan, ağ portlarını hızlıca taramak için kullanılan bir araçtır."; Usage = "Port taramalarını hızlı bir şekilde gerçekleştirmek için kullanılır." },
        @{ Name = "Amass"; Description = "Alt alan adı keşif aracı"; Details = "Amass, bir alan adına ait alt alan adlarını keşfetmek için kullanılan bir araçtır."; Usage = "Hedef bir alan adıyla ilişkili alt alan adlarını bulmak için kullanılır." },

        # Credential Dumping
        @{ Name = "Mimikatz"; Description = "Kimlik bilgisi alma aracı"; Details = "Mimikatz, Windows makinelerinden şifreleri ve kimlik bilgilerini çıkartmak için kullanılan bir aracıdır."; Usage = "Windows sistemlerinden şifreler ve oturum bilgileri toplamak için kullanılır." },
        @{ Name = "LaZagne"; Description = "Şifre kurtarma aracı"; Details = "LaZagne, uygulamaların sakladığı şifreleri toplamak için kullanılır."; Usage = "Uygulamalarda saklanan şifreleri bulmak ve analiz etmek için kullanılır." },
        @{ Name = "Pypykatz"; Description = "Python ile kimlik bilgisi alma aracı"; Details = "Pypykatz, Windows sistemlerinden kimlik bilgilerini çekmek için kullanılan bir Python aracıdır."; Usage = "Windows sistemlerinde kimlik bilgilerini toplamak için kullanılır." },
        @{ Name = "Dumpert"; Description = "LSASS bellek dökümü alma aracı"; Details = "Dumpert, LSASS işlemlerinden bellek dökümü almak için kullanılan bir araçtır."; Usage = "Şifre ve kimlik bilgisi toplamak için bellek dökümlerini analiz eder." },
        @{ Name = "Forkatz"; Description = "Geliştirilmiş Mimikatz türevi"; Details = "Forkatz, Mimikatz'ın geliştirilmiş bir sürümüdür ve kimlik bilgilerini çekmek için kullanılır."; Usage = "Windows sistemlerinden şifre ve oturum bilgilerini toplamak için kullanılır." },
        @{ Name = "Nanodump"; Description = "Minimal bellek döküm aracı"; Details = "Nanodump, LSASS işlemlerini hedef alarak hafif bir bellek dökümü alır."; Usage = "Kimlik bilgilerini toplamak için bellek dökümünü analiz eder." },

        # Phishing
        @{ Name = "GoPhish"; Description = "Kimlik avı kampanya aracı"; Details = "GoPhish, kimlik avı saldırılarını simüle etmek ve farkındalık testleri yapmak için kullanılan bir araçtır."; Usage = "Kimlik avı saldırılarını planlamak ve yürütmek için kullanılır." },
        @{ Name = "King Phisher"; Description = "Kimlik avı testi aracı"; Details = "King Phisher, kimlik avı farkındalığını artırmak için saldırıları simüle eder."; Usage = "E-posta tabanlı kimlik avı saldırılarını test etmek için kullanılır." },
        @{ Name = "Evil URL"; Description = "Kötü amaçlı URL oluşturma aracı"; Details = "Evil URL, kötü amaçlı URL'ler oluşturmak için kullanılan bir araçtır."; Usage = "Kötü niyetli URL'ler oluşturarak farkındalık testleri yapmak için kullanılır." },

        # OSINT
        @{ Name = "Maltego"; Description = "Görsel OSINT aracı"; Details = "Maltego, bir hedef hakkında açık kaynak verileri toplamak ve bu bilgileri görselleştirmek için kullanılır."; Usage = "Hedef organizasyonları ve bireyleri analiz etmek için OSINT (Açık Kaynak) bilgileri toplar." },
        @{ Name = "SpiderFoot"; Description = "Otomatik OSINT arama aracı"; Details = "SpiderFoot, bir hedef hakkında açık kaynaklardan bilgi toplamak için kullanılan bir araçtır."; Usage = "Hedef sistemler ve bireyler hakkında bilgi toplamak için otomatize edilmiş OSINT araçları kullanır." },
        @{ Name = "OSINT Framework"; Description = "OSINT bilgi toplama çerçevesi"; Details = "OSINT Framework, farklı kaynaklardan bilgi toplamak için kullanılan bir rehberdir."; Usage = "OSINT araçlarını bir arada görmek ve doğru bilgi toplama yöntemlerini seçmek için kullanılır." },

        # Exfiltration
        @{ Name = "SharpExfiltrate"; Description = "Veri dışa aktarma aracı"; Details = "SharpExfiltrate, hedef sistemden veri sızdırmak için kullanılan bir araçtır."; Usage = "Veri sızıntılarını gerçekleştirmek için kullanılır." },
        @{ Name = "DNSExfiltrator"; Description = "DNS tabanlı veri dışa aktarma aracı"; Details = "DNSExfiltrator, DNS protokolü üzerinden veri sızdırmak için kullanılır."; Usage = "DNS kanallarını kullanarak gizli veri aktarımı yapmak için kullanılır." },
        @{ Name = "Egress-Assess"; Description = "Veri çıkışı değerlendirme aracı"; Details = "Egress-Assess, sistemden dışa veri çıkış yollarını analiz eder."; Usage = "Sistemden veri çıkış yollarını test etmek ve güvenlik önlemlerini değerlendirmek için kullanılır." }
    )

    # Red Team Nedir?
    $redTeamNote = @"
Red Team Nedir?
---------------
Red Team, bir organizasyonun bilgi güvenliğini test etmek için sızma testleri ve simüle edilen siber saldırılar düzenleyen ekipleri temsil eder.
Amaçları şunları içerir:
1. Organizasyonun savunma mekanizmalarının zayıflıklarını tespit etmek.
2. Gerçek saldırı senaryolarını simüle etmek.
3. Saldırıların engellenmesi için savunma ekiplerine (Blue Team) geri bildirim sağlamak.

Red Team, organizasyonların zafiyetlerini tespit ederek daha güçlü bir siber güvenlik altyapısı oluşturmasına yardımcı olur.
"@

    # FZF Menü
    $menuItems = $redTeamTools | ForEach-Object { "$($_.Name) - $($_.Description)" }
    $menuItems += "`nRed Team Nedir? - Red Team'in amacı ve işlevleri hakkında bilgi alın."

    $selectedTool = $menuItems | fzf --height 70% --reverse --prompt "Red Team Toolkit: "

    if ($selectedTool) {
        $toolName = ($selectedTool -split " - ")[0]
        $toolDetails = $redTeamTools | Where-Object { $_.Name -eq $toolName }

        if ($toolDetails) {
            Write-Host "Seçilen Araç: $($toolDetails.Name)" -ForegroundColor Green
            Write-Host "`nAçıklama: $($toolDetails.Description)" -ForegroundColor Cyan
            Write-Host "`nDetaylı Bilgi: $($toolDetails.Details)" -ForegroundColor White
            Write-Host "`nKullanım Alanı:" -ForegroundColor Yellow
            Write-Host $($toolDetails.Usage) -ForegroundColor White
        } else {
            Write-Host "$redTeamNote" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Hiçbir araç seçilmedi." -ForegroundColor Yellow
    }
}

# Alias Oluşturma
New-Alias -Name 'redteam' -Value 'Invoke-RedTeam'