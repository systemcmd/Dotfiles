# 🌟 Dotfiles SystemCmd

```powershell
$GitHubRepositoryAuthor = "Systemcmd"; `
$GitHubRepositoryName = "Dotfiles"; `
```

---

## 🚀 Proje Özeti

Bu **Dotfiles** betiği, sisteminizin verimli bir şekilde yönetilmesini sağlamak ve çeşitli güvenlik, bilgi toplama ve optimizasyon işlemleri gerçekleştirmek için tasarlanmıştır. Aşağıdaki işlevleri sunar:

- ⚡ **PowerShell** profil yapılandırması.
- 🔍 **BIOS**, **IP**, ve Bluetooth cihaz bilgisi görüntüleme.
- 💹 Güncel döviz kurlarını görüntüleme.
- 📊 **RAM**, **GPU**, ve **CPU** kullanım durumlarını analiz etme.
- 🌐 **Google Dorking** teknikleriyle hızlı aramalar.
- 🔑 **Hashcat** ile parola kırma.
- 🛡️ **Metasploit Framework** desteği.
- 🌐 **Nmap** ile ağ taramaları.
- 🐳 **Docker** bilgileri ve rehberlik.
- 🔴 **Redteam** ve 🔵 **Blueteam** görevleri hakkında bilgi.
- 🔹 **Yeni eklenen bir çok özellik...** 🔹

---

## 💻 Windows Terminal System Help

Komutlar ve fonksiyonlar, aşağıdaki görsellerde detaylandırılmıştır:

### System Help
![System Help](https://github.com/systemcmd/Dotfiles/raw/main/images/system%20help.png)

### CTRL+F Kullanımı
![CTRL+F Komutu](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+F.png)

### CTRL+R Kullanımı
![CTRL+R Komutu](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+R.jpg)

### Nmap Menü
![Nmap Menü](https://github.com/systemcmd/Dotfiles/raw/main/images/nmp.png)

---

## 🔧 Kurulum Rehberi

1. **Dotfiles İndirme**  
   Dotfiles içerisindeki `powershell` klasörünü doğrudan `Belgeler` dizinine kopyalayın.

2. **Alternatif Yöntem**  
   `Microsoft.PowerShell_profile` dosyasındaki kodları `$profile` içine yapıştırın. Ardından, `powershell` klasörünü oluşturulan `Belgeler` dizinine taşıyın.

3. **PowerShell Yükleme**  
   Microsoft Store'dan **PowerShell Preview** veya **PowerShell** yükleyin.

---

### 🛠️ Scoop Kurulumu

Aşağıdaki adımları izleyerek gerekli araçları yükleyin:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser  # PowerShell Policy Ayarları
irm get.scoop.sh | iex                               # Scoop Yükleme
scoop --version                                      # Scoop Test
scoop install fzf                                    # fzf Modülü
scoop install bat                                    # bat Modülü
```

---

### 🎨 Terminal Özelleştirme

1. **Icons Modülü**  
   ```powershell
   Install-Module -Name Terminal-Icons -Scope CurrentUser
   ```

2. **Fzf Modülü**  
   ```powershell
   Install-Module -Name PSFzf -Scope CurrentUser
   ```

3. **NerdFont Yükleme**  
   [NerdFont Resmi Sitesi](https://www.nerdfonts.com/font-downloads) üzerinden uygun fontu indirin.

---

### 🛠️ Terminal Settings (İsteğe Bağlı)

Terminalin görünümünü daha profesyonel yapmak için aşağıdaki işlemi gerçekleştirin:

1. `C:\Users\kod\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` dosyasını açın.
2. Örnek ayarları bu dosyaya ekleyin ve gerekli yolları düzenleyin.

---

### 🐧 Kali Linux İçin Ekstra

`.bashrc` dosyasını ana dizininize kopyalayın veya içeriğini ekleyin:
```bash
echo $SHELL  # Kontrol etmek için
```
Eğer `zsh` kullanıyorsanız, `bash`'a geçerek `ctrl+f` ve `ctrl+r` kullanımını aktif hale getirebilirsiniz.

---

## ⚠️ Önemli Notlar

- 🛠️ Hatalarla ilgili doğrudan destek sağlamıyorum.
- Paylaşımımla ilgilendiğiniz için teşekkür ederim! 😊

---

## 🏆 Destek ve Katkı

Eğer projeyi beğendiyseniz, bir ⭐ bırakmayı unutmayın! 🧑‍💻
