[CmdletBinding()]
param(
    [string]$SourceDir
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "[systemcmd] $Message" -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Message)
    Write-Warning "[systemcmd] $Message"
}

function Resolve-InstallSource {
    param([string]$PreferredPath)

    if ($PreferredPath -and (Test-Path -LiteralPath $PreferredPath)) {
        return (Resolve-Path -LiteralPath $PreferredPath).Path
    }

    if ($PSScriptRoot) {
        $repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
        if (Test-Path -LiteralPath (Join-Path $repoRoot 'windows\PowerShell\Microsoft.PowerShell_profile.ps1')) {
            return $repoRoot.Path
        }
    }

    $tempRoot = Join-Path $env:TEMP ('systemcmd-dotfiles-' + [guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    if (Get-Command -Name git.exe -ErrorAction SilentlyContinue) {
        Write-Step 'Git ile kaynak dosyalar indiriliyor.'
        & git.exe clone --depth 1 https://github.com/systemcmd/Dotfiles.git $tempRoot | Out-Null
        return $tempRoot
    }

    $archivePath = Join-Path $env:TEMP 'systemcmd-dotfiles.zip'
    Write-Step 'Zip arsivi indiriliyor.'
    Invoke-WebRequest -Uri 'https://github.com/systemcmd/Dotfiles/archive/refs/heads/main.zip' -OutFile $archivePath
    Expand-Archive -Path $archivePath -DestinationPath $tempRoot -Force

    $expandedRoot = Get-ChildItem -LiteralPath $tempRoot -Directory | Select-Object -First 1
    if (-not $expandedRoot) {
        throw 'Kaynak dosyalar indirilemedi.'
    }

    return $expandedRoot.FullName
}

function Ensure-WinGetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Command -Name winget.exe -ErrorAction SilentlyContinue)) {
        Write-Warn "winget bulunamadi, $Name otomatik yuklenemedi."
        return
    }

    Write-Step "$Name kontrol ediliyor."
    try {
        & winget.exe install --id $Id --exact --silent --accept-source-agreements --accept-package-agreements 1>$null
    } catch {
        Write-Warn "$Name kurulumu tamamlanamadi: $($_.Exception.Message)"
    }
}

