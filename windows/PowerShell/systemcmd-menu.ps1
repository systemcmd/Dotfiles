function New-SystemCmdMenuEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section,

        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Usage,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [string]$ActionKey = 'info',
        [string]$Example = '',
        [string]$Note = ''
    )

    [PSCustomObject]@{
        Section     = $Section
        Label       = $Label
        Usage       = $Usage
        Description = $Description
        ActionKey   = $ActionKey
        Example     = $Example
        Note        = $Note
    }
}

function Get-SystemCmdMenuSectionOrder {
    return @{
        Main     = 0
        Search   = 1
        Files    = 2
        Network  = 3
        Hardware = 4
        Alias    = 5
        Editor   = 6
        Theme    = 7
        Windows  = 8
        Hacking  = 9
    }
}

function Get-SystemCmdMenuSectionColor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section
    )

    switch ($Section) {
        'Main' { return '81' }
        'Search' { return '110' }
        'Files' { return '214' }
        'Network' { return '39' }
        'Hardware' { return '179' }
        'Alias' { return '141' }
        'Editor' { return '45' }
        'Theme' { return '171' }
        'Windows' { return '75' }
        'Hacking' { return '196' }
        default { return '245' }
    }
}

function Get-SystemCmdMenuSectionConsoleColor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section
    )

    switch ($Section) {
        'Main' { return 'Cyan' }
        'Search' { return 'Blue' }
        'Files' { return 'Yellow' }
        'Network' { return 'Green' }
        'Hardware' { return 'DarkYellow' }
        'Alias' { return 'Magenta' }
        'Editor' { return 'Cyan' }
        'Theme' { return 'DarkMagenta' }
        'Windows' { return 'Blue' }
        'Hacking' { return 'Red' }
        default { return 'Gray' }
    }
}

function Get-SystemCmdMenuSectionIcon {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section
    )

    switch ($Section) {
        'Main'     { return [char]0x25C6 }   # ◆
        'Search'   { return [char]0x2726 }   # ✦
        'Files'    { return [char]0x25A3 }   # ▣
        'Network'  { return [char]0x25C9 }   # ◉
        'Hardware' { return [char]0x2B21 }   # ⬡
        'Alias'    { return [char]0x2261 }   # ≡
        'Editor'   { return [char]0x25C7 }   # ◇
        'Theme'    { return [char]0x25C8 }   # ◈
        'Windows'  { return [char]0x229E }   # ⊞
        'Hacking'  { return [char]0x25CE }   # ◎
        default    { return [char]0x00B7 }   # ·
    }
}

function Add-SystemCmdMenuEntryIfCommandExists {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[object]]$Entries,

        [Parameter(Mandatory = $true)]
        [string]$CommandName,

        [Parameter(Mandatory = $true)]
        [string]$Section,

        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Usage,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [string]$ActionKey,
        [string]$Example = '',
        [string]$Note = ''
    )

    if (-not (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($ActionKey)) {
        $ActionKey = 'command:{0}' -f $CommandName
    }

    $Entries.Add(
        (New-SystemCmdMenuEntry -Section $Section -Label $Label -Usage $Usage -Description $Description -ActionKey $ActionKey -Example $Example -Note $Note)
    )
}

