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
- Docker hakkında bilgi verir.
- Redteam ile ilgili bilgi verir.
- Blueteam ile ilgili bilgi verir.

## Windows Terminal System help

![System Help](https://github.com/systemcmd/Dotfiles/raw/main/images/system%20help.png)


![CTRL+F Komutu](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+F.png)


![CTRL+R Komutu](https://github.com/systemcmd/Dotfiles/raw/main/images/CTRL+R.jpg)


![Nmap Menü](https://github.com/systemcmd/Dotfiles/raw/main/images/nmp.png)

## Nasıl kurulur ? 

- Dosyaları indirdikten sonra dotfiles içerisindeki powershell klasörünü belgeler kısmına direk kopyalayın.

- Yukarıdaki işlemi yapamazsanız Microsoft.PowerShell_profile içerisinde kodları $profile içerisine acıp içerisine kopyalayın bu işlemden sonra zaten belgeler kısmına powershell oluşturulucak tekrar kopyalama yapın.

- ilk olarak microsoft store'dan powershell preview yada powershell  indiriyoruz sonra sında  

### Scoop install 

- ```Set-ExecutionPolicy RemoteSigned -Scope CurrentUser ``` Acıklama : PowerShell Execution Policy Ayarlarını Güncelle,
- ```irm get.scoop.sh  iex ``` Acıklama : Scoop indiriyoruz.
- ```scoop --version ```     Acıklama : Scoop test et.
- ```scoop install fzf ```  Acıklama : Fzf modülünü yüklüyoruz.
- ```scoop install bat ```  Acıklama : Ctrl+f için gerekli modül.


### Powershell Terminal
- ```Install-Module -Name Terminal-Icons -Scope CurrentUser```    Acıklama : Bu Terminal-ıcons terminalde iconların daha güzel görünmesi için.
- ```Install-Module -Name PSFzf -Scope CurrentUser```    Acıklama : Ctrl+f & Ctrl+r için yüklenmesi gereken modül.


### NerdFont
- Aşağıdaki siteden hack nerdfont indirebilirsiniz terminalde iconlar vs daha düzügn gözükmesi için.
- https://www.nerdfonts.com/font-downloads

### Terminal Settings
- İsterseniz yükleyin bunu gerekli bir işlev değil sadece görüntü.
- Terminal settings klasöründeki dosya için ise içeriğini kopyalayın C:\Users\kod\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json içerisine yapıştırın.
- Fakat dosya yollarını falan kendinize göre düzenleyin yoksa powershell vs bozulur.

### hata
-   74 |      [xml]$smiOutput = & 'nvidia-smi' -q -x  böyle bir hata alırsanız gpu sürücülerini doğru yüklediğinizden emin olun.

### Kalilinux
- Kali linux için .bashrc dosyasını içeriği kopyalayın yada direk kendisini kopyalayıp kullanıcı ana dizinine yapıştırın. Echo $SHELL yaparak kontrol sağlayın eğerki zsh'da iseniz bash gecin ctrl+f ve ctrl+r kullanmaya başlayın.

### Dip Not
- Kişisel dosyalarım olduğu için herhangi bir hatada yardımcı olmuyorum sizinle paylaşmak istedim sadece bir teşekkür yeterli olur.
