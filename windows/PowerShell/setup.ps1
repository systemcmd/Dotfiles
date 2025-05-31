# setup.ps1 - systemcmd Dotfiles One-Click Installer
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n📦 systemcmd Dotfiles kurulumu başlatılıyor..." -ForegroundColor Cyan

#-----------------------------
# 1. PowerShell 7 kontrolü
#-----------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "❗ Bu Dotfiles PowerShell 7+ gerektirir. Lütfen 'winget install Microsoft.Powershell' ile yükleyin."
    return
}

#-----------------------------
# 2. Dotfiles klasörü
#-----------------------------
$dotfilesPath = "$HOME\.dotfiles"
$repoUrl = "https://github.com/systemcmd/Dotfiles"

if (-Not (Test-Path $dotfilesPath)) {
    Write-Host "📥 Dotfiles klasörü indiriliyor: $repoUrl" -ForegroundColor Yellow

    if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "❌ 'git' komutu bulunamadı. Git yükleyin: https://git-scm.com/downloads"
        return
    }

    git clone $repoUrl $dotfilesPath
} else {
    Write-Host "✅ Dotfiles klasörü zaten mevcut: $dotfilesPath" -ForegroundColor Green
}

#-----------------------------
# 3. Profil dosyasını bağla
#-----------------------------
$sourceProfile = "$dotfilesPath\windows\PowerShell\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE
$profileDir = Split-Path $targetProfile

if (-not (Test-Path $profileDir)) {
    Write-Host "📁 Profil dizini oluşturuluyor: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (Test-Path $sourceProfile) {
    Write-Host "🔗 Profil dosyası kopyalanıyor..."
    try {
        Copy-Item -Path $sourceProfile -Destination $targetProfile -Force
        Write-Host "✅ Profil dosyası başarıyla ayarlandı." -ForegroundColor Green
    } catch {
        Write-Warning "❌ Profil kopyalanamadı: $_"
        return
    }
} else {
    Write-Warning "❌ Kaynak profil dosyası bulunamadı: $sourceProfile"
    return
}

#-----------------------------
# 4. Gerekli modülleri yükle
#-----------------------------
$modules = @("PSReadLine", "Terminal-Icons")

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod modülü yükleniyor..."
        try {
            Install-Module $mod -Scope CurrentUser -Force -AllowClobber
            Write-Host "✅ $mod başarıyla yüklendi." -ForegroundColor Green
        } catch {
            Write-Warning "⚠️ $mod yüklenemedi: $_"
        }
    } else {
        Write-Host "✅ $mod zaten kurulu." -ForegroundColor DarkGray
    }
}

#-----------------------------
# 5. fzf uygulamasını yükle
#-----------------------------
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📦 fzf bulunamadı. Winget ile kuruluyor..."
    try {
        winget install fzf -e --silent
        Write-Host "✅ fzf başarıyla yüklendi." -ForegroundColor Green
    } catch {
        Write-Warning "⚠️ fzf yüklenemedi. Manuel yüklemek için: https://github.com/junegunn/fzf"
    }
} else {
    Write-Host "✅ fzf zaten sistemde kurulu." -ForegroundColor DarkGray
}

#-----------------------------
# 6. Bitiriş
#-----------------------------
Write-Host "`n🎉 systemcmd ortamı hazır!" -ForegroundColor Cyan
Write-Host "💡 Yeni bir PowerShell 7 terminali açarak tüm özellikleri kullanabilirsin." -ForegroundColor Gray
Write-Host "`n🧪 Kurulum sırasında oluşan hatalar yukarıda listelenmiştir. İnceleyebilirsin." -ForegroundColor DarkGray
