function Show-GoogleDorkMenu {
    
    function Replace-Placeholders {
        param (
            [string]$dork
        )
        $matches = [regex]::Matches($dork, '{{(.*?)}}')
        foreach ($match in $matches) {
            $key = $match.Groups[1].Value
            $userInput = Read-Host "Lütfen '$key' için bir değer girin"
            $dork = $dork -replace [regex]::Escape($match.Value), $userInput
        }
        return $dork
    }

    $googleDorks = @{
        "site:example.com"                                = "Belirli bir site üzerinde arama yapar."
        "intitle:index.of"                                = "Belirli başlıkta dosyaları arar."
        "inurl:admin"                                     = "URL'de 'admin' içeren sayfaları bulur."
        "filetype:xls | filetype:xlsx intext:email"        = "E-posta içeren Excel dosyalarını bulur."
        "intext:@example.com"                             = "Belirli bir e-posta adresi içeren sayfaları bulur."
        "intext:password | passcode"                      = "Şifreler içeren sayfaları bulur."
        "inurl:/phpinfo.php"                              = "PHP bilgi sayfalarını bulur."
        "ext:sql | ext:dbf | ext:mdb"                     = "Veritabanı dosyalarını bulur."
        "intext:`"index of /`" `"/chat/logs`""             = "Sohbet loglarına erişim sağlar."
        "site:gov confidential"                           = "Hükümet sitelerinde gizli bilgileri arar."
        "filetype:doc site:gov"                           = "Hükümete ait Word belgelerini arar."
        "inurl:wp-config"                                 = "WordPress config dosyalarını arar."
        "intext:username filetype:log"                    = "Kullanıcı adı içeren log dosyalarını bulur."
        "intitle:`"Live View / - AXIS`""                  = "Canlı kamera görüntülerine erişim sağlar."
        "inurl:admin filetype:db"                         = "Admin panelleriyle ilişkili veritabanı dosyalarını bulur."
        "inurl:login | inurl:signin intitle:`"login`" | `"signin`"" = "Giriş sayfalarını bulur."
        "intitle:`"index of`" intext:connect.inc"          = "Bağlantı dosyalarını arar."
        "allintext:username filetype:log"                 = "Kullanıcı adları içeren log dosyalarını bulur."
        "inurl:`"/phpMyAdmin/`" `"Welcome to phpMyAdmin`""  = "phpMyAdmin panellerine erişim sağlar."
        "intitle:`"webcamXP 5`""                          = "webcamXP yazılımını kullanan kameraları bulur."
        "site:example.com -www"                           = "Belirli bir sitedeki alt alan adlarını hariç tutarak arar."
        "cache:example.com"                               = "Google'ın önbelleğe alınmış sayfasını gösterir."
        "related:example.com"                             = "Benzer siteleri gösterir."
        "link:example.com"                                = "Belirli bir siteye bağlantı veren sayfaları bulur."
        "intext:example"                                  = "Sayfa içeriğinde belirli bir kelimeyi arar."
        "intitle:example"                                 = "Sayfa başlığında belirli bir kelimeyi arar."
        "inurl:example"                                   = "URL içinde belirli bir kelimeyi arar."
        "filetype:pdf"                                    = "Belirli dosya türlerini arar."
        "allintext:username password"                     = "Sayfa içeriğinde belirli bir kelime grubunu arar."
        "allintitle:admin login"                          = "Sayfa başlığında belirli bir kelime grubunu arar."
        "allinurl:admin login"                            = "URL içinde belirli bir kelime grubunu arar."
        "intext:password filetype:log"                    = "Şifre içeren log dosyalarını bulur."
        "intitle:index.of finances.xls"                   = "Finansal Excel dosyalarını bulur."
        "intitle:index.of config"                         = "Konfigürasyon dosyalarını arar."
        "intitle:index.of backup"                         = "Yedekleme dosyalarını bulur."
        "inurl:admin intitle:login"                       = "Admin giriş sayfalarını bulur."
        "intitle:index.of mysql"                          = "MySQL veritabanı dosyalarını bulur."
        "inurl:secret"                                    = "URL içinde 'secret' içeren sayfaları bulur."
        "inurl:password"                                  = "URL içinde 'password' içeren sayfaları bulur."
        "filetype:sql"                                    = "SQL dosyalarını bulur."
        "filetype:txt"                                    = "TXT dosyalarını bulur."
        "filetype:log"                                    = "Log dosyalarını bulur."
        "filetype:conf"                                   = "Konfigürasyon dosyalarını bulur."
        "filetype:ini"                                    = "INI dosyalarını bulur."
        "filetype:bak"                                    = "Yedekleme dosyalarını bulur."
        "filetype:sh"                                     = "Shell script dosyalarını bulur."
        "filetype:py"                                     = "Python dosyalarını bulur."
        "filetype:rb"                                     = "Ruby dosyalarını bulur."
        "filetype:php"                                    = "PHP dosyalarını bulur."
        "filetype:asp"                                    = "ASP dosyalarını bulur."
        "filetype:jsp"                                    = "JSP dosyalarını bulur."
        "filetype:js"                                     = "JavaScript dosyalarını bulur."
        "filetype:css"                                    = "CSS dosyalarını bulur."
        "filetype:html"                                   = "HTML dosyalarını bulur."
        "intext:credentials filetype:log"                 = "Kimlik bilgileri içeren log dosyalarını bulur."
        "intext:ssn filetype:xls"                         = "Sosyal güvenlik numaraları içeren Excel dosyalarını bulur."
        "intitle:password"                                = "Başlıkta 'password' içeren sayfaları bulur."
        'intext:"Database error"'                         = "Veritabanı hata mesajlarını içeren sayfaları bulur."
        "intext:cvv filetype:xls"                         = "CVV numaraları içeren Excel dosyalarını bulur."
        "inurl:gov filetype:xls"                          = "Hükümet sitelerinde Excel dosyalarını bulur."
        "inurl:wp-login.php"                              = "WordPress giriş sayfalarını bulur."
        "inurl:/.env"                                    = ".env dosyalarını arar, hassas veriler içerebilir."
        'intext:"Configuration file"'                     = "Konfigürasyon dosyalarını içeren sayfaları bulur."
        'inurl:"/cgi-bin/"'                               = "CGI dizinlerini arar."
        'intext:"{{username}}"'                           = "Belirli bir kullanıcı adını içeren sayfaları arar. (Placeholder sonrası değer girilecektir.)"
    }

    # Geçici dosya oluşturuluyor ve dork listesi burada saklanıyor
    $tempFile = [System.IO.Path]::GetTempFileName()
    $dorksDisplay = $googleDorks.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
        "$($_.Name) - `e[36m$($_.Value)`e[0m"
    }
    $dorksDisplay | Set-Content -Path $tempFile

    $fzfCommand = "cat $tempFile | fzf --height 50% --layout=reverse --border --ansi --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,info:#8ec07c,pointer:#fb4934,marker:#fabd2f,header:#8ec07c,spinner:#fe8019 --pointer='>' --marker='+' --header='Google Dorks Listesi' --prompt='Dork Seçimi: '"
    $result = Invoke-Expression $fzfCommand
    Remove-Item $tempFile

    if ($result) {
        $selectedDorkKey = $result.Split(" - ")[0]
        if ($selectedDorkKey -match '{{.*?}}') {
            $selectedDorkKey = Replace-Placeholders $selectedDorkKey
        }

        # Arama motoru seçimi
        $engineChoice = Read-Host "Hangi arama motorunu kullanmak istersiniz? (1: Google [varsayılan], 2: Bing, 3: DuckDuckGo)"
        switch ($engineChoice) {
            "2" { $baseUrl = "https://www.bing.com/search?q=" }
            "3" { $baseUrl = "https://duckduckgo.com/?q=" }
            default { $baseUrl = "https://www.google.com/search?q=" }
        }

        $selectedDorkDescription = $googleDorks[$selectedDorkKey]
        if (-not $selectedDorkDescription) {
            $selectedDorkDescription = "Dinamik placeholder'lar içeren dork seçildi."
        }

        # Seçilen dork'ta geçen operatörlerin detaylı açıklamalarını hazırlamak için
        $operatorDetails = @{
            "site:"    = "site: operatörü, belirli bir site veya alan adı üzerinde arama yapmanızı sağlar. Örneğin: site:example.com"
            "intitle:" = "intitle: operatörü, sayfa başlığında arama yapmanızı sağlar. Örneğin: intitle:index.of"
            "inurl:"   = "inurl: operatörü, URL içerisinde arama yapmanızı sağlar. Örneğin: inurl:admin"
            "filetype:"= "filetype: operatörü, belirli dosya türlerini aramanızı sağlar. Örneğin: filetype:pdf"
            "intext:"  = "intext: operatörü, sayfa içeriğinde arama yapmanızı sağlar. Örneğin: intext:password"
            "ext:"     = "ext: operatörü, dosya uzantısı bazında arama yapmanızı sağlar. Örneğin: ext:sql"
        }
        $detailedInfo = ""
        foreach ($op in $operatorDetails.Keys) {
            if ($selectedDorkKey -match [regex]::Escape($op)) {
                $detailedInfo += "`nDetay ($op): " + $operatorDetails[$op]
            }
        }

        Write-Output "`n`n`e[32mSeçilen Dork:`e[0m $selectedDorkKey"
        Write-Output "`e[32mAçıklama:   `e[0m $selectedDorkDescription"
        if ($detailedInfo -ne "") {
            Write-Output "`n`e[33mDetaylar:$detailedInfo`e[0m"
        }

        $encodedDork = [uri]::EscapeDataString($selectedDorkKey)
        $exampleUsage = "$baseUrl$encodedDork"
        Write-Output "`n`e[32mÖrnek Kullanım:`e[0m $exampleUsage"
    }
    else {
        Write-Output "`n`e[31mHerhangi bir seçim yapılmadı. İşlem iptal edildi.`e[0m"
    }
}

Set-Alias -Name dork -Value Show-GoogleDorkMenu
