# systemcmd – Tek Tık Kurulum (Çift Kademe Türkçe Kodlama + Sağlam PSFzf)

function Set-TurkishConsoleEncoding {
    param([switch]$Quiet)

    # 1) UTF-8 kod sayfasını dene (conhost için)
    try { chcp 65001 > $null } catch {}
    [Console]::OutputEncoding  = [System.Text.UTF8Encoding]::new($true)
    [Console]::InputEncoding   = [System.Text.UTF8Encoding]::new($true)
    $global:OutputEncoding     = [Console]::OutputEncoding

    # Hızlı test (ş,ğ,Ü) – UTF-8 bozuksa string uzunluğu 5 yerine 7 olur
    if (([string]'şüğŞİ').Length -gt 5) {
        if (-not $Quiet) { Write-Host "UTF-8 desteklenmiyor, Windows-1254’e geçiliyor..." -Fore Yellow }
        $turk = [System.Text.Encoding]::GetEncoding(1254)
        [Console]::OutputEncoding = $turk
        [Console]::InputEncoding  = $turk
        $global:OutputEncoding   = $turk
        try { chcp 1254 > $null } catch {}
    }
}

Set-TurkishConsoleEncoding -Quiet

Write-Host "`nsystemcmd: Kurulum başlıyor..." -Fore Cyan

# -- PowerShell 7 kontrolü ----------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "Bu kurulum için PowerShell 7+ gereklidir (winget install Microsoft.PowerShell)"
    return
}

# -- Profil klasörü -----------------------------------------------------------
$psDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $psDir)) {
    Write-Host "Profil klasörü oluşturuluyor: $psDir"
    New-Item -ItemType Directory -Path $psDir -Force | Out-Null
}

# -- Dotfiles indir → kopyala -------------------------------------------------
$tempDir = "$env:TEMP\systemcmd-dotfiles"
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
git clone https://github.com/systemcmd/Dotfiles $tempDir
Copy-Item "$tempDir\windows\PowerShell\*" $psDir -Recurse -Force
Write-Host "Dosyalar kopyalandı." -Fore Green

# -- $PROFILE ayarla ----------------------------------------------------------
$profilePath   = $PROFILE
$sourceProfile = "$psDir\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}
if ($profilePath -ne $sourceProfile) { Copy-Item $sourceProfile $profilePath -Force }

# -- Temel modüller -----------------------------------------------------------
@("PSReadLine","Terminal-Icons") | ForEach-Object {
    if (-not (Get-Module -ListAvailable -Name $_)) {
        Install-Module $_ -Scope CurrentUser -Force -AllowClobber
    }
}

# -- PSFzf (Gallery varsa hızlı, yoksa GitHub) --------------------------------
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
    Write-Host "PSFzf yükleniyor (Gallery)..."
    try {
        Install-Module PSFzf -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    } catch {
        Write-Warning "Gallery başarısız – GitHub yedeği kullanılıyor."
        $dest = "$HOME\Documents\PowerShell\Modules\PSFzf"
        $zip  = "$env:TEMP\PSFzf.zip"
        $urls = @(
            'https://github.com/kelleyma49/PSFzf/archive/refs/heads/main.zip',
            'https://github.com/kelleyma49/PSFzf/archive/refs/heads/master.zip'
        )
        foreach ($u in $urls) {
            try {
                Invoke-WebRequest $u -OutFile $zip -ErrorAction Stop
                Expand-Archive $zip "$env:TEMP\PSFZFTMP" -Force
                $src = Get-ChildItem "$env:TEMP\PSFZFTMP\PSFzf-*" | Select-Object -First 1
                if ($src) { Move-Item $src $dest -Force; break }
            } catch {}
        }
        Remove-Item "$env:TEMP\PSFZFTMP","$env:TEMP\PSFzf.zip" -Recurse -Force -EA SilentlyContinue
    }
}

# -- fzf.exe uygulaması -------------------------------------------------------
if (-not (Get-Command fzf.exe -EA SilentlyContinue)) {
    Write-Host "fzf yükleniyor (winget)..."
    winget install fzf -e --silent
}

# -- Bitti --------------------------------------------------------------------
Write-Host "`nsystemcmd ortamı başarıyla kuruldu. 'system help' komutunu deneyin." -Fore Cyan
Write-Host "Yeni bir PowerShell 7 terminali açtığınızda tüm ayarlar etkin." -Fore Gray
