# setup.ps1 - systemcmd Dotfiles One-Click Installer

Write-Host "`n📦 systemcmd Dotfiles kurulumu başlatılıyor..." -ForegroundColor Cyan

#-----------------------------
# 1. PowerShell 7 kontrolü
#-----------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "❗ Bu Dotfiles PowerShell 7+ gerektirir. Lütfen 'winget install Microsoft.Powershell' ile yükleyin."
    exit 1
}

#-----------------------------
# 2. Dotfiles klasörü
#-----------------------------
$dotfilesPath = "$HOME\.dotfiles"
$repoUrl = "https://github.com/systemcmd/Dotfiles"

if (-Not (Test-Path $dotfilesPath)) {
    Write-Host "📥 Dotfiles klasörü indiriliyor: $repoUrl" -ForegroundColor Yellow

    if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "❌ 'git' komutu bulunamadı. Lütfen Git yükleyin: https://git-scm.com/downloads"
        exit 1
    }

    git clone $repoUrl $dotfilesPath
} else {
    Write-Host "✔️ Dotfiles klasörü zaten mevcut: $dotfilesPath" -ForegroundColor DarkGray
}

#-----------------------------
# 3. Profil dosyasını bağla
#-----------------------------
$sourceProfile = "$dotfilesPath\windows\PowerShell\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE

if (Test-Path $sourceProfile) {
    Write-Host "🔗 Profil dosyası ayarlanıyor..."
    try {
        Copy-Item -Path $sourceProfile -Destination $targetProfile -Force
        Write-Host "✔️ Profil dosyası başarıyla ayarlandı." -ForegroundColor Green
    } catch {
        Write-Warning "❌ Profil kopyalanamadı: $_"
        exit 1
    }
} else {
    Write-Warning "❌ Kaynak profil dosyası bulunamadı: $sourceProfile"
    exit 1
}

#-----------------------------
# 4. Gerekli modülleri yükle
#-----------------------------
$modules = @("PSReadLine", "Terminal-Icons", "fzf")

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod modülü yükleniyor..."
        try {
            Install-Module $mod -Scope CurrentUser -Force -AllowClobber
            Write-Host "✔️ $mod yüklendi." -ForegroundColor Green
        } catch {
            Write-Warning "⚠️ $mod yüklenemedi: $_"
        }
    } else {
        Write-Host "✔️ $mod modülü zaten yüklü." -ForegroundColor DarkGray
    }
}

#-----------------------------
# 5. Bitiriş ve restart
#-----------------------------
Write-Host "`n✅ Kurulum tamamlandı! systemcmd ortamı hazır!" -ForegroundColor Cyan
Write-Host "💡 Yeni bir PowerShell 7 terminali açarak kullanabilirsin." -ForegroundColor Gray

Start-Sleep -Seconds 2

# Otomatik olarak PowerShell 7 terminalini başlat
try {
    Start-Process "pwsh"
    Write-Host "🔁 Yeni terminal başlatıldı." -ForegroundColor Yellow
    exit
} catch {
    Write-Warning "⚠️ Yeni terminal başlatılamadı. Elle başlatabilirsiniz: pwsh"
}
