if ($PSCommandPath) {
    $scriptContent = Get-Content -Path $PSCommandPath -Raw
    if ($scriptContent -notmatch 'function\s+SystemCmd') {
        return
    }
} else {
    Write-Error "Script path belirlenemedi (PSScriptRoot/PSCommandPath hatalı). Kod çalışmayı durduruyor."
    return
}

###############################################################################
# Alias List
###############################################################################
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
$aliasList | ForEach-Object {
    New-Alias -Name $_.Name -Value $_.Value
}

###############################################################################
# ll function
###############################################################################
function ll {
    param (
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Force
}

###############################################################################
# rmrf function
###############################################################################
function rmrf {
    param (
        [string]$Path
    )
    Remove-Item -Path $Path -Recurse -Force
}

###############################################################################
# Environment Variables
###############################################################################
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:FZF_HISTORY_FILE = "$HOME/.fzf_history"
$env:FZF_DEFAULT_OPTS = '--height 70% --layout=reverse --border '

###############################################################################
# which function
###############################################################################
function which ($command) {
    if ($command -ne $null -and $command -ne "") {
        Get-Command -Name $command -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
    } else {
        Write-Host "Komut adı belirtilmedi veya geçersiz. Örnek: which steam" -ForegroundColor Red
    }
}

###############################################################################
# ff function
###############################################################################
function ff {
    $selectedFile = fzf --preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window down:70%
    vim $selectedFile
}

###############################################################################
# Module Imports
###############################################################################
@(
    'Terminal-Icons',
    'PSFzf',
    'PSReadLine'
) | ForEach-Object {
    Import-Module -Name $_
}

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

###############################################################################
# Dot-source other scripts using $PSScriptRoot to get the directory of the current script
###############################################################################
if ($PSScriptRoot) {
    . "$PSScriptRoot\nmphcmfs\Nmap.ps1"
    . "$PSScriptRoot\nmphcmfs\Hashcat.ps1"
    . "$PSScriptRoot\nmphcmfs\Msfconsole.ps1"
    . "$PSScriptRoot\nmphcmfs\PentestMenu.ps1"
    . "$PSScriptRoot\nmphcmfs\dork.ps1"
    . "$PSScriptRoot\nmphcmfs\ncat.ps1"
    . "$PSScriptRoot\nmphcmfs\dockerhelp.ps1"
    . "$PSScriptRoot\nmphcmfs\blueteam.ps1"
    . "$PSScriptRoot\nmphcmfs\redteam.ps1"
    . "$PSScriptRoot\nmphcmfs\crypto_resources.ps1"
    . "$PSScriptRoot\nmphcmfs\SistemArac.ps1"
    . "$PSScriptRoot\nmphcmfs\adminhck.ps1"
    . "$PSScriptRoot\pc\ip-bt.ps1"
    . "$PSScriptRoot\pc\ascii.ps1"
    . "$PSScriptRoot\pc\ram-gpu-cpu.ps1"
    . "$PSScriptRoot\pc\bios.ps1"
    . "$PSScriptRoot\pc\money.ps1"
} else {
    Write-Host "Error: PSScriptRoot is not defined." -ForegroundColor Red
}


function Type-Text {
    param(
        [string]$Text,
        [int]$Delay = 100
    )
    foreach ($char in $Text.ToCharArray()) {
        # Karakteri yeşil renkte gösterelim (dilersen renk kodlarını değiştirebilirsin)
        Write-Host -NoNewline "`e[1;92m$char`e[0m"
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

function Show-HelpMenu {

    Write-Host "`e[1;94m╔═════════════════════════════════════════════════════════════╗`e[0m"
    Write-Host "`e[1;94m║`e[0m         `e[1;95m✨ MEVCUT KOMUTLAR VE FONKSİYONLAR ✨`e[0m           `e[1;94m║`e[0m"
    Write-Host "`e[1;94m╠═════════════════════════════════════════════════════════════╣`e[0m"
    Write-Host ""

    $robot1 = @"
`e[90m    ________   `e[0m
`e[90m   /        \  `e[0m
`e[90m  | `e[96m[]    [] `e[90m| `e[0m
`e[90m  | `e[93m  \____/  `e[90m| `e[0m
`e[90m   \________/  `e[0m
"@

    $robot2 = @"
`e[90m   .--------.  `e[0m
`e[90m  /   `e[96m0  0  `e[90m\ `e[0m
`e[90m |     __    | `e[0m
`e[90m | 
`e[90m  \__________/ `e[0m
"@

    $robot3 = @"
`e[90m    ________    `e[0m
`e[90m   /        \   `e[0m
`e[90m  |  `e[96m^    ^  `e[90m|  `e[0m
`e[90m  | `e[93m  \____/   `e[90m|  `e[0m
`e[90m   \___~~___/   `e[0m
"@

    $robot4 = @"
`e[90m    ________    `e[0m
`e[90m   /        \   `e[0m
`e[90m  |  `e[96m><   >< `e[90m|  `e[0m
`e[90m  | `e[93m  \____/   `e[0m|  `e[0m
`e[90m   \________/   `e[0m
"@

    Write-Host "`e[92m[ ÖZEL TUŞ ATAMALARI ]`e[0m"
    Write-Host "  `e[96m• Ctrl+d`e[0m   : Çıkış yapar."
    Write-Host "  `e[96m• Ctrl+f`e[0m   : Dosya araması (fzf)."
    Write-Host "  `e[96m• Ctrl+r`e[0m   : Ters geçmiş araması."
    Write-Host ""

    Write-Host "`e[92m[ ALIASLAR ]`e[0m"
    Write-Host "  `e[93m• vim       `e[0m: nvim için kısayol."
    Write-Host "  `e[93m• grep      `e[0m: findstr için kısayol."
    Write-Host "  `e[93m• wn        `e[0m: winget için kısayol."
    Write-Host "  `e[93m• sil       `e[0m: cls (ekran temizleme)."
    Write-Host "  `e[93m• tig       `e[0m: Git için tig aracı."
    Write-Host "  `e[93m• less      `e[0m: less komutu."
    Write-Host "  `e[93m• ifconfig  `e[0m: ipconfig için kısayol."
    Write-Host "  `e[93m• st        `e[0m: start komutu."
    Write-Host "  `e[93m• csc       `e[0m: .NET derleyicisi."
    Write-Host ""

    Write-Host "`e[92m[ MEVCUT FONKSİYONLAR ]`e[0m"
    Write-Host "  `e[96m• ll [path]      `e[0m: Belirtilen dizini listeler (gizli dosyalar dahil)."
    Write-Host "  `e[96m• rmrf <path>    `e[0m: Silme (Recurse -Force)."
    Write-Host "  `e[96m• which <command>`e[0m: Komutun path’ini gösterir."
    Write-Host "  `e[96m• ff             `e[0m: fzf ile dosya araması + vim ile açma."
    Write-Host "  `e[96m• Show-Ports     `e[0m: Aktif bağlantıları (netstat) gösterir."
    Write-Host ""

    Write-Host "`e[92m[ HARİCİ MENÜLER ve KOMUTLAR ]`e[0m"
    Write-Host "  `e[95m🚀 dockerhelp        `e[0m: Docker bilgisi."
    Write-Host "  `e[95m🪙 crypto            `e[0m: Crypto hakkında bilgiler."
    Write-Host "  `e[95m📈 pentestmenu       `e[0m: Pentest için siteler."
    Write-Host "  `e[95m🛡️ blueteam          `e[0m: BlueTeam menüsü."
    Write-Host "  `e[95m🔥 redteam           `e[0m: RedTeam menüsü."
    Write-Host "  `e[95m🔎 nmp               `e[0m: Nmap komut menüsü."
    Write-Host "  `e[95m📡 ncatmenu          `e[0m: Ncat komut menüsü."
    Write-Host "  `e[95m💻 hc                `e[0m: Hashcat menüsü."
    Write-Host "  `e[95m🦾 msf               `e[0m: Metasploit menüsü."
    Write-Host "  `e[95m🔍 dork              `e[0m: Google Dorking menüsü."
    Write-Host "  `e[95m🎨 ascii             `e[0m: Cümle kodlama (ascii.ps1)."
    Write-Host "  `e[95m⚙️ sistemarac        `e[0m: Sağ tık'a sistem araçlarını ekler ve kaldırır."
    Write-Host "  `e[95m😡 adminhck          `e[0m: Sağ tık yaptığınız dosyanın sahipliğini alır."
    Write-Host "  `e[95m🌐 ip                `e[0m: IP bilgileri (dış & local)."
    Write-Host "  `e[95m🖥️ ram/gpu/cpu       `e[0m: Sistem kaynak bilgileri."
    Write-Host "  `e[95m🔰 bios              `e[0m: BIOS bilgileri."
    Write-Host "  `e[95m💰 para              `e[0m: Finansal hesaplama (örn: para 50)."
    Write-Host ""

    $robots = @($robot1, $robot2, $robot3, $robot4)
    $selectedRobot = $robots | Get-Random
    Write-Host $selectedRobot
    Write-Host ""

    Type-Text "`e[┌──(X_O㉿System)-[~/Cmd]"
    Write-Host ""
}

function SystemCmd { Show-HelpMenu }

New-Alias -Name 'system' -Value 'SystemCmd'

