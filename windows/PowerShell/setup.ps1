# systemcmd Dotfiles One-Click Installer - Tam Entegre Kurulum

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "`n📦 systemcmd kurulumu başlatılıyor..." -ForegroundColor Cyan

# PowerShell 7 kontrolü
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "❗ PowerShell 7+ gereklidir. Lütfen yükleyin: winget install Microsoft.Powershell"
    return
}

# Profil yolu ve klasör kontrolü
$targetProfile = $PROFILE
$profileDir = Split-Path $targetProfile
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Profil içeriği oluşturuluyor
$profileContent = @'
# systemcmd PowerShell profili
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function system {
    param ([string]$command = "help")
    switch ($command) {
        "help" {
            Write-Host "🧠 Komutlar:"
            Write-Host "  system update   → Dotfiles güncelle (yakında)"
            Write-Host "  system menu     → fzf menüsü"
            Write-Host "  system harden   → Güvenlik ayarları (yakında)"
        }
        "menu" {
            Show-SystemctlMenu
        }
        default {
            Write-Warning "Tanımsız komut: $command"
        }
    }
}

function Show-SystemctlMenu {
    $commands = @(
        "systemctl list-units --type=service",
        "systemctl status",
        "journalctl -xe",
        "systemctl restart network",
        "systemctl enable docker",
        "systemctl disable bluetooth"
    )
    $selection = $commands | fzf --prompt "Bir komut seç: "
    if ($selection) {
        Write-Host "`n⏱ Çalıştırılıyor: $selection" -ForegroundColor Cyan
        Invoke-Expression $selection
    }
}
'@

# Dosyayı yaz
Set-Content -Path $targetProfile -Value $profileContent -Encoding UTF8 -Force
Write-Host "✅ Profil dosyası yazıldı: $targetProfile" -ForegroundColor Green

# Modülleri kur
$modules = @("PSReadLine", "Terminal-Icons")
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "📦 $mod yükleniyor..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "✅ $mod zaten kurulu." -ForegroundColor DarkGray
    }
}

# fzf kontrolü
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📦 fzf bulunamadı. Winget ile kuruluyor..."
    winget install fzf -e --silent
} else {
    Write-Host "✅ fzf zaten kurulu." -ForegroundColor DarkGray
}

Write-Host "`n🎉 systemcmd ortamı hazır!" -ForegroundColor Cyan
Write-Host "💡 'system help' yazarak komutları görebilirsin." -ForegroundColor Gray
Write-Host "🔁 Yeni bir PowerShell terminali açarsan tüm değişiklikler aktif olur."
