function Get-SystemCmdThemeBuildScriptPath {
    $candidates = @(
        (Join-Path $script:SystemCmdRoot 'theme\Build-SystemCmdTheme.ps1'),
        (Join-Path $script:SystemCmdRoot 'Dotfiles\theme\Build-SystemCmdTheme.ps1'),
        (Join-Path (Split-Path -Parent $script:SystemCmdRoot) 'Dotfiles\theme\Build-SystemCmdTheme.ps1')
    ) | Select-Object -Unique

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Invoke-SystemCmdThemeBuild {
    $buildScript = Get-SystemCmdThemeBuildScriptPath
    if (-not $buildScript) {
        Write-Host 'systemcmd theme build icin kaynak script bulunamadi.' -ForegroundColor Yellow
        return
    }

    try {
        & $buildScript
    } catch {
        Write-Host ("Tema build hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function New-SystemCmdDoctorEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [bool]$Healthy,

        [Parameter(Mandatory = $true)]
        [string]$Detail
    )

    [PSCustomObject]@{
        Name    = $Name
        Healthy = $Healthy
        Detail  = $Detail
    }
}

function Get-SystemCmdCommandDetail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) {
        return 'Bulunamadi'
    }

    foreach ($propertyName in 'Source', 'Path', 'Definition') {
        $property = $command.PSObject.Properties[$propertyName]
        if ($property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [string]$property.Value
        }
    }

    return $command.CommandType.ToString()
}

function Get-SystemCmdDoctorEntries {
    $entries = @()
    $entries += New-SystemCmdDoctorEntry -Name 'systemcmd root' -Healthy (Test-Path -LiteralPath $script:SystemCmdRoot) -Detail $script:SystemCmdRoot
    $entries += New-SystemCmdDoctorEntry -Name 'PowerShell' -Healthy $true -Detail $PSVersionTable.PSVersion.ToString()
    $entries += New-SystemCmdDoctorEntry -Name 'fzf' -Healthy (Test-SystemCmdCommand 'fzf') -Detail ($(if (Test-SystemCmdCommand 'fzf') { Get-SystemCmdCommandDetail 'fzf' } else { 'Bulunamadi' }))
    $entries += New-SystemCmdDoctorEntry -Name 'bat' -Healthy ((Test-SystemCmdCommand 'bat') -or (Test-SystemCmdCommand 'batcat')) -Detail ($(if (Test-SystemCmdCommand 'bat') { Get-SystemCmdCommandDetail 'bat' } elseif (Test-SystemCmdCommand 'batcat') { Get-SystemCmdCommandDetail 'batcat' } else { 'Bulunamadi' }))
    $entries += New-SystemCmdDoctorEntry -Name 'Neovim' -Healthy (Test-SystemCmdCommand 'nvim') -Detail ($(if (Test-SystemCmdCommand 'nvim') { Get-SystemCmdCommandDetail 'nvim' } else { 'Bulunamadi' }))
    $entries += New-SystemCmdDoctorEntry -Name 'PSReadLine' -Healthy ([bool](Get-Module -ListAvailable -Name PSReadLine)) -Detail ($(if (Get-Module -ListAvailable -Name PSReadLine) { 'Yuklu' } else { 'Bulunamadi' }))
    $entries += New-SystemCmdDoctorEntry -Name 'PSFzf' -Healthy ([bool](Get-Module -ListAvailable -Name PSFzf)) -Detail ($(if (Get-Module -ListAvailable -Name PSFzf) { 'Yuklu' } else { 'Bulunamadi' }))
    $entries += New-SystemCmdDoctorEntry -Name 'Terminal-Icons' -Healthy ([bool](Get-Module -ListAvailable -Name Terminal-Icons)) -Detail ($(if (Get-Module -ListAvailable -Name Terminal-Icons) { 'Yuklu' } else { 'Bulunamadi' }))

    $themeGeneratedPath = Join-Path $script:SystemCmdRoot 'systemcmd-theme.generated.ps1'
    $entries += New-SystemCmdDoctorEntry -Name 'Theme runtime' -Healthy (Test-Path -LiteralPath $themeGeneratedPath) -Detail $themeGeneratedPath

    $themeBuildScript = Get-SystemCmdThemeBuildScriptPath
    $entries += New-SystemCmdDoctorEntry -Name 'Theme build' -Healthy ([bool]$themeBuildScript) -Detail ($(if ($themeBuildScript) { $themeBuildScript } else { 'Bulunamadi' }))

    $nvimConfigPath = if ($script:SystemCmdIsWindows) {
        Join-Path $env:LOCALAPPDATA 'nvim\init.lua'
    } else {
        Join-Path $HOME '.config/nvim/init.lua'
    }
    $entries += New-SystemCmdDoctorEntry -Name 'Neovim config' -Healthy (Test-Path -LiteralPath $nvimConfigPath) -Detail $nvimConfigPath

    $favoritesPath = if ($env:SYSTEMCMD_HISTORY_FAVORITES_PATH) {
        $env:SYSTEMCMD_HISTORY_FAVORITES_PATH
    } elseif ($script:SystemCmdIsWindows) {
        Join-Path $HOME '.systemcmd-history-favorites.json'
    } else {
        Join-Path $HOME '.systemcmd-history-favorites.json'
    }
    $entries += New-SystemCmdDoctorEntry -Name 'Favorites store' -Healthy $true -Detail $favoritesPath

    if ($script:SystemCmdIsWindows) {
        $vsCodeTargets = @(
            (Join-Path $env:USERPROFILE '.vscode\extensions\systemcmd.systemcmd-color\package.json'),
            (Join-Path $env:USERPROFILE '.vscode-insiders\extensions\systemcmd.systemcmd-color\package.json'),
            (Join-Path $env:USERPROFILE '.vscode-oss\extensions\systemcmd.systemcmd-color\package.json')
        )
        $themeInstalled = $vsCodeTargets | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        $entries += New-SystemCmdDoctorEntry -Name 'VS Code theme' -Healthy ([bool]$themeInstalled) -Detail ($(if ($themeInstalled) { $themeInstalled } else { 'Bulunamadi' }))
    }

    return $entries
}