function Get-SystemCmdMenuEntries {
    $entries = [System.Collections.Generic.List[object]]::new()

    $entries.Add((New-SystemCmdMenuEntry -Section 'Main' -Label 'systemcmd' -Usage 'systemcmd' -Description 'Bolmeli komut menusunu acar.' -Example 'systemcmd'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Main' -Label 'doctor' -Usage 'systemcmd doctor' -Description 'Kurulum, tema ve arac sagligini kontrol eder.' -ActionKey 'doctor' -Example 'systemcmd doctor'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Main' -Label 'cloudhelp' -Usage 'cloudhelp' -Description '✶ Claude Code icin interaktif Turkce referans menusu acar.' -ActionKey 'command:cloudhelp' -Example 'cloudhelp'))

    $entries.Add((New-SystemCmdMenuEntry -Section 'Search' -Label 'Ctrl+f' -Usage 'Ctrl+f' -Description 'Hizli dosya seciciyi acar ve secilen yolu satira yazar.' -Example 'Bir yol yazip Ctrl+f' -Note 'Bir klasor yolu yaziliysa o klasorun icini listeler.'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Search' -Label 'Ctrl+r' -Usage 'Ctrl+r' -Description 'Favorili gecmis aramasini acar.' -Example 'Ctrl+r -> F -> Enter' -Note 'F: favori ac/kapat.'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Search' -Label 'Ctrl+d' -Usage 'Ctrl+d' -Description 'Imlecin altindaki karakteri siler.' -Example 'Ctrl+d'))

    $entries.Add((New-SystemCmdMenuEntry -Section 'Files' -Label 'll' -Usage 'll [path]' -Description 'Gizli dosyalar dahil klasor listeler.' -ActionKey 'command:ll' -Example 'll C:\Windows'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Files' -Label 'rmrf' -Usage 'rmrf <path>' -Description 'Dosya veya klasoru zorla siler.' -ActionKey 'command:rmrf' -Example 'rmrf .\temp' -Note 'Dikkat: kalici silme yapar.'))
    $entries.Add((New-SystemCmdMenuEntry -Section 'Files' -Label 'which' -Usage 'which <komut>' -Description 'Komutun gercek yolunu gosterir.' -ActionKey 'command:which' -Example 'which git'))

    $entries.Add((New-SystemCmdMenuEntry -Section 'Network' -Label 'Show-Ports' -Usage 'Show-Ports' -Description 'Acik portlari listeler.' -ActionKey 'ports' -Example 'Show-Ports'))

    Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'system' -Section 'Alias' -Label 'system' -Usage 'system' -Description 'systemcmd aliasidir.' -ActionKey 'info' -Example 'system'
    Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'c' -Section 'Alias' -Label 'c / sil' -Usage 'c  |  sil' -Description 'Terminal ekranini temizler.' -ActionKey 'info' -Example 'c'
    Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'st' -Section 'Alias' -Label 'st' -Usage 'st <komut | dosya>' -Description 'Start-Process kisayoludur.' -ActionKey 'info' -Example 'st notepad.exe'

    if (Test-SystemCmdCommand 'nvim') {
        $entries.Add((New-SystemCmdMenuEntry -Section 'Editor' -Label 'nvim' -Usage 'nvim [dosya]' -Description 'Neovim acilir.' -ActionKey 'command:nvim' -Example 'nvim README.md'))
    }

    Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'vim' -Section 'Alias' -Label 'vim' -Usage 'vim [dosya]' -Description 'Neovim aliasidir.' -ActionKey 'info' -Example 'vim init.lua'

    if (Get-SystemCmdThemeBuildScriptPath) {
        $entries.Add((New-SystemCmdMenuEntry -Section 'Theme' -Label 'theme build' -Usage 'systemcmd theme build' -Description 'Tek kaynak paletten VS Code, Neovim ve shell temalarini uretir.' -ActionKey 'theme-build' -Example 'systemcmd theme build'))
    }

    if ($script:SystemCmdIsWindows) {
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'ifconfig' -Section 'Network' -Label 'ifconfig' -Usage 'ifconfig' -Description 'ipconfig kisayoludur.' -ActionKey 'command:ipconfig' -Example 'ifconfig'
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'ip' -Section 'Network' -Label 'ip' -Usage 'ip [-SadeceIcIP] [-SadeceDisIP]' -Description 'Ic ve dis IP bilgilerini gosterir.' -Example 'ip -SadeceDisIP'
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'wn' -Section 'Alias' -Label 'wn' -Usage 'wn <args>' -Description 'winget kisayoludur.' -ActionKey 'info' -Example 'wn search neovim'
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'tig' -Section 'Alias' -Label 'tig' -Usage 'tig' -Description 'Terminal tabanli git arayuzunu acar.' -ActionKey 'info' -Example 'tig'
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'less' -Section 'Alias' -Label 'less' -Usage 'less <dosya>' -Description 'Dosyayi terminalde sayfali gosterir.' -ActionKey 'info' -Example 'less README.md'
        Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'csc' -Section 'Alias' -Label 'csc' -Usage 'csc <args>' -Description '.NET Framework C# derleyicisini calistirir.' -ActionKey 'info' -Example 'csc Program.cs'

        $hardwareEntries = @(
            @{ CommandName = 'Ram';  Label = 'Ram';  Usage = 'Ram';  Description = '🧠 RAM kullanimini ve en cok bellek kullanan surecleri gosterir.'; Example = 'Ram';  Note = '' },
            @{ CommandName = 'CPU';  Label = 'CPU';  Usage = 'CPU';  Description = '⚡ CPU kullanimini, uptime bilgisini ve agir surecleri gosterir.'; Example = 'CPU';  Note = '' },
            @{ CommandName = 'GPU';  Label = 'GPU';  Usage = 'GPU';  Description = '🎮 GPU kullanimini ve bellek ozetini gosterir.'; Example = 'GPU';  Note = 'Detayli bilgi icin nvidia-smi gerekir.' },
            @{ CommandName = 'Disk'; Label = 'Disk'; Usage = 'Disk'; Description = '💾 Disklerin doluluk ve kullanilabilir alan durumunu gosterir.'; Example = 'Disk'; Note = '' },
            @{ CommandName = 'Pil';  Label = 'Pil';  Usage = 'Pil';  Description = '🔋 Pil yuzdesi, kalan sure ve sarj durumunu gosterir.'; Example = 'Pil';  Note = 'Genelde laptoplarda anlamlidir.' },
            @{ CommandName = 'bios'; Label = 'bios'; Usage = 'bios'; Description = '⚙️ BIOS surumu ve temel donanim bilgilerini gosterir.'; Example = 'bios'; Note = '' }
        )

        foreach ($entry in $hardwareEntries) {
            Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName $entry.CommandName -Section 'Hardware' -Label $entry.Label -Usage $entry.Usage -Description $entry.Description -Example $entry.Example -Note $entry.Note
        }

        $windowsEntries = @(
            @{ Label = 'dockerhelp'; Usage = 'dockerhelp'; Description = 'Docker interaktif referans — konteyner, imaj, compose, ag, volume.'; Example = 'dockerhelp'; Note = '' },
            @{ Label = 'crypto'; Usage = 'crypto'; Description = 'Kripto kaynak menusunu acir.'; Example = 'crypto'; Note = '' },
            @{ Label = 'pentestmenu'; Usage = 'pentestmenu'; Description = 'Pentest baglantilarini gosterir.'; Example = 'pentestmenu'; Note = '' },
            @{ Label = 'blueteam'; Usage = 'blueteam'; Description = 'BlueTeam notlarini acir.'; Example = 'blueteam'; Note = '' },
            @{ Label = 'redteam'; Usage = 'redteam'; Description = 'RedTeam notlarini acir.'; Example = 'redteam'; Note = '' },
            @{ Label = 'nmp'; Usage = 'nmp'; Description = 'Nmap komut menusunu acir.'; Example = 'nmp'; Note = '' },
            @{ Label = 'ctl'; Usage = 'ctl'; Description = 'systemctl ve journalctl yardimini gosterir.'; Example = 'ctl'; Note = '' },
            @{ Label = 'ncatmenu'; Usage = 'ncatmenu'; Description = 'Ncat komut menusunu acir.'; Example = 'ncatmenu'; Note = '' },
            @{ Label = 'hc'; Usage = 'hc'; Description = 'Hashcat menusunu acir.'; Example = 'hc'; Note = '' },
            @{ Label = 'msf'; Usage = 'msf'; Description = 'Metasploit menusunu acir.'; Example = 'msf'; Note = '' },
            @{ Label = 'dork'; Usage = 'dork'; Description = 'Google dork menusunu acir.'; Example = 'dork'; Note = '' },
            @{ Label = 'ascii'; Usage = 'ascii <metin>'; Description = 'Metni ASCII koda cevirir.'; Example = 'ascii systemcmd'; Note = '' },
            @{ Label = 'sistemarac'; Usage = 'sistemarac'; Description = 'Sag tik sistem araclarini acar.'; Example = 'sistemarac'; Note = '' },
            @{ Label = 'adminhck'; Usage = 'adminhck'; Description = 'Dosya sahipligini almaya yardim eder.'; Example = 'adminhck'; Note = '' },
            @{ Label = 'para'; Usage = 'para'; Description = 'Finansal hesaplama aracini acir.'; Example = 'para'; Note = '' }
        )

        foreach ($entry in $windowsEntries) {
            Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName $entry.Label -Section 'Windows' -Label $entry.Label -Usage $entry.Usage -Description $entry.Description -Example $entry.Example -Note $entry.Note
        }
    }

    Add-SystemCmdMenuEntryIfCommandExists -Entries $entries -CommandName 'Show-20Hack' `
        -Section 'Hacking' -Label '20hack' -Usage 'hack' `
        -Description '20 hacking teknigi — kesi, web, parola, exploit, ag interaktif referans.' `
        -ActionKey 'command:Show-20Hack' `
        -Example 'hack'

    $sectionOrder = Get-SystemCmdMenuSectionOrder
    return $entries.ToArray() | Sort-Object @{ Expression = { $sectionOrder[$_.Section] } }, Usage
}

function Show-SystemCmdEntryCard {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Entry
    )

    $line = '─' * 74

    Write-Host ''
    Write-Host $line -ForegroundColor DarkGray
    Write-Host ('[{0}] {1}' -f $Entry.Section.ToUpperInvariant(), $Entry.Label) -ForegroundColor Cyan
    Write-Host ('Kullanim : {0}' -f $Entry.Usage) -ForegroundColor White
    Write-Host ('Aciklama : {0}' -f $Entry.Description) -ForegroundColor Gray

    if (-not [string]::IsNullOrWhiteSpace($Entry.Example)) {
        Write-Host ('Ornek    : {0}' -f $Entry.Example) -ForegroundColor DarkGray
    }

    if (-not [string]::IsNullOrWhiteSpace($Entry.Note)) {
        Write-Host ('Not      : {0}' -f $Entry.Note) -ForegroundColor DarkYellow
    }

    Write-Host $line -ForegroundColor DarkGray
    Write-Host ''
}

function Invoke-SystemCmdMenuEntry {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Entry
    )

    switch ($Entry.ActionKey) {
        'doctor' { Show-SystemCmdDoctor; return }
        'ports' { Show-Ports; return }
        'theme-build' { Invoke-SystemCmdThemeBuild; return }
        'info' { Show-SystemCmdEntryCard -Entry $Entry; return }
        default {
            if ($Entry.ActionKey -like 'command:*') {
                $commandName = $Entry.ActionKey.Substring(8)
                & $commandName
                return
            }

            Show-SystemCmdEntryCard -Entry $Entry
        }
    }
}

