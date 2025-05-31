# setup.ps1 - systemcmd Dotfiles One-Click Installer

Write-Host "`n📦 systemcmd Dotfiles kurulumu başlatılıyor..." -ForegroundColor Cyan

# Dotfiles klasörü
$dotfilesPath = "$HOME\.dotfiles"
$repoUrl = "https://github.com/systemcmd/Dotfiles"

# Dotfiles klasörü yoksa indir
if (-Not (Test-Path $dotfilesPath)) {
    Write-Host "📥 Repo indiriliyor: $repoUrl" -ForegroundColor Yellow
    git clone $repoUrl $dotfilesPath
} else {
    Write-Host "✔️ Dotfiles klasörü zaten var: $dotfilesPath" -ForegroundColor DarkGray
}

# Profil dosyasını bağla
$sourceProfile = "$dotfilesPath\windows\PowerShell\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE

if (Test-Path $sourceProfile) {
    Write-Host "🔗 Profil dosyası kopyalanıyor: $sourceProfile → $targetProfile"
    Copy-Item -Path $sourceProfile -Destination $targetProfile -Force
} else {
    Write-Host "❌ Profil dosyası bulunamadı: $sourceProfile" -ForegroundColor Red
    exit 1
}

# Modülleri kur
$modules = @("PSReadLine", "Terminal-Icons", "fzf")
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod modülü yükleniyor..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "✔️ $mod modülü zaten yüklü" -ForegroundColor DarkGray
    }
}

# Kurulum tamam
Write-Host "`n✅ systemcmd ortamı hazır! Yeni bir PowerShell terminali açarak kullanabilirsin." -ForegroundColor Green

# (İsteğe bağlı) Otomatik yeniden başlat
if ($env:TERM -ne "xterm-256color") {
    Write-Host "🔁 Terminal yeniden başlatılıyor..." -ForegroundColor Yellow
    Start-Process "powershell"
    exit
}