function Show-SystemCmdDoctor {
    $entries = Get-SystemCmdDoctorEntries
    $okCount = ($entries | Where-Object Healthy).Count
    $warnCount = ($entries.Count - $okCount)

    Write-Host ''
    Write-Host 'systemcmd doctor' -ForegroundColor Cyan
    Write-Host ''

    foreach ($entry in $entries) {
        $statusText = if ($entry.Healthy) { 'OK  ' } else { 'WARN' }
        $statusColor = if ($entry.Healthy) { 'Green' } else { 'Yellow' }
        Write-Host $statusText -ForegroundColor $statusColor -NoNewline
        Write-Host (" {0,-16} {1}" -f $entry.Name, $entry.Detail)
    }

    Write-Host ''
    Write-Host ("Toplam: {0} OK, {1} WARN" -f $okCount, $warnCount) -ForegroundColor DarkGray
}

function Get-SystemCmdDoctorSummary {
    $entries = Get-SystemCmdDoctorEntries
    [PSCustomObject]@{
        Ok   = ($entries | Where-Object Healthy).Count
        Warn = ($entries | Where-Object { -not $_.Healthy }).Count
    }
}

function Get-SystemCmdMenuEntries {
    $entries = @(
        [PSCustomObject]@{ Section = 'Core'; Label = 'doctor'; Description = 'Kurulum, tema ve arac sagligini kontrol eder.'; ActionKey = 'doctor' },
        [PSCustomObject]@{ Section = 'Tools'; Label = 'ports'; Description = 'Acik portlari listeler.'; ActionKey = 'ports' }
    )

    if (Test-SystemCmdCommand 'nvim') {
        $entries += [PSCustomObject]@{ Section = 'Editor'; Label = 'nvim'; Description = 'Neovim acilir.'; ActionKey = 'command:nvim' }
    }

    if (Get-SystemCmdThemeBuildScriptPath) {
        $entries += [PSCustomObject]@{ Section = 'Theme'; Label = 'theme build'; Description = 'Tek kaynak paletten VS Code, Neovim ve shell temalarini uretir.'; ActionKey = 'theme-build' }
    }

    if ($script:SystemCmdIsWindows) {
        $windowsEntries = @(
            @{ Label = 'bios'; Description = 'BIOS ve donanim bilgilerini gosterir.' },
            @{ Label = 'ip'; Description = 'IP ozetini gosterir.' },
            @{ Label = 'ascii'; Description = 'Metni ASCII koda cevirir.' },
            @{ Label = 'dockerhelp'; Description = 'Docker komut notlarini gosterir.' },
            @{ Label = 'nmp'; Description = 'Nmap komut menusunu acir.' },
            @{ Label = 'ncatmenu'; Description = 'Ncat komut menusunu acir.' },
            @{ Label = 'blueteam'; Description = 'BlueTeam notlarini acir.' },
            @{ Label = 'redteam'; Description = 'RedTeam notlarini acir.' },
            @{ Label = 'crypto'; Description = 'Kripto kaynak menusunu acir.' },
            @{ Label = 'para'; Description = 'Finansal hesaplama aracini acir.' }
        )

        foreach ($entry in $windowsEntries) {
            if (Get-Command -Name $entry.Label -ErrorAction SilentlyContinue) {
                $entries += [PSCustomObject]@{
                    Section     = 'Windows'
                    Label       = $entry.Label
                    Description = $entry.Description
                    ActionKey   = ('command:{0}' -f $entry.Label)
                }
            }
        }
    }

    return $entries
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
        default {
            if ($Entry.ActionKey -like 'command:*') {
                $commandName = $Entry.ActionKey.Substring(8)
                & $commandName
            }
        }
    }
}

