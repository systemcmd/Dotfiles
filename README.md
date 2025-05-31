# 📁 systemcmd Dotfiles

![systemcmd banner](https://github.com/systemcmd/Dotfiles/raw/main/images/systemhelp.png)

---

## 🚀 Hızlı Başlangıç

### 🔧 Windows Tek Komut Kurulumu

PowerShell 7+ ile aşağıdaki komutu çalıştırarak tüm yapılandırmaları kurabilirsiniz:

```powershell
iwr https://raw.githubusercontent.com/systemcmd/Dotfiles/main/windows/PowerShell/setup.ps1 | iex
```

🟢 Kurulum sonrası tüm ayarlar otomatik etkinleşir.  
🔁 Yeni bir PowerShell terminali açarak kullanmaya başlayabilirsiniz.

---

## 🎯 Özellikler

- 🖥️ PowerShell profili ile gelişmiş terminal
- 📈 Sistem istatistikleri (CPU, RAM, GPU)
- 🔍 IP, BIOS, ağ ve Bluetooth bilgisi
- 💻 Docker, Nmap, Metasploit entegrasyonları
- 🧠 Google Dork, Hashcat, Redteam/BlueTeam araçları
- ⚙️ Terminal-Icons, PSReadLine, PSFzf modül desteği
- 🧩 fzf ile etkileşimli servis ve log seçim sistemi

---

## 🖼️ Ekran Görüntüleri

| Komut Yardımı | Sistem Bilgileri | Yetki Gösterimi |
|---------------|------------------|------------------|
| ![system](https://github.com/systemcmd/Dotfiles/raw/main/images/systemhelp.png) | ![arc](https://github.com/systemcmd/Dotfiles/raw/main/images/sistemarc.png) | ![admin](https://github.com/systemcmd/Dotfiles/raw/main/images/sahip.png) |

| FZF Kısayolları | Geri Arama | Nmap Menü |
|------------------|------------|-------------|
| ![CTRL+F](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+F.png) | ![CTRL+R](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+R.jpg) | ![Nmap](https://github.com/systemcmd/Dotfiles/raw/main/images/nmp.png) |

---

## ⚙️ Manuel Kurulum

### Linux/macOS:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/systemcmd/Dotfiles/main/install.sh)"
```

### Windows:
```cmd
curl -LO https://raw.githubusercontent.com/systemcmd/Dotfiles/main/install.bat
install.bat
```

---

## 📦 Yapılandırma Dosyaları

- `setup.ps1` – PowerShell için otomatik kurulum
- `install.sh` – Linux/macOS için terminal yapılandırması
- `functions.ps1`, `aliases.ps1` – Özel komutlar ve kısayollar
- `system.ps1` – Yardım ve komut tanıtım sistemi

---

## 🎨 Tavsiye Edilen Terminal ve Font

- 💻 [Windows Terminal](https://aka.ms/terminal)
- 🖋 [NerdFonts - Hack, FiraCode](https://www.nerdfonts.com/font-downloads)

---

## 🛟 Katkı & Geri Bildirim

Geliştirmeye katkı sağlamak veya öneri sunmak için:

- ⭐ Bu repo'yu beğenerek destek ol
- 📥 Pull Request gönderebilirsin
- ❓ `Issues` kısmından geri bildirim bırakabilirsin

---

## 🧠 Notlar

- Terminalinizin UTF-8 desteklediğinden emin olun
- PowerShell 7.2+ önerilir
- Bu repo, günlük kullanım ve pentest kolaylığı için optimize edilmiştir

---

## 📌 Lisans

MIT Lisansı – özgürce kullanın, geliştirin, paylaşın.

---

📬 Her şey hazır. Terminalde `system help` yaz ve keşfetmeye başla!
