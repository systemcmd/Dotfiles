# systemcmd Dotfiles Tek Tık Kurulum
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)
$OutputEncoding = [Console]::OutputEncoding

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

# Geçici klasöre Dotfiles indir
$tempDir = "$env:TEMP\systemcmd-dotfiles"
Remove-Item -Recurse -Force -Path $tempDir -ErrorAction SilentlyContinue
git clone https://github.com/systemcmd/Dotfiles $tempDir

# Dotfiles içeriğini PowerShell klasörüne kopyala
$dotfilesSource = "$tempDir\windows\PowerShell"
Copy-Item -Path "$dotfilesSource\*" -Destination $psDir -Recurse -Force

# $PROFILE dosyasını ayarla (ama kendini kopyalamaya çalışma)
$profilePath = $PROFILE
$sourceProfile = "$psDir\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}
if ($sourceProfile -ne $profilePath) {
    Copy-Item -Path $sourceProfile -Destination $profilePath -Force
}

Write-Host "✅ Profil ve fonksiyon dosyaları başarıyla kopyalandı." -ForegroundColor Green

# PSReadLine ve Terminal-Icons modülleri
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

# PSFzf modülünü manuel indir ve kur
$psfzfDir = "$HOME\Documents\PowerShell\Modules\PSFzf"
if (-not (Test-Path $psfzfDir)) {
    Write-Host "📦 PSFzf modülü manuel kuruluyor..."
    Invoke-WebRequest -Uri "https://github.com/kelleyma49/PSFzf/archive/refs/heads/main.zip" -OutFile "$env:TEMP\PSFzf.zip"
    Expand-Archive "$env:TEMP\PSFzf.zip" -DestinationPath "$env:TEMP\PSFzf" -Force
    Move-Item "$env:TEMP\PSFzf\PSFzf-main" $psfzfDir -Force
    Write-Host "✅ PSFzf başarıyla indirildi ve kuruldu." -ForegroundColor Green
} else {
    Write-Host "✅ PSFzf zaten kurulu." -ForegroundColor DarkGray
}

# fzf uygulaması yüklü mü?
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📦 fzf bulunamadı. Winget ile kuruluyor..."
    try {
        winget install fzf -e --silent
        Write-Host "✅ fzf başarıyla yüklendi." -ForegroundColor Green
    } catch {
        Write-Warning "⚠️ fzf yüklenemedi. Manuel kurulum için: https://github.com/junegunn/fzf"
    }
} else {
    Write-Host "✅ fzf zaten sistemde kurulu." -ForegroundColor DarkGray
}

# Kurulum tamam
Write-Host "`n🎉 systemcmd ortamı başarıyla kuruldu ve aktif hale getirildi!" -ForegroundColor Cyan
Write-Host "💡 'system help' yazarak komutları test edebilirsin." -ForegroundColor Gray
Write-Host "🔁 Yeni bir PowerShell terminali açarsan tüm özellikler otomatik yüklenecek." -ForegroundColor Gray
