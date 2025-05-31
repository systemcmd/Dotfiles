# setup.ps1 - systemcmd Dotfiles One-Click Installer

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
$modules = @("PSReadLine", "Terminal-Icons", "fzf")

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod yükleniyor..."
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
# 5. Bitiriş
#-----------------------------
Write-Host "`n🎉 systemcmd ortamı hazır!" -ForegroundColor Cyan
Write-Host "💡 Yeni bir PowerShell 7 terminali açarak tüm özellikleri kullanabilirsin." -ForegroundColor Gray
Write-Host "`n🧪 Kurulum sırasında oluşan hatalar yukarıda listelenmiştir. İnceleyebilirsiniz." -ForegroundColor DarkGray