function Ensure-PSGalleryModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$PwshPath
    )

    if ($PwshPath) {
        $installCommand = @"
`$moduleName = '$Name'
if (-not (Get-Module -ListAvailable -Name `$moduleName)) {
    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }

    if (Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }

    Install-Module -Name `$moduleName -Scope CurrentUser -Force -AllowClobber
}
"@

        Write-Step "$Name modulu PowerShell 7 icin yukleniyor."
        try {
            & $PwshPath -NoLogo -NoProfile -Command $installCommand
        } catch {
            Write-Warn "$Name modulu yuklenemedi: $($_.Exception.Message)"
        }
        return
    }

    if (Get-Module -ListAvailable -Name $Name) {
        return
    }

    if (-not (Get-Command -Name Install-Module -ErrorAction SilentlyContinue)) {
        Write-Warn "Install-Module bulunamadi, $Name atlandi."
        return
    }

    try {
        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        }
    } catch {
        Write-Warn "NuGet saglayicisi kurulurken hata olustu: $($_.Exception.Message)"
    }

    try {
        if (Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue) {
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        }
    } catch {}

    Write-Step "$Name modulu yukleniyor."
    try {
        Install-Module -Name $Name -Scope CurrentUser -Force -AllowClobber
    } catch {
        Write-Warn "$Name modulu yuklenemedi: $($_.Exception.Message)"
    }
}

function Ensure-ProfileBootstrap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProfilePath,

        [Parameter(Mandatory = $true)]
        [string]$BootstrapBlock
    )

    $profileDir = Split-Path -Parent $ProfilePath
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $backupPattern = 'function SystemCmd|systemcmd bootstrap|MEVCUT KOMUTLAR VE FONKSIYONLAR'

    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        Set-Content -LiteralPath $ProfilePath -Value $BootstrapBlock -Encoding UTF8
        return
    }

    $content = Get-Content -LiteralPath $ProfilePath -Raw
    if ($content -match 'systemcmd bootstrap') {
        Set-Content -LiteralPath $ProfilePath -Value $BootstrapBlock -Encoding UTF8
        return
    }

    if ($content -match $backupPattern) {
        $backupPath = '{0}.bak-{1}' -f $ProfilePath, (Get-Date -Format 'yyyyMMddHHmmss')
        Copy-Item -LiteralPath $ProfilePath -Destination $backupPath -Force
        Set-Content -LiteralPath $ProfilePath -Value $BootstrapBlock -Encoding UTF8
        return
    }

    Add-Content -LiteralPath $ProfilePath -Value ("`r`n" + $BootstrapBlock) -Encoding UTF8
}

function Resolve-PwshPath {
    $candidate = Get-Command -Name pwsh.exe -ErrorAction SilentlyContinue
    if ($candidate) {
        return $candidate.Source
    }

    $fallback = 'C:\Program Files\PowerShell\7\pwsh.exe'
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    return $null
}

$resolvedSourceDir = Resolve-InstallSource -PreferredPath $SourceDir
$windowsSourceDir = Join-Path $resolvedSourceDir 'windows\PowerShell'

if (-not (Test-Path -LiteralPath (Join-Path $windowsSourceDir 'Microsoft.PowerShell_profile.ps1'))) {
    throw 'PowerShell profil dosyalari bulunamadi.'
}

$documentsDir = [Environment]::GetFolderPath('MyDocuments')
$installRoot = Join-Path $documentsDir 'PowerShell\systemcmd'
$pwshProfilePath = Join-Path $documentsDir 'PowerShell\Microsoft.PowerShell_profile.ps1'
$legacyProfilePath = Join-Path $documentsDir 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

Write-Step 'Windows icin gerekli araclar kontrol ediliyor.'
Ensure-WinGetPackage -Id 'Microsoft.PowerShell' -Name 'PowerShell 7'
Ensure-WinGetPackage -Id 'junegunn.fzf' -Name 'fzf'
Ensure-WinGetPackage -Id 'sharkdp.bat' -Name 'bat'
Ensure-WinGetPackage -Id 'Neovim.Neovim' -Name 'Neovim'

$pwshPath = Resolve-PwshPath

Write-Step 'PowerShell modulleri kontrol ediliyor.'
@('PSReadLine', 'Terminal-Icons', 'PSFzf') | ForEach-Object {
    Ensure-PSGalleryModule -Name $_ -PwshPath $pwshPath
}

Write-Step 'systemcmd dosyalari kopyalaniyor.'
if (Test-Path -LiteralPath $installRoot) {
    Remove-Item -LiteralPath $installRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Copy-Item -Path (Join-Path $windowsSourceDir '*') -Destination $installRoot -Recurse -Force

$terminalSettingsSource = Join-Path $resolvedSourceDir 'windows\terminal settings\settings.json'
if (Test-Path -LiteralPath $terminalSettingsSource) {
    Copy-Item -LiteralPath $terminalSettingsSource -Destination (Join-Path $installRoot 'windows-terminal.settings.template.json') -Force
}

$bootstrapBlock = @"
# systemcmd bootstrap
`$systemCmdProfile = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\systemcmd\Microsoft.PowerShell_profile.ps1'
if (Test-Path -LiteralPath `$systemCmdProfile) {
    . `$systemCmdProfile
}
"@

Write-Step 'Profil bootstrap dosyalari ayarlaniyor.'
Ensure-ProfileBootstrap -ProfilePath $pwshProfilePath -BootstrapBlock $bootstrapBlock
Ensure-ProfileBootstrap -ProfilePath $legacyProfilePath -BootstrapBlock $bootstrapBlock

if ($pwshPath) {
    Write-Step 'Profil yukleme testi yapiliyor.'
    try {
        & $pwshPath -NoLogo -NoProfile -Command ". '$installRoot\\Microsoft.PowerShell_profile.ps1'; 'PROFILE_OK'" | Out-Null
    } catch {
        Write-Warn "Profil testinde hata olustu: $($_.Exception.Message)"
    }
} else {
    Write-Warn 'PowerShell 7 yolu bulunamadi. Yeni terminal acildiginda PATH guncellenmis olabilir.'
}

Write-Host ''
Write-Host 'systemcmd kurulumu tamamlandi.' -ForegroundColor Green
Write-Host "Kurulum dizini: $installRoot" -ForegroundColor DarkGray
Write-Host 'Yeni bir terminal acip `system help` komutunu calistirabilirsiniz.' -ForegroundColor DarkGray
