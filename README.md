# systemcmd Dotfiles

![systemcmd banner](https://github.com/systemcmd/Dotfiles/raw/main/images/systemhelp.png)

**systemcmd**, mevcut terminalin (Windows Terminal, iTerm2, GNOME Terminal vb.)
ve kabugun (PowerShell 7, zsh, bash) _icinde_ calisan, cross-platform akilli bir
shell ortamidir. Ayri bir terminal emulatoru degildir; var olan terminaline
proje farkindaligi, git degisiklik gorunumu, Buddy companion ve hizli komut
merkezi ekler.

Bu repo uc ayri kurulum akisi sunar:

- Windows 11 icin PowerShell 7 profili ve araclari
- Linux icin Bash profili ve fzf tabanli hizli komutlar
- macOS icin PowerShell 7 tabanli, tasinabilir `systemcmd` cekirdegi

## Mimari

`src/SystemCmd` tek tasinabilir cekirdektir. Windows'a ozel profil, pentest
referanslari ve sistem araclari `windows/` altinda kalir; macOS kurulumu bunlari
bilerek yuklemez. Bu ayrim hem tasinabilirligi hem de guvenli varsayilanlari
korur. CI, Windows, Ubuntu ve macOS'ta cekirdegin parse edilmesini ve testlerini
calistirir.

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

### macOS

Homebrew kuruluysa depo kokunden:

```bash
bash macos/install.sh
```

Kurucu `pwsh`, `fzf`, `bat`, `neovim` ve `git` paketlerini Homebrew ile kurar;
PowerShell profiline yalnizca tasinabilir cekirdegi ekler. Yeni bir terminalde
`pwsh` acip su komutlari kullanabilirsiniz:

```powershell
systemcmd doctor
systemcmd dashboard
systemcmd ports
systemcmd run
```

## Komutlar (v2 · shell environment)

`src/SystemCmd` artik klasik terminalin icinde calisan akilli bir shell ortamidir.
Modul yuklendikten sonra:

```powershell
systemcmd changes           # git degisiklik gorunumu (interaktif: jk/enter/s/u/c/x)
systemcmd changes --watch   # canli izleme modu
systemcmd project           # proje HUD (tip, git, runtime)
systemcmd status            # hizli durum panosu (+ startup ms)
systemcmd buddy             # companion paneli (proje/branch/session/last)
systemcmd buddy explain     # son hatayi acikla (komut calistirmaz)
systemcmd brain             # brain context (offline'a zarif dusus)
systemcmd doctor --performance   # profil/git/detection sureleri
systemcmd theme preview     # tema onizleme;  systemcmd theme set <ad>
```

`sc` kisa aliasi da kullanilabilir (`sc changes`). Tab-completion tanimlidir.

UI, terminal yeteneklerine gore otomatik uyarlanir (truecolor/unicode) ve
desteklenmeyen terminalde ASCII moduna duser. Windows'ta kutu cizim karakterleri
icin konsolu UTF-8'e almak isterseniz `Enable-SystemCmdUtf8` calistirin (opsiyonel;
mevcut ayarlarinizi zorla ezmez).

Buddy 3.0 mevcut oyunlastirilmis pet sistemini (profil icindeki
`systemcmd-companion.ps1`) korur; ona ek olarak sessiz bir terminal companion'i
(context + hata farkindaligi) getirir.

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
- `src/SystemCmd/`: Windows, macOS ve Linux ortak PowerShell modulu
- `macos/install.sh`: macOS/Homebrew kurucusu
- `tests/`: Pester testleri
- `.github/workflows/ci.yml`: uc platformlu dogrulama
- `theme/systemcmd-theme-source.json`: Tek kaynak tema paleti
- `theme/Build-SystemCmdTheme.ps1`: Tema build scripti
- `install.bat`: Windows icin tek tik giris noktasi
- `install.sh`: Linux icin terminal giris noktasi
- `install-linux.desktop`: Linux icin GUI giris noktasi

## Notlar

- Windows Terminal ayarlari otomatik olarak ezilmez; ornek dosya kurulum klasorune kopyalanir
- Linux masaustu ortamina gore `.desktop` dosyasina ilk acilista "Allow Launching" vermeniz gerekebilir
- Kurulumdan sonra yeni bir terminal acmaniz yeterli