function Show-SystemCmdFallbackHelp {
    $entries = Get-SystemCmdMenuEntries
    $sectionOrder = Get-SystemCmdMenuSectionOrder
    $usageWidth = [Math]::Max((($entries | ForEach-Object { $_.Usage.Length } | Measure-Object -Maximum).Maximum), 24)
    $headerFormat = '  {0,-' + $usageWidth + '}  {1}'
    $rowFormat = '  {0,-' + $usageWidth + '}  '

    Write-Host ''
    Write-Host 'systemcmd' -ForegroundColor Cyan
    Write-Host 'Tum komutlar bolumlere ayrildi. Menude yazmaya basla, filtrele ve Enter ile calistir.' -ForegroundColor DarkGray
    Write-Host ''

    $groups = $entries |
        Group-Object Section |
        Sort-Object { $sectionOrder[$_.Name] }

    foreach ($group in $groups) {
        $sectionColor = Get-SystemCmdMenuSectionConsoleColor -Section $group.Name
        $sectionIcon  = Get-SystemCmdMenuSectionIcon -Section $group.Name
        Write-Host ('{0} {1}  {2} komut' -f $sectionIcon, $group.Name, $group.Count) -ForegroundColor $sectionColor
        Write-Host (($headerFormat) -f 'KULLANIM', 'NE YAPAR') -ForegroundColor DarkGray

        foreach ($entry in $group.Group | Sort-Object Usage) {
            Write-Host (($rowFormat) -f $entry.Usage) -ForegroundColor White -NoNewline
            Write-Host $entry.Description -ForegroundColor Gray

            if (-not [string]::IsNullOrWhiteSpace($entry.Note)) {
                Write-Host (($rowFormat) -f '') -ForegroundColor White -NoNewline
                Write-Host ('Not: {0}' -f $entry.Note) -ForegroundColor DarkYellow
            }
        }

        Write-Host ''
    }
}

