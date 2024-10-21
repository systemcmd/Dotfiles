function Show-AnimatedMenu.hc {
    $hashcatCommands = @(
        @{ Command="hashcat -I"; Description="Tüm cihazların ayrıntılarını listeler." },
        @{ Command="hashcat -b"; Description="Tüm cihazların benchmark testini yapar." },
        @{ Command="hashcat --restore --session=mySession"; Description="Belirli bir oturum adından saldırıyı devam ettirir." },
        @{ Command="hashcat -m 0 -a 0 hash.txt wordlist.txt --potfile-disable"; Description="MD5 hashleri için düz saldırı gerçekleştirir ve potfile kullanımını devre dışı bırakır." },
        @{ Command="hashcat -m 1800 -a 0 hash.txt wordlist.txt"; Description="SHA-512 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 1400 -a 0 hash.txt wordlist.txt"; Description="SHA-256 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 500 -a 0 hash.txt wordlist.txt"; Description="md5crypt (MD5) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 3200 -a 0 hash.txt wordlist.txt"; Description="bcrypt $2*$, Blowfish (Unix) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 1500 -a 0 hash.txt wordlist.txt"; Description="descrypt, DES (Unix) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 100 -a 0 hash.txt wordlist.txt"; Description="SHA1 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 1700 -a 0 hash.txt wordlist.txt"; Description="SHA-512(Unix) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 5500 -a 0 hash.txt wordlist.txt"; Description="NetNTLMv1-VANILLA / NetNTLMv1+ESS hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 5600 -a 0 hash.txt wordlist.txt"; Description="NetNTLMv2 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 7300 -a 0 hash.txt wordlist.txt"; Description="IPMI2 RAKP HMAC-SHA1 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 7500 -a 0 hash.txt wordlist.txt"; Description="Kerberos 5 AS-REP hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 13100 -a 0 hash.txt wordlist.txt"; Description="Kerberos 5 TGS-REP hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 7100 -a 0 hash.txt wordlist.txt"; Description="macOS v10.8+ (PBKDF2-SHA512) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 11600 -a 0 hash.txt wordlist.txt"; Description="7-Zip hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 12500 -a 0 hash.txt wordlist.txt"; Description="RAR3-hp hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 13000 -a 0 hash.txt wordlist.txt"; Description="RAR5 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 6800 -a 0 hash.txt wordlist.txt"; Description="LastPass + LastPass sniffed hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 11300 -a 0 hash.txt wordlist.txt"; Description="Bitcoin/Litecoin wallet.dat hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 125 -a 0 hash.txt wordlist.txt"; Description="ARP-SHA256 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 1300 -a 0 hash.txt wordlist.txt"; Description="SHA-224 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 17300 -a 0 hash.txt wordlist.txt"; Description="SHA3-512 hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 5700 -a 0 hash.txt wordlist.txt"; Description="Cisco-IOS $8$ hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 5800 -a 0 hash.txt wordlist.txt"; Description="Cisco-IOS $9$ hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 26400 -a 0 hash.txt wordlist.txt"; Description="MS Office 2007+ hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 13300 -a 0 hash.txt wordlist.txt"; Description="AxCrypt hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 10 -a 0 hash.txt wordlist.txt"; Description="md5($pass.$salt) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 20 -a 0 hash.txt wordlist.txt"; Description="md5($salt.$pass) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 50 -a 0 hash.txt wordlist.txt"; Description="HMAC-MD5 (key = $pass) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 60 -a 0 hash.txt wordlist.txt"; Description="HMAC-MD5 (key = $salt) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 150 -a 0 hash.txt wordlist.txt"; Description="HMAC-SHA1 (key = $pass) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 160 -a 0 hash.txt wordlist.txt"; Description="HMAC-SHA1 (key = $salt) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 8000 -a 0 hash.txt wordlist.txt"; Description="Samsung Android Password/PIN hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 5000 -a 0 hash.txt wordlist.txt"; Description="SHA-3(512) hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -m 9600 -a 0 hash.txt wordlist.txt"; Description="MS Office 2013+ hashleri için düz saldırı gerçekleştirir." },
        @{ Command="hashcat -a 3 -m 0 hash.txt ?d?d?d?d"; Description="Düz saldırı (mask attack) kullanarak dört basamaklı sayıları brute-force yapar." },
        @{ Command="hashcat -a 6 -m 0 hash.txt wordlist.txt ?d?d?d"; Description="Wordlist + mask hybrid saldırı." },
        @{ Command="hashcat -a 7 -m 0 hash.txt ?d?d?d wordlist.txt"; Description="Mask + wordlist hybrid saldırı." },
        @{ Command="hashcat -a 1 -m 0 hash.txt wordlist1.txt wordlist2.txt"; Description="Kombinasyon saldırısı (combinator attack)." }
    )

    $fzfInput = $hashcatCommands | ForEach-Object {
        "$([char]27)[38;5;57m$($_.Command)$([char]27)[0m`t$([char]27)[38;5;244m⯈ $($_.Description)$([char]27)[0m"
    } | Out-String

    $fzfOutputFile = [System.IO.Path]::GetTempFileName()

    try {

        $fzfInput | fzf --height 70% --layout=reverse --border --ansi --color=fg:#FFD700,bg:#1C1C1C,hl:#5F00AF --color=fg+:#FFD700,bg+:#262626,hl+:#7FFF00 --color=info:#00FF00,prompt:#00FF00,pointer:#FF0000,marker:#FF69B4,spinner:#00FF00,header:#00FF00 > $fzfOutputFile

        $selected = Get-Content -Path $fzfOutputFile

        if ($selected) {
            $selectedItem = $hashcatCommands | Where-Object { $_.Command -eq ($selected -split "`t")[0] }
            $selectedCommand = $selectedItem.Command
            $selectedDescription = $selectedItem.Description
            Clear-Host
            $prompt = " > "
            Write-Host "$prompt$selectedCommand   >  $selectedDescription" -ForegroundColor Red
        } else {
            Write-Host "Hiçbir komut seçilmedi." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Bir hata oluştu: $_" -ForegroundColor Red
    } finally {

        Remove-Item -Path $fzfOutputFile -ErrorAction SilentlyContinue
    }
}


Set-Alias hc Show-AnimatedMenu.hc
