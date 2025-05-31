# systemcmd Dotfiles Tek Tık Kurulum (UTF-8, ASCII mesajlar, sağlam PSFzf)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)
$OutputEncoding          = [Console]::OutputEncoding

Write-Host "`nsystemcmd: Kurulum başlatılıyor..." -ForegroundColor Cyan

# --- 1) PowerShell 7 kontrolü ---------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7+ gereklidir. 'winget install Microsoft.PowerShell' komutunu çalıştırın."
    return
}

# --- 2) Profil klasörü ----------------------------------
$psDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $psDir)) {
    Write-Host "Profil klasörü oluşturuluyor: $psDir"
    New-Item -ItemType Directory -Path $psDir -Force | Out-Null
}

# --- 3) Dotfiles'ı geçici klasöre klonla -----------------
$tempDir = "$env:TEMP\systemcmd-dotfiles"
Remove-Item -Recurse -Force -Path $tempDir -ErrorAction SilentlyContinue
git clone https://github.com/systemcmd/Dotfiles $tempDir

# --- 4) Dosyaları hedefe kopyala -------------------------
$dotfilesSource = "$tempDir\windows\PowerShell"
Copy-Item "$dotfilesSource\*" $psDir -Recurse -Force
Write-Host "Profil ve fonksiyon dosyaları kopyalandı." -ForegroundColor Green

# --- 5) $PROFILE dosyasını aktif et ----------------------
$profilePath   = $PROFILE
$sourceProfile = "$psDir\Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}
if ($sourceProfile -ne $profilePath) {
    Copy-Item $sourceProfile $profilePath -Force
}

# --- 6) Temel modüller ----------------------------------
$modules = @("PSReadLine", "Terminal-Icons")
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Write-Host "$m modülü yükleniyor..."
        Install-Module $m -Scope CurrentUser -Force -AllowClobber
    }
}

# --- 7) PSFzf: önce PowerShell Gallery -------------------
$psfzfName = "PSFzf.PowerShell"
if (-not (Get-Module -ListAvailable -Name $psfzfName)) {
    Write-Host "PSFzf modülü yükleniyor (PowerShell Gallery)..."
    try {
        Install-Module $psfzfName -Scope CurrentUser -Force -AllowClobber
    } catch {
        # Galeri başarısızsa GitHub'dan indir
        Write-Warning "Gallery başarısız. GitHub yedeği indiriliyor..."
        $zip = "$env:TEMP\PSFzf.zip"
        Invoke-WebRequest https://github.com/kelleyma49/PSFzf/archive/refs/heads/master.zip -OutFile $zip
        Expand-Archive $zip "$env:TEMP\PSFzf" -Force
        Move-Item "$env:TEMP\PSFzf\PSFzf-master" "$HOME\Documents\PowerShell\Modules\PSFzf" -Force
    }
}

# --- 8) fzf.exe uygulaması ------------------------------
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "fzf yükleniyor (winget)..."
    winget install fzf -e --silent
}

# --- 9) Tamamlandı --------------------------------------
Write-Host "`nsystemcmd ortamı başarıyla kuruldu. 'system help' komutunu deneyin." -ForegroundColor Cyan
Write-Host "Yeni bir PowerShell 7 terminali açtığınızda ayarlar otomatik yüklenecek." -ForegroundColor Gray