function Show-SystemCmdFallbackHelp {
    Write-Host ''
    Write-Host 'systemcmd' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  systemcmd          : Ana menuyu acar.' -ForegroundColor Gray
    Write-Host '  systemcmd doctor   : Kurulum ve arac sagligini kontrol eder.' -ForegroundColor Gray
    Write-Host '  systemcmd theme build : Tema dosyalarini yeniden uretir.' -ForegroundColor Gray
    Write-Host '  Ctrl+f             : Hizli dosya secici.' -ForegroundColor Gray
    Write-Host '  Ctrl+r             : Favorili gecmis aramasi, F ile yildizla.' -ForegroundColor Gray
    Write-Host ''
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
    $labelWidth = [Math]::Max((($entries | ForEach-Object { $_.Label.Length } | Measure-Object -Maximum).Maximum), 6)
    $headerLines = @(
        'Enter: calistir | Esc: cik',
        ('Ctrl+f: dosya | Ctrl+r: history | doctor: {0} ok / {1} warn' -f $summary.Ok, $summary.Warn)
    )
    $headerText = ($headerLines -join [Environment]::NewLine)

    $items = for ($index = 0; $index -lt $entries.Count; $index++) {
        $entry = $entries[$index]
        $sectionColor = switch ($entry.Section) {
            'Core' { '36' }
            'Tools' { '214' }
            'Editor' { '45' }
            'Theme' { '171' }
            'Windows' { '39' }
            default { '245' }
        }

        $display = (
            "`e[38;5;{0}m[{1}]`e[0m `e[97m{2,-$labelWidth}`e[0m `e[38;5;245m{3}`e[0m" -f
            $sectionColor,
            $entry.Section.ToUpperInvariant(),
            $entry.Label,
            $entry.Description
        )

        [string]::Join(
            [char]9,
            @(
                [string]$index
                [string]$entry.Section
                [string]$entry.Label
                [string]$entry.Description
                [string]$display
            )
        )
    }

    $selection = $items | & fzf `
        --delimiter "`t" `
        --with-nth 5 `
        --nth 2,3,4,5 `
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
