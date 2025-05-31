# systemcmd Dotfiles Tek Tık Kurulum  (ASCII mesajlar + sağlam PSFzf)
# -----------------------------------
# 1) Konsol ve PowerShell kodlamasını UTF-8'e al
try {
    chcp 65001 > $null        # conhost ise UTF-8 kod sayfası
} catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)
$OutputEncoding             = [Console]::OutputEncoding

Write-Host "`nsystemcmd : kurulum başlıyor..." -ForegroundColor Cyan

# 2) PowerShell 7 kontrolü
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7+ gerekiyor.  winget install Microsoft.PowerShell"
    return
}

# 3) Profil klasörü
$psDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $psDir)) {
    Write-Host "Profil klasörü oluşturuluyor: $psDir"
    New-Item -ItemType Directory -Path $psDir -Force | Out-Null
}

# 4) Dotfiles'ı indir → kopyala
$tempDir = "$env:TEMP\systemcmd-dotfiles"
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
git clone https://github.com/systemcmd/Dotfiles $tempDir
Copy-Item "$tempDir\windows\PowerShell\*" $psDir -Recurse -Force
Write-Host "Dosyalar kopyalandı." -ForegroundColor Green

# 5) $PROFILE gösterici
$profilePath   = $PROFILE
$sourceProfile = "$psDir\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}
if ($profilePath -ne $sourceProfile) {
    Copy-Item $sourceProfile $profilePath -Force
}

# 6) Temel modüller
$baseMods = @("PSReadLine","Terminal-Icons")
foreach ($m in $baseMods) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Install-Module $m -Scope CurrentUser -Force -AllowClobber
    }
}

# 7) PSFzf — önce PSGallery, olmazsa GitHub
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
    Write-Host "PSFzf yükleniyor (PowerShell Gallery)..."
    try {
        Install-Module PSFzf -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    } catch {
        Write-Warning "Gallery başarısız → GitHub yedeği."
        $dest = "$HOME\Documents\PowerShell\Modules\PSFzf"
        $zip  = "$env:TEMP\PSFzf.zip"
        $urls = @(
            'https://github.com/kelleyma49/PSFzf/archive/refs/heads/main.zip',
            'https://github.com/kelleyma49/PSFzf/archive/refs/heads/master.zip'
        )
        foreach ($u in $urls) {
            try {
                Invoke-WebRequest $u -OutFile $zip -ErrorAction Stop
                Expand-Archive $zip "$env:TEMP\PSFzf" -Force
                $src = Get-ChildItem "$env:TEMP\PSFzf\PSFzf-*" | Select-Object -First 1
                if ($src) { Move-Item $src $dest -Force; break }
            } catch {}
        }
        Remove-Item "$env:TEMP\PSFzf*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 8) fzf.exe uygulaması
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "fzf yükleniyor (winget)..."
    winget install fzf -e --silent
}

Write-Host "`nsystemcmd ortamı kuruldu.  'system help' komutunu deneyin." -ForegroundColor Cyan
Write-Host "Yeni bir PowerShell 7 terminali açtığınızda ayarlar etkin."  -ForegroundColor Gray
