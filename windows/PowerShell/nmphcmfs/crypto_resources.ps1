function crypto {
    # fzf kontrolü: fzf yüklü değilse hata mesajı verip çıkış yapar.
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Error "fzf bulunamadı. Lütfen fzf'yi kurun ve tekrar deneyin."
        return
    }

    # --- Detaylı Açıklamalar ---
    $detailed = @{
        "WalletExplorer.com"  = "Bu platform, blockchain üzerinde yer alan cüzdan adreslerini derinlemesine analiz eden profesyonel bir araçtır. Cüzdanlar arasındaki bağlantıları, işlem geçmişlerini ve etkileşimleri detaylı şekilde gözler önüne serer. Böylece, belirli adreslerin faaliyetlerini analiz ederek olası anormallikleri ve şüpheli aktiviteleri tespit edebilirsiniz."
        "Blockchain.info"     = "Blockchain.info, Bitcoin ve diğer kripto paraların blok zinciri üzerindeki işlemlerini izleme imkanı sunan kapsamlı bir gezgin hizmetidir. Cüzdan bakiyeleri, işlem geçmişleri ve blok detayları hakkında ayrıntılı bilgi sunarak verilerin şeffaflığını ve doğruluğunu kontrol etmenizi sağlar."
        "BitcoinWhosWho.com"   = "Bu platform, belirli bir Bitcoin adresinin sahibi hakkında bilgi edinmenizi ve geçmişte dolandırıcılık ya da şüpheli faaliyetlerle ilişkilendirilip ilişkilendirilmediğini kontrol etmenizi sağlar. Güvenlik açısından önemli veriler sunarak, adreslerin güvenilirliğini değerlendirme konusunda rehberlik eder."
        "ChipMixer.com"        = "ChipMixer, Bitcoin işlemlerinin anonimleştirilmesi amacıyla kullanılan yenilikçi bir coin karıştırma servisidir. İşlemleri küçük parçalara bölüp farklı adreslere yönlendirerek, işlem izlerinin karışmasını sağlar; böylece kullanıcıların finansal gizliliğini artırır."
        "BlockExplorer.com"    = "BlockExplorer, Bitcoin ve diğer blockchain ağlarındaki işlemleri detaylı bir şekilde incelemenizi sağlayan profesyonel bir araçtır. Belirli işlem kimlikleri, cüzdan adresleri veya blok numaraları girilerek ilgili işlemlerin detaylarına ve doğruluklarına ulaşılabilir."
        "LocalBitcoins.com"    = "Eskiden popüler olan P2P Bitcoin ticaret platformu LocalBitcoins, kullanıcılar arasında doğrudan alım satım işlemlerinin gerçekleşmesine olanak tanıyordu. Platform, 2023 yılında faaliyetlerini sonlandırmış olsa da geçmişteki deneyimler açısından analiz edilebilir."
        "BitcoinBlender"       = "BitcoinBlender, kullanıcıların Bitcoin işlemlerini karıştırarak anonimliklerini ve finansal gizliliklerini artırmalarını sağlayan bir mixer servisidir. İşlemleri farklı adreslere yönlendirerek orijinal gönderici ve alıcının birbirinden ayrılmasını sağlar, böylece işlem izlerinin takibi zorlaşır."
        "Blockonomics"         = "Blockonomics, blockchain verilerinin analizini ve Bitcoin ödeme işlemlerinin takibini sağlayan kapsamlı bir platformdur. E-ticaret siteleri için Bitcoin ödeme altyapısı sunarken, belirli cüzdan adreslerinin işlem geçmişlerini detaylı olarak incelemenize olanak tanır."
        "BitcoinAbuse"         = "BitcoinAbuse, Bitcoin dolandırıcılığı ve kötüye kullanım faaliyetlerinin raporlandığı güvenilir bir veritabanıdır. Şüpheli veya dolandırıcılıkla ilişkilendirilen Bitcoin adreslerini bildirerek, geçmiş şüpheli aktiviteleri incelemenize olanak sağlar."
        "Ethscan"              = "Ethscan, Ethereum blok zinciri üzerindeki işlemleri, akıllı sözleşmeleri ve cüzdan bakiyelerini detaylı olarak incelemenizi sağlayan güçlü bir explorer hizmetidir. Ethereum ekosisteminde verilerin şeffaf ve izlenebilir olmasına katkıda bulunur."
        "Bscscan"              = "Bscscan, Binance Smart Chain (BSC) üzerindeki işlemleri ve akıllı sözleşmeleri detaylı olarak incelemenizi sağlayan profesyonel bir araçtır. Cüzdan bakiyeleri, işlem geçmişleri ve diğer önemli detaylara erişim sunarak BSC ekosisteminin güvenliğini destekler."
        "Aware-Online"         = "Aware-Online, kripto para cüzdan adreslerinin analizini ve izlenmesini sağlayan kapsamlı bir hizmettir. Blockchain üzerindeki hareketleri detaylı olarak gözlemleyerek potansiyel riskleri, güvenlik açıklarını ve anormallikleri tespit etmenize yardımcı olur."
        "OXT"                 = "OXT, Bitcoin ve diğer blockchain ağları üzerinde derinlemesine analiz yapmanızı sağlayan bir explorer hizmetidir. Cüzdan adreslerinin işlem geçmişleri, bağlantıları ve diğer analiz sonuçlarına erişim sunarak verilerin bütünsel incelenmesini mümkün kılar."
        "TokenSniffer.com"     = "TokenSniffer, kripto para dünyasında dolandırıcılık amacıyla oluşturulmuş sahte token'ları tespit etmek için geliştirilmiş bir platformdur. Akıllı sözleşme kodlarını detaylı şekilde analiz eder, potansiyel riskleri belirler ve şüpheli aktiviteleri raporlar."
        "TronScan"             = "TronScan, Tron blok zinciri üzerindeki işlemleri, cüzdan bakiyelerini ve akıllı sözleşmeleri detaylı olarak incelemenizi sağlayan profesyonel bir explorer'dır. TRX ve diğer Tron tabanlı token'ların işlemleri hakkında kapsamlı bilgi sunar."
    }

    # --- Kısa Açıklamalar (Menüde görüntülenecek) ---
    $short = @{
        "WalletExplorer.com"  = "Cüzdan adreslerini detaylı analiz eder."
        "Blockchain.info"     = "İşlemleri, bakiyeleri ve blok verilerini gözlemler."
        "BitcoinWhosWho.com"   = "BTC adres güvenilirliğini değerlendirir."
        "ChipMixer.com"        = "BTC işlemlerini anonimleştirir."
        "BlockExplorer.com"    = "İşlemleri detaylı inceler."
        "LocalBitcoins.com"    = "P2P BTC ticareti (eski platform)."
        "BitcoinBlender"       = "BTC'leri karıştırarak gizlilik sağlar."
        "Blockonomics"         = "Blockchain verilerini analiz eder."
        "BitcoinAbuse"         = "Dolandırıcılık raporlarını sunar."
        "Ethscan"              = "Ethereum işlemlerini inceler."
        "Bscscan"              = "BSC işlemlerini gözlemler."
        "Aware-Online"         = "Cüzdan analiz ve izleme yapar."
        "OXT"                 = "Verileri derinlemesine analiz eder."
        "TokenSniffer.com"     = "Sahte token tespitinde yardımcı olur."
        "TronScan"             = "Tron işlemlerini detaylı analiz eder."
    }

    # --- Resmi Web Sitesi Linkleri ---
    $links = @{
        "WalletExplorer.com"  = "https://www.walletexplorer.com"
        "Blockchain.info"     = "https://www.blockchain.info"
        "BitcoinWhosWho.com"   = "https://www.bitcoinwhoswho.com"
        "ChipMixer.com"        = "https://www.chipmixer.com"
        "BlockExplorer.com"    = "https://www.blockexplorer.com"
        "LocalBitcoins.com"    = "https://localbitcoins.com"
        "BitcoinBlender"       = "https://www.bitcoinblender.com"
        "Blockonomics"         = "https://www.blockonomics.co"
        "BitcoinAbuse"         = "https://www.bitcoinabuse.com"
        "Ethscan"              = "https://etherscan.io"
        "Bscscan"              = "https://www.bscscan.com"
        "Aware-Online"         = "https://aware.online"
        "OXT"                 = "https://www.oxt.me"
        "TokenSniffer.com"     = "https://www.tokensniffer.com"
        "TronScan"             = "https://tronscan.org"
    }

    # --- Menü Listesi Oluşturma (Platform - Kısa Açıklama) ---
    $list = $short.Keys | Sort-Object | ForEach-Object {
        "$_ - $($short[$_])"
    }

    Clear-Host
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "         Kripto ve Blockchain Kaynakları" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "Aşağıdaki listeden incelemek istediğiniz kaynağı seçiniz:" -ForegroundColor White
    Write-Host ""
    
    # --- fzf ile İnteraktif Seçim ---
    $selectedLine = $list | fzf --prompt="Kaynak Seçiniz: " --height=50% --layout=reverse --header="Platform"
    
    if ($selectedLine) {
        $selectedKey = $selectedLine.Split(" - ")[0]
        Clear-Host
        Write-Host "===================================================" -ForegroundColor Green
        Write-Host "              Seçilen Kripto Kaynağı" -ForegroundColor Cyan
        Write-Host "---------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "Platform Adı: " -NoNewline -ForegroundColor Yellow
        Write-Host "$selectedKey" -ForegroundColor White
        Write-Host ""
        Write-Host "Detaylı Açıklama:" -ForegroundColor Yellow
        Write-Host $detailed[$selectedKey] -ForegroundColor White
        Write-Host ""
        Write-Host "Resmi Web Sitesi: " -NoNewline -ForegroundColor Yellow
        Write-Host $links[$selectedKey] -ForegroundColor White
        Write-Host "===================================================" -ForegroundColor Green

        # --- Yeni Özellik: Rastgele Blockchain Bilgisi ---
        $facts = @(
            "Blockchain teknolojisi, merkeziyetsiz yapısıyla veri güvenliğini artırır.",
            "Bitcoin, 2009 yılında Satoshi Nakamoto tarafından piyasaya sürülmüştür.",
            "Ethereum, akıllı sözleşmeleri destekleyen öncü bir platformdur.",
            "Binance Smart Chain, hızlı ve düşük maliyetli işlemleriyle öne çıkar.",
            "Blockchain verileri değiştirilemez ve şeffaftır.",
            "Kripto para piyasası, küresel finansal sistemde devrim yaratmaktadır."
        )
        $randomFact = Get-Random -InputObject $facts
        Write-Host "`nBlockchain Bilgi:" -ForegroundColor Magenta
        Write-Host $randomFact -ForegroundColor White
    }
}
