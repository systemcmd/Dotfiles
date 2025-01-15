# Blue Team Toolkit
function Invoke-BlueTeam {
    $blueTeamTools = @(
        # Network Analysis
        @{ Name = "Wireshark"; Description = "Ağ trafiği analiz aracı"; Details = "Wireshark, ağ trafiğini analiz ederek ağdaki sorunları tespit etmenize yardımcı olur."; Usage = "Wireshark, ağdaki protokol hatalarını tespit etmek, şüpheli aktiviteleri belirlemek ve ağ performansını analiz etmek için kullanılır." },
        @{ Name = "pfSense"; Description = "Ağ güvenlik duvarı ve yönlendirici"; Details = "pfSense, açık kaynaklı bir güvenlik duvarı ve yönlendirici çözümüdür."; Usage = "Ağ güvenliğini artırmak, VPN bağlantılarını yönetmek ve erişim kontrolleri oluşturmak için kullanılır." },
        @{ Name = "Arkime"; Description = "Ağ paketlerini yakalama ve arşivleme aracı"; Details = "Arkime, yüksek hacimli ağ trafiğini yakalayıp saklayan bir araçtır."; Usage = "Geçmiş ağ aktivitelerini analiz etmek ve saldırı sonrası delil toplamak için kullanılır." },
        @{ Name = "Snort"; Description = "Ağ izinsiz giriş tespit sistemi (IDS)"; Details = "Snort, ağ trafiğini analiz ederek izinsiz girişleri algılar."; Usage = "Snort, kötü niyetli aktiviteleri tespit etmek ve ağ güvenliğini sağlamak için kullanılır." },

        # Incident Management
        @{ Name = "TheHive"; Description = "Olay müdahale yönetim platformu"; Details = "TheHive, siber olaylara müdahale etmek ve ekip içi koordinasyonu sağlamak için tasarlanmıştır."; Usage = "Tehdit istihbaratını analiz etmek, raporlar oluşturmak ve güvenlik olaylarını yönetmek için kullanılır." },
        @{ Name = "GRR Rapid Response"; Description = "Olay müdahale ve adli inceleme aracı"; Details = "GRR, uzak sistemlerde analiz yaparak hızlı müdahale süreçlerini yönetir."; Usage = "Uzak cihazlardan veri toplamak ve adli inceleme yapmak için kullanılır." },

        # Threat Intelligence
        @{ Name = "MISP"; Description = "Tehdit istihbarat paylaşım platformu"; Details = "MISP, tehdit bilgilerini toplamak, paylaşmak ve analiz etmek için kullanılır."; Usage = "Siber tehdit verilerini analiz ederek ve paylaşarak daha geniş bir güvenlik ağı oluşturmak için kullanılır." },
        @{ Name = "MITRE ATT&CK"; Description = "Tehdit modelleme ve analiz çerçevesi"; Details = "MITRE ATT&CK, saldırganların kullandığı teknikleri ve taktikleri analiz eden bir bilgi tabanıdır."; Usage = "Siber saldırı yöntemlerini anlamak, zafiyetleri tespit etmek ve önlem almak için kullanılır." },

        # EDR (Endpoint Detection & Response)
        @{ Name = "Cortex XDR"; Description = "Uç nokta tespit ve yanıt çözümü"; Details = "Cortex XDR, uç noktalardaki tehditleri tespit etmek ve bunlara yanıt vermek için tasarlanmıştır."; Usage = "Uç nokta sistemlerini izlemek, kötü niyetli aktiviteleri tespit etmek ve bu tehditlere hızlı yanıt vermek için kullanılır." },
        @{ Name = "CYNET 360"; Description = "Siber güvenlik otomasyon platformu"; Details = "CYNET 360, otomatik tehdit algılama ve yanıtlama sağlar."; Usage = "Tehditleri hızlı bir şekilde algılamak ve yanıt vermek için kullanılır." },
        @{ Name = "FortiEDR"; Description = "Gelişmiş uç nokta güvenliği"; Details = "FortiEDR, uç noktaları kötü amaçlı aktivitelerden korur."; Usage = "Sistem güvenliğini sağlamak ve kötü niyetli yazılımlara karşı koruma sağlamak için kullanılır." },

        # OS Analysis
        @{ Name = "HELK"; Description = "Olay günlüklerini analiz etme ve görselleştirme aracı"; Details = "HELK, günlük dosyalarını analiz ederek güvenlik tehditlerini görselleştirir."; Usage = "Tehditleri görselleştirmek ve analiz etmek için olay günlüklerini incelemek için kullanılır." },
        @{ Name = "Volatility"; Description = "Bellek adli inceleme aracı"; Details = "Volatility, bellek döküm dosyalarını analiz ederek sistemdeki şüpheli aktiviteleri ortaya çıkarır."; Usage = "RAM üzerinde çalışan kötü niyetli yazılımları analiz etmek ve adli delil toplamak için kullanılır." },
        @{ Name = "Wazuh"; Description = "SIEM entegrasyonlu güvenlik izleme aracı"; Details = "Wazuh, gerçek zamanlı güvenlik izleme ve SIEM entegrasyonu sağlar."; Usage = "Güvenlik açıklarını izlemek, tehditleri tespit etmek ve uyumluluk raporları oluşturmak için kullanılır." },
        @{ Name = "RegRipper"; Description = "Windows kayıt defteri analiz aracı"; Details = "RegRipper, Windows sistem kayıtlarını analiz eder."; Usage = "Adli bilişim süreçlerinde, sistem kayıtlarındaki değişiklikleri incelemek için kullanılır." },
        @{ Name = "OSSEC"; Description = "Host tabanlı izinsiz giriş tespit sistemi"; Details = "OSSEC, sistemdeki anormal aktiviteleri tespit eden bir host tabanlı güvenlik aracıdır."; Usage = "Gerçek zamanlı izleme ve sistem anormalliklerini tespit etmek için kullanılır." },
        @{ Name = "osquery"; Description = "Sistem analiz ve sorgulama aracı"; Details = "osquery, SQL tabanlı sorgularla sistem durumunu analiz etmenizi sağlar."; Usage = "Sistem durumunu izlemek, süreçleri ve ağ bağlantılarını analiz etmek için kullanılır." },

        # Honeypots
        @{ Name = "Kippo"; Description = "SSH honeypot"; Details = "Kippo, saldırganları analiz etmek için kullanılan bir SSH honeypot'tur."; Usage = "SSH saldırılarını izlemek ve saldırganların davranışlarını analiz etmek için kullanılır." },
        @{ Name = "Cowrie"; Description = "Gelişmiş SSH ve Telnet honeypot"; Details = "Cowrie, SSH ve Telnet saldırılarını tespit etmek için kullanılır."; Usage = "SSH protokolü üzerinden gelen saldırıları analiz etmek ve raporlamak için kullanılır." },
        @{ Name = "Dionaea"; Description = "Kötü amaçlı yazılım honeypot"; Details = "Dionaea, kötü amaçlı yazılımları yakalamak ve analiz etmek için bir honeypot'tur."; Usage = "Kötü niyetli yazılımların örneklerini toplamak ve analiz etmek için kullanılır." },
        @{ Name = "HonSSH"; Description = "SSH bağlantılarını izleyen honeypot"; Details = "HonSSH, SSH bağlantılarını izleyip analiz eder."; Usage = "SSH aktivitelerini izlemek, saldırgan davranışlarını analiz etmek ve tehditleri raporlamak için kullanılır." },

        # SIEM
        @{ Name = "OSSIM"; Description = "Açık kaynaklı SIEM aracı"; Details = "OSSIM, güvenlik bilgisi ve olay yönetimi için bir platformdur."; Usage = "Güvenlik olaylarını analiz etmek ve tehdit raporları oluşturmak için kullanılır." },
        @{ Name = "Splunk"; Description = "Gelişmiş veri analizi ve SIEM aracı"; Details = "Splunk, büyük veri analizi ve günlük izleme için kullanılır."; Usage = "Siber güvenlik olaylarını analiz etmek, raporlar oluşturmak ve tehditleri tespit etmek için kullanılır." },
        @{ Name = "LogRhythm"; Description = "SIEM ve olay yönetimi çözümü"; Details = "LogRhythm, tehdit analizi ve olay yönetimi için bir çözümdür."; Usage = "Tehdit tespiti yapmak ve güvenlik olaylarını yönetmek için kullanılır." },

   # Ek bir seçenek: Blue Team Nedir?
   @{ 
    Name = "Blue Team Nedir?"; 
    Description = "Blue Team'in görevleri ve amaçları hakkında bilgi alın."; 
    Details = @"
    Blue Team, bir organizasyonun bilgi güvenliği savunma ekiplerini temsil eder. Görevleri arasında şunlar bulunur:
    1. Güvenlik tehditlerini önleme.
    2. Güvenlik tehditlerini algılama.
    3. Olaylara hızlı bir şekilde müdahale etme.

    Blue Team, siber saldırıları engellemek ve organizasyonun altyapısını güvende tutmak için sürekli çalışır.
"@; 
    Usage = @"
    Blue Team, organizasyon içindeki güvenliği sağlamak ve tehditlere karşı proaktif bir savunma mekanizması oluşturmak için kritik bir rol oynar.
"@
}
)
 
    # Menü Öğeleri
    $menuItems = $blueTeamTools | ForEach-Object { "$($_.Name) - $($_.Description)" }

    # fzf Menü
    $selectedTool = $menuItems | fzf --height 70% --reverse --prompt "Blue Team Toolkit: "

    if ($selectedTool) {
        $toolName = ($selectedTool -split " - ")[0]
        $toolDetails = $blueTeamTools | Where-Object { $_.Name -eq $toolName }
        if ($toolDetails) {
            Write-Host "Seçilen Araç: $($toolDetails.Name)" -ForegroundColor Green
            Write-Host "`nAçıklama: $($toolDetails.Description)" -ForegroundColor Cyan
            Write-Host "`nDetaylı Bilgi: $($toolDetails.Details)" -ForegroundColor White
            Write-Host "`nKullanım Alanı:" -ForegroundColor Yellow
            Write-Host $($toolDetails.Usage) -ForegroundColor White
        } else {
            Write-Host "Blue Team Nedir hakkında bilgi seçildi." -ForegroundColor Green
        }
    } else {
        Write-Host "Hiçbir araç seçilmedi." -ForegroundColor Yellow
    }
}

# Alias Oluşturma
New-Alias -Name 'blueteam' -Value 'Invoke-BlueTeam'
