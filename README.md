# 🌟 Dotfiles SystemCmd

![GitHub stars](https://img.shields.io/github/stars/systemcmd/Dotfiles?style=social)
![GitHub forks](https://img.shields.io/github/forks/systemcmd/Dotfiles?style=social)

```powershell
$GitHubRepositoryAuthor = "Systemcmd"; `
$GitHubRepositoryName = "Dotfiles"; `
```

---

## 🚀 Proje Özeti

Bu **Dotfiles** betiği, sisteminizin verimli bir şekilde yönetilmesini sağlamak ve çeşitli güvenlik, bilgi toplama ve optimizasyon işlemleri gerçekleştirmek için tasarlanmıştır. Aşağıdaki işlevleri sunar:

- ⚡ PowerShell profil yapılandırması
- 🔍 BIOS, IP, ve Bluetooth cihaz bilgisi görüntüleme
- 💹 Güncel döviz kurları görüntüleme
- 📊 RAM, GPU, CPU kullanım analizi
- 🌐 Google Dorking teknikleri
- 🔑 Hashcat ile parola kırma
- 🛡️ Metasploit Framework entegrasyonu
- 🌐 Nmap ile ağ tarama
- 🐳 Docker bilgileri ve örnekleri
- 🔴 Redteam & 🔵 Blueteam rehberleri
- 🔹 Daha birçok özellik...

---

## 💻 Windows Terminal System Help

Aşağıda sık kullanılan komut ve fonksiyonlara dair görseller yer almaktadır:

![System Help](https://github.com/systemcmd/Dotfiles/raw/main/images/systemhelp.png)
![sistemarc](https://github.com/systemcmd/Dotfiles/raw/main/images/sistemarc.png)
![adminhck](https://github.com/systemcmd/Dotfiles/raw/main/images/sahip.png)
![CTRL+F](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+F.png)
![CTRL+R](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+R.jpg)
![Nmap Menü](https://github.com/systemcmd/Dotfiles/raw/main/images/nmp.png)

---

## ⚙️ Otomatik Kurulum

### 🐧 Linux/macOS:

Aşağıdaki tek satırlık komutla Dotfiles otomatik olarak indirilir, gerekli paketler kurulur ve sistem yapılandırılır:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/systemcmd/Dotfiles/main/install.sh)"
```

> Alternatif olarak manuel kurulum:
```bash
git clone https://github.com/systemcmd/Dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

---

### 🪟 Windows:

- `install.bat` dosyasına çift tıklayın  
**veya**  
- CMD'de aşağıdaki komutla çalıştırın:

```cmd
curl -LO https://raw.githubusercontent.com/systemcmd/Dotfiles/main/install.bat
install.bat
```

---

## 📦 Kurulum İçeriği

- `install.sh`: Linux/macOS için otomatik kurulum betiği
- `install.bat`: Windows için otomatik kurulum betiği

📌 `install.sh`: Dotfiles’ı indirir, gerekli paketleri kurar ve `bash/`, `zsh/`, `vim/`, `tmux/` klasörlerini `stow` ile ev dizinine bağlar.

📌 `install.bat`: Dotfiles’ı indirir, `scoop` ile gerekli araçları kurar ve `.vimrc`, `.gitconfig` gibi yapılandırmaları sembolik bağlantı ile kullanıcı dizinine yerleştirir.

🔁 Her iki script de terminali kullanıma hazır hale getirir. Kullanıcının tek yapması gereken bir kez çalıştırmaktır.

---

## 🛠️ Terminal Özelleştirme

```powershell
Install-Module -Name Terminal-Icons -Scope CurrentUser
Install-Module -Name PSFzf -Scope CurrentUser
```

🖋 NerdFont için: [nerdfonts.com](https://www.nerdfonts.com/font-downloads)

---

## 🐧 Kali Linux İçin Ekstra

`.bashrc` dosyasını ana dizine kopyalayın veya içeriğini ekleyin:

```bash
echo $SHELL
```

> `zsh` yerine `bash` kullanımı önerilir (`CTRL+F`, `CTRL+R` gibi kısayollar için)

---

## ⚠️ Önemli Notlar

- 🛠️ Hatalar konusunda bire bir teknik destek verilmez.
- 📤 Ancak geri bildirimleriniz ve yıldızlarınız projeye katkı sağlar. Teşekkürler!

---

## 🏆 Destek ve Katkı

Projeyi beğendiyseniz, bir ⭐ bırakmayı unutmayın!  
Yeni özellikler için isteklerinizi iletebilirsiniz. [ ⭐ Geldikçe Güncelleme Atılacak. ] 🧑‍💻
