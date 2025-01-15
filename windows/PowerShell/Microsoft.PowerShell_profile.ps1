# Alias List
$aliasList = @(
    @{ Name='vim'; Value='nvim' },
    @{ Name='grep'; Value='findstr' },
    @{ Name='wn'; Value='winget' },
    @{ Name='sil'; Value='cls' },
    @{ Name='tig'; Value='C:\Program Files\Git\usr\bin\tig.exe' },
    @{ Name='less'; Value='C:\Program Files\Git\usr\bin\less.exe' },
    @{ Name='ifconfig'; Value='ipconfig' },
    @{ Name='st'; Value='start' },
    @{ Name='csc'; Value='C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe' }
)

# Alias Definitions
$aliasList | ForEach-Object { New-Alias -Name $_.Name -Value $_.Value }

# ll function
function ll {
    param (
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Force
}

# rmrf function
function rmrf {
    param (
        [string]$Path
    )
    Remove-Item -Path $Path -Recurse -Force
}

# Environment Variables
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:FZF_HISTORY_FILE = "$HOME/.fzf_history"
$env:FZF_DEFAULT_OPTS = '--height 70% --layout=reverse --border '

# which function
function which ($command) {
    if ($command -ne $null -and $command -ne "") {
        Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
    } else {
        Write-Host "Komut adı belirtilmedi veya geçersiz. Örnek: which steam" -ForegroundColor Red
    }
}

# ff function
function ff {
    $selectedFile = fzf --preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window down:70%
    vim $selectedFile
}

# Module Imports
@(
    'Terminal-Icons', 
    'PSFzf', 
    'PSReadLine'
) | ForEach-Object { Import-Module -Name $_ }

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Dot-source other scripts using $PSScriptRoot to get the directory of the current script
if ($PSScriptRoot) {
    . "$PSScriptRoot\nmphcmfs\Nmap.ps1"
    . "$PSScriptRoot\nmphcmfs\Hashcat.ps1"
    . "$PSScriptRoot\nmphcmfs\Msfconsole.ps1"
    . "$PSScriptRoot\nmphcmfs\dork.ps1"
    . "$PSScriptRoot\nmphcmfs\dockerhelp.ps1"
    . "$PSScriptRoot\\nmphcmfs\\blueteam.ps1"
    . "$PSScriptRoot\\nmphcmfs\\redteam.ps1"
    . "$PSScriptRoot\pc\ip-bt.ps1"
    . "$PSScriptRoot\pc\ascii.ps1"
    . "$PSScriptRoot\pc\ram-gpu-cpu.ps1"
    . "$PSScriptRoot\pc\bios.ps1"
    . "$PSScriptRoot\pc\money.ps1"
} else {
    Write-Host "Error: PSScriptRoot is not defined." -ForegroundColor Red
}

# Show-HelpMenu function (Türkçe)
function Show-HelpMenu {
    $helpText = @"
Mevcut Komutlar ve Fonksiyonlar:
---------------------------------
Özel Tuş Atamaları:
- Ctrl+d            : Çıkış yapar.
- Ctrl+f            : Dosya araması için kullanır.
- Ctrl+r            : Ters geçmiş araması için kullanır.

Aliaslar:
- vim               : nvim için kısayol.
- grep              : findstr için kısayol.
- wn                : winget için kısayol.
- sil               : cls (ekran temizleme) için kısayol.
- tig               : Git için tig aracı.
- less              : less komutuna gitmek için.
- ifconfig          : ipconfig için kısayol.
- st                : start komutuna gitmek için.
- csc               : .NET derleyicisi için kısayol.

Komutlar:
- dockerhelp        : Docker ile ilgili bilgi alırsınız.
- blueteam          : BlueTeam uygulamaları hakkında bilgi.
- redteam           : RedTeam uygulamaları hakkında bilgi.
- nmp               : Nmap komutları yardımcı menü.
- hc                : Hashcat yardımcı menü.
- msf               : Metasploit yardımcı menü.
- dork              : GoogleDorking menü.
- ascii             : Cümle kodlama.
- ip                : IP gösterir hem dış hem local.
- pil               : Batarya bilgisini gösterir.
- ram - gpu - cpu   : RAM, GPU ve CPU bilgileri gösterir.
- bios              : BIOS bilgileri gösterir.
- para              : Finansal hesaplamalar. Örnek: para 50.

Burası benim kişisel oluşturduğum kodlarım. Elimden geldiğince yardımcı olmaya çalıştım, umarım size de yararlı olur.
"@
    Write-Host $helpText
}

# system help alias
New-Alias -Name 'system' -Value 'Show-HelpMenu'
