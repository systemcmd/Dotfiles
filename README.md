# Dotfiles SystemCmd

```Powershell
$GitHubRepositoryAuthor = "Systemcmd"; `
$GitHubRepositoryName = "Dotfiles"; `
```



## Bu Dotfiles Ne Yapar ?

Bu dotfiles betiği aşağıdaki işlemleri gerçekleştirir:

- PowerShell profilinizi yapılandırır.
- BIOS bilgilerinizi görüntüler.
- Bilgisayarınızın IP adresini ve Bluetooth cihazlarını listeler.
- Döviz kurlarını görüntüler.
- Bilgisayarınızdaki RAM, GPU ve CPU kullanım bilgilerini toplar.
- Google Dorking tekniklerini kullanarak aramalar yapar.
- Hashcat ile parola kırma işlemleri yapmanızı sağlar.
- Metasploit Framework destek olur.
- Nmap ile ağ taramaları yapar.

## Windows Terminal System help

PS C:\Users\**\Desktop> system help

Mevcut Komutlar ve Fonksiyonlar:
---------------------------------
Özel Tuş Atamaları:
- Ctrl+d            : Çıkış yapar.
- Ctrl+f            : Dosya araması için kullanır.
- Ctrl+r            : Ters geçmiş araması için kullanır.

Komutlar:
- nmp               : Nmap komutları yardımcı menü.
- hc                : Hashcat yardımcı menü.
- msf               : Metasploit yardımcı menü.
- dork              : GoogleDorking  menü.
- ascii             : Cümle kodlama.
- ip                : IP gösterir hem dış hem local.
- pil               : Batarya bilgisini gösterir.
- ram - gpu - cpu   : RAM, GPU ve CPU bilgileri gösterir.
- bios              : BIOS bilgileri gösterir.
- para              : Finansal hesaplamalar.

## Nasıl kurulur ? 

- Dosyaları indirdikten sonra dotfiles içerisindeki powershell klasörünü belgeler kısmına direk kopyalayın.

- Yukarıdaki işlemi yapamazsanız Microsoft.PowerShell_profile içerisinde kodları $profile içerisine acıp içerisine kopyalayın bu işlemden sonra zaten belgeler kısmına powershell oluşturulucak tekrar kopyalama yapın.

- ilk olarak microsoft store'dan powershell preview yada powershell  indiriyoruz sonra sında  

### Scoop install 
| ----- | ------------------------ | ---------- | --- |
| Set-ExecutionPolicy RemoteSigned -Scope CurrentUser   | Description : PowerShell Execution Policy Ayarlarını Güncelle | PowerShell  ✅ |
| irm get.scoop.sh | iex   |  Description : Scoop indiriyoruz | PowerShell  ✅ |
| scoop --version  |  Description : Scoop test et | PowerShell  ✅ | Scoop ✅ |
| scoop install fzf  |  Description : Fzf modülünü yüklüyoruz | PowerShell  ✅ | Scoop ✅ |
| scoop install bat  |  Description : Ctrl+f için gerekli modül | PowerShell  ✅ | Scoop ✅ | fzf ✅ |


### Powershell Terminal
| Install-Module -Name Terminal-Icons -Scope CurrentUser  |  Description : Bu Terminal-ıcons terminalde iconların daha güzel görünmesi için. | PowerShell  ✅ |
| Install-Module -Name PSFzf -Scope CurrentUser  |  Description : Ctrl+f & Ctrl+r için yüklenmesi gereken modül | PowerShell  ✅ |


### NerdFont
- Aşağıdaki siteden hack nerdfont indirebilirsiniz terminalde iconlar vs daha düzügn gözükmesi için.
- https://www.nerdfonts.com/font-downloads

### Terminal Settings
- İsterseniz yükleyin bunu gerekli bir işlev değil sadece görüntü.
- Terminal settings klasöründeki dosya için ise içeriğini kopyalayın C:\Users\kod\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json içerisine yapıştırın.
- Fakat dosya yollarını falan kendinize göre düzenleyin yoksa powershell vs bozulur.

### hata
-   74 |      [xml]$smiOutput = & 'nvidia-smi' -q -x  böyle bir hata alırsanız gpu sürücülerini doğru yüklediğinizden emin olun.

### Kali linux 
- Çok basit .bashrc kullandığınız kullanıcının ana kısmına kopyalayın bu kadar.