function Show-SystemCmdTuiMenu {
    if (-not (Test-SystemCmdCommand 'fzf')) {
        Show-SystemCmdFallbackHelp
        return
    }

    $entries = Get-SystemCmdMenuEntries
    if (-not $entries -or $entries.Count -eq 0) {
        Show-SystemCmdFallbackHelp
        return
    }

    $summary = Get-SystemCmdDoctorSummary
    $usageWidth = [Math]::Max((($entries | ForEach-Object { $_.Usage.Length } | Measure-Object -Maximum).Maximum), 18)
    $sectionOrder = Get-SystemCmdMenuSectionOrder
    $sectionSummary = (
        $entries |
            Group-Object Section |
            Sort-Object { $sectionOrder[$_.Name] } |
            ForEach-Object {
                $ic = Get-SystemCmdMenuSectionIcon -Section $_.Name
                '{0} {1}:{2}' -f $ic, $_.Name, $_.Count
            }
    ) -join '  '

    $headerLines = @(
        'Tum komutlar burada. Yazmaya basla ve filtrele.',
        ('Bolumler: {0}' -f $sectionSummary),
        ('Enter: calistir veya bilgi ac | Esc: cik | doctor: {0} ok / {1} warn' -f $summary.Ok, $summary.Warn)
    )
    $headerText = ($headerLines -join [Environment]::NewLine)

    $items = for ($index = 0; $index -lt $entries.Count; $index++) {
        $entry = $entries[$index]
        $sectionColor = Get-SystemCmdMenuSectionColor -Section $entry.Section
        $sectionIcon  = Get-SystemCmdMenuSectionIcon -Section $entry.Section
        $display = (
            "`e[38;5;{0}m{1}`e[0m  `e[97m{2,-$usageWidth}`e[0m `e[38;5;245m{3}`e[0m" -f
            $sectionColor,
            $sectionIcon,
            $entry.Usage,
            $entry.Description
        )

        [string]::Join(
            [char]9,
            @(
                [string]$index
                [string]$entry.Section
                [string]$entry.Label
                [string]$entry.Usage
                [string]$entry.Description
                [string]$display
            )
        )
    }

    $selection = $items | & fzf `
        --delimiter "`t" `
        --with-nth 6 `
        --prompt 'systemcmd > ' `
        --header $headerText `
        --layout reverse `
        --border `
        --ansi `
        --color (Get-SystemCmdFzfColorOption)

    if ([string]::IsNullOrWhiteSpace($selection)) {
        return
    }

    $selectedIndexText = ($selection -split "`t", 2)[0].Trim()
    $selectedIndex = -1
    if (-not [int]::TryParse($selectedIndexText, [ref]$selectedIndex)) {
        Write-Host ("systemcmd menu secimi cozulmedi: {0}" -f $selection) -ForegroundColor Yellow
        return
    }

    if ($selectedIndex -lt 0 -or $selectedIndex -ge $entries.Count) {
        Write-Host ("systemcmd menu indeksi gecersiz: {0}" -f $selectedIndex) -ForegroundColor Yellow
        return
    }

    Invoke-SystemCmdMenuEntry -Entry $entries[$selectedIndex]
}
