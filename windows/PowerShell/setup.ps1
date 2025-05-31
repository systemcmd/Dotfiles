# systemcmd Dotfiles Tek Tık Kurulum
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "`n📦 systemcmd kurulumu başlatılıyor..." -ForegroundColor Cyan

# PowerShell 7 kontrolü
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "❗ PowerShell 7+ gereklidir. Lütfen 'winget install Microsoft.Powershell' ile yükleyin."
    return
}

# Hedef klasör: PowerShell profil klasörü
$psDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $psDir)) {
    Write-Host "📁 Profil klasörü oluşturuluyor: $psDir"
    New-Item -ItemType Directory -Path $psDir -Force | Out-Null
}

# Tüm Dotfiles içeriğini bu dizine indirip kopyalayacağız
$tempDir = "$env:TEMP\systemcmd-dotfiles"
Remove-Item -Recurse -Force -Path $tempDir -ErrorAction SilentlyContinue
git clone https://github.com/systemcmd/Dotfiles $tempDir

# PowerShell alt klasöründeki tüm dosyaları profil klasörüne kopyala
$dotfilesSource = "$tempDir\windows\PowerShell"
Copy-Item -Path "$dotfilesSource\*" -Destination $psDir -Recurse -Force

# $PROFILE dosyasını ayarla (otomatik çalışsın)
$profilePath = $PROFILE
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}
$sourceProfile = "$psDir\Microsoft.PowerShell_profile.ps1"
Copy-Item -Path $sourceProfile -Destination $profilePath -Force

Write-Host "✅ Profil ve fonksiyon dosyaları kopyalandı." -ForegroundColor Green

# Modülleri yükle
$modules = @("PSReadLine", "Terminal-Icons")
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod yükleniyor..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "✅ $mod zaten kurulu." -ForegroundColor DarkGray
    }
}

# fzf yükle
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📦 fzf bulunamadı. Winget ile kuruluyor..."
    winget install fzf -e --silent
} else {
    Write-Host "✅ fzf zaten kurulu." -ForegroundColor DarkGray
}

# Kurulum tamamlandı
Write-Host "`n🎉 systemcmd ortamı kuruldu ve aktif hale getirildi!" -ForegroundColor Cyan
Write-Host "💡 Şimdi 'system help' yazarak komutları test edebilirsin." -ForegroundColor Gray
Write-Host "🔁 Yeni bir PowerShell terminali açarsan her şey otomatik yüklenecek."
