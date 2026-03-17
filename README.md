# systemcmd Dotfiles

![systemcmd banner](https://github.com/systemcmd/Dotfiles/raw/main/images/systemhelp.png)

Bu repo iki ayri kurulum akisi sunar:

- Windows 11 icin PowerShell 7 profili ve araclari
- Linux icin Bash profili ve fzf tabanli hizli komutlar

## Tek Tik Kurulum

### Windows 11

Repo'yu indiren kullanici sadece `install.bat` dosyasina cift tiklar.

Alternatif olarak PowerShell ile:

```powershell
iwr https://raw.githubusercontent.com/systemcmd/Dotfiles/main/windows/install.ps1 | iex
```

Kurulum:

- PowerShell 7, `fzf`, `bat` ve `Neovim` icin `winget` denemesi yapar
- `PSReadLine`, `Terminal-Icons` ve `PSFzf` modullerini kurar
- Dosyalari `Documents\PowerShell\systemcmd` altina kopyalar
- `%LOCALAPPDATA%\nvim` altina `systemcmd` Neovim ayarlarini kurar
- Var olan profili ezmek yerine bootstrap satiri ekler

### Linux

Repo'yu indiren kullanici masaustu ortaminda `install-linux.desktop` dosyasina cift tiklayabilir.

Terminal tercih edenler icin:

```bash
bash install.sh
```

Kurulum:

- `apt`, `dnf`, `pacman`, `zypper` veya `apk` ile `fzf`, `bat`, `Neovim` ve clipboard araclarini kurmayi dener
- `~/.config/systemcmd/systemcmd.bashrc` dosyasini yerlestirir
- `~/.config/nvim` altina `systemcmd` Neovim ayarlarini kurar
- `~/.bashrc` icine tek satirlik bootstrap ekler

## Neler Duzenlendi

- Windows profili artik kosulsuz hata uretmiyor
- Eksik moduller ve komutlar sessizce pas geciliyor
- `Show-Ports` fonksiyonu eklendi
- `Ctrl+R` favori sistemi Windows ve Linux'ta ayni mantikla calisiyor; Linux tarafinda `F: favori ac/kapat` yardim yazisi gorunuyor
- `systemcmd color` VS Code temasi eklendi; VS Code varsa installer otomatik yukleyip aktif etmeyi dener
- `systemcmd color` paletine gore hazir Neovim ayarlari eklendi
- `systemcmd doctor` ile kurulum sagligi kontrol edilebilir
- `systemcmd` ile TUI ana menu acilir
- `systemcmd theme build` ile tek kaynak tema dosyasindan VS Code, Neovim ve shell tema ciktilari uretilir
- Kurulum scriptleri artik mevcut dosya agaciyla uyumlu
- Linux installer eski olmayan klasorleri hedeflemiyor

## Dizinler

- `windows/install.ps1`: Windows installer
- `windows/PowerShell/`: Windows profil ve komut dosyalari
- `linux/systemcmd.bashrc`: Linux bash profil parcasi
- `theme/systemcmd-theme-source.json`: Tek kaynak tema paleti
- `theme/Build-SystemCmdTheme.ps1`: Tema build scripti
- `install.bat`: Windows icin tek tik giris noktasi
- `install.sh`: Linux icin terminal giris noktasi
- `install-linux.desktop`: Linux icin GUI giris noktasi

## Notlar

- Windows Terminal ayarlari otomatik olarak ezilmez; ornek dosya kurulum klasorune kopyalanir
- Linux masaustu ortamina gore `.desktop` dosyasina ilk acilista "Allow Launching" vermeniz gerekebilir
- Kurulumdan sonra yeni bir terminal acmaniz yeterli
