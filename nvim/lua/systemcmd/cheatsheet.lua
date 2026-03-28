-- systemcmd yardım penceresi — tüm tuş haritaları Türkçe
local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
--  Bölümler ve girişler
-- ─────────────────────────────────────────────────────────────────────────────
local sections = {
  {
    icon  = " ",
    title = "TEMEL İŞLEMLER",
    color = "CSHelpBlue",
    entries = {
      { key = "<Esc>",          desc = "Arama vurgusunu temizle" },
      { key = "Ctrl+S",         desc = "Dosyayı kaydet (tüm modlarda)" },
      { key = "<Space>w",       desc = "Dosyayı kaydet" },
      { key = "<Space>q",       desc = "Pencereyi kapat" },
      { key = "<Space>Q",       desc = "Hepsini kapat (zorla)" },
      { key = "u",              desc = "Geri al" },
      { key = "Ctrl+R",         desc = "İleri al" },
      { key = "Ctrl+A",         desc = "Hepsini seç (ggVG)" },
      { key = ".",              desc = "Son komutu tekrarla" },
      { key = "Ctrl+Q",         desc = "Görsel blok modu" },
    },
  },
  {
    icon  = " ",
    title = "PANO & KOPYALA/YAPIŞTIR",
    color = "CSHelpGreen",
    entries = {
      { key = "Ctrl+C",         desc = "Satırı / seçimi panoya kopyala" },
      { key = "Ctrl+V",         desc = "Panodan yapıştır" },
      { key = "yy",             desc = "Satırı kopyala (yank)" },
      { key = "y + hareket",    desc = "Hareket alanını kopyala (yw, y$…)" },
      { key = "p / P",          desc = "Sonrasına / öncesine yapıştır" },
      { key = "\"+y",           desc = "Sistem panosuna kopyala" },
      { key = "\"+p",           desc = "Sistem panosundan yapıştır" },
      { key = "<Space>d",       desc = "Yank yapmadan sil" },
      { key = "x",              desc = "Karakteri sil (yank yok)" },
    },
  },
  {
    icon  = "󰈙 ",
    title = "DOSYA & BUFFER",
    color = "CSHelpCyan",
    entries = {
      { key = "<Space>ff",      desc = "Dosya bul (Telescope)" },
      { key = "<Space>fr",      desc = "Son açılan dosyalar" },
      { key = "<Space>fb",      desc = "Açık dosyalar listesi" },
      { key = "<Space>e",       desc = "Dosya gezginini aç/kapat" },
      { key = "<Space>E",       desc = "Mevcut dosyayı gezginde göster" },
      { key = "Tab",            desc = "Sonraki buffer" },
      { key = "Shift+Tab",      desc = "Önceki buffer" },
      { key = "<Space>bp",      desc = "Buffer'ı sabitle/çöz" },
      { key = "<Space>bx",      desc = "Diğer tüm buffer'ları kapat" },
      { key = "<Space>bl",      desc = "Soldaki buffer'ları kapat" },
      { key = "<Space>br",      desc = "Sağdaki buffer'ları kapat" },
    },
  },
  {
    icon  = " ",
    title = "ARAMA & GREP",
    color = "CSHelpMagenta",
    entries = {
      { key = "/",              desc = "İleri ara" },
      { key = "?",              desc = "Geri ara" },
      { key = "n / N",          desc = "Sonraki / önceki eşleşme (ortala)" },
      { key = "<Space>/",       desc = "Buffer içinde fuzzy ara" },
      { key = "<Space>fg",      desc = "Tüm dosyalarda içerik ara (grep)" },
      { key = "<Space>fh",      desc = "Yardım konularında ara" },
      { key = "<Space>fk",      desc = "Tuş haritalarında ara" },
      { key = "<Space>fc",      desc = "Komutlarda ara" },
      { key = "<Space>ft",      desc = "TODO/FIX/NOTE yorum ara" },
    },
  },
  {
    icon  = "󰆧 ",
    title = "KOD DÜZENLEME",
    color = "CSHelpYellow",
    entries = {
      { key = "gcc",            desc = "Satırı yorum yap / kaldır" },
      { key = "gc + hareket",   desc = "Hareket alanını yorum yap (gcip…)" },
      { key = "gb + hareket",   desc = "Blok yorum yap" },
      { key = "ys{hareket}{c}", desc = "Çevresine karakter sar (ysiw\")" },
      { key = "cs{eski}{yeni}", desc = "Çevreleyen karakteri değiştir (cs\"')" },
      { key = "ds{karakter}",   desc = "Çevreleyen karakteri sil (ds\")" },
      { key = "< / >",          desc = "Seçimi sola/sağa girintile (görsel)" },
      { key = "Alt+J/K",        desc = "Satırı/seçimi yukarı/aşağı taşı" },
      { key = "Ctrl+Space",     desc = "Treesitter ile seçimi büyüt" },
      { key = "<Space>cf",      desc = "Dosyayı formatla" },
    },
  },
  {
    icon  = " ",
    title = "PENCERE YÖNETİMİ",
    color = "CSHelpBlue",
    entries = {
      { key = "Ctrl+H/J/K/L",   desc = "Sol/aşağı/yukarı/sağ pencereye geç" },
      { key = "Ctrl+↑/↓",       desc = "Pencere yüksekliğini artır/azalt" },
      { key = "Ctrl+←/→",       desc = "Pencere genişliğini azalt/artır" },
      { key = ":sp",            desc = "Yatay böl" },
      { key = ":vsp",           desc = "Dikey böl" },
      { key = "<Space>t",       desc = "Alt pencerede terminal aç" },
      { key = "Esc Esc",        desc = "Terminal modundan çık" },
    },
  },
  {
    icon  = " ",
    title = "LSP (DİL SUNUCUSU)",
    color = "CSHelpCyan",
    entries = {
      { key = "gd",             desc = "Tanıma git (go to definition)" },
      { key = "gD",             desc = "Bildirimine git (declaration)" },
      { key = "gr",             desc = "Tüm referansları listele" },
      { key = "gI",             desc = "Uygulamaya git (implementation)" },
      { key = "gy",             desc = "Tür tanımına git" },
      { key = "K",              desc = "Belge göster (hover)" },
      { key = "gK",             desc = "İmza yardımı göster" },
      { key = "<Space>rn",      desc = "Sembolü yeniden adlandır" },
      { key = "<Space>ca",      desc = "Kod aksiyonu (hata düzeltme vb.)" },
      { key = "<Space>cf",      desc = "LSP ile dosyayı formatla" },
    },
  },
  {
    icon  = " ",
    title = "TAMAMLAMA (CMP)",
    color = "CSHelpGreen",
    entries = {
      { key = "Ctrl+Space",     desc = "Tamamlamayı zorla aç" },
      { key = "Ctrl+N / Ctrl+P",desc = "Listede aşağı / yukarı git" },
      { key = "Tab / Shift+Tab",desc = "Tamamla / snippet sonrakine atla" },
      { key = "Enter",          desc = "Seçili öğeyi onayla" },
      { key = "Ctrl+E",         desc = "Tamamlamayı iptal et" },
      { key = "Ctrl+B / Ctrl+F",desc = "Belgeyi yukarı / aşağı kaydır" },
    },
  },
  {
    icon  = " ",
    title = "GİT İŞLEMLERİ",
    color = "CSHelpMagenta",
    entries = {
      { key = "]h / [h",        desc = "Sonraki / önceki git değişikliği" },
      { key = "<Space>hs",      desc = "Değişikliği staged'e al" },
      { key = "<Space>hr",      desc = "Değişikliği sıfırla" },
      { key = "<Space>hS",      desc = "Tüm dosyayı staged'e al" },
      { key = "<Space>hR",      desc = "Tüm dosyayı sıfırla" },
      { key = "<Space>hp",      desc = "Değişikliği önizle" },
      { key = "<Space>hb",      desc = "Satır blame (kim yazdı)" },
      { key = "<Space>hB",      desc = "Satır blame'i aç/kapat" },
      { key = "<Space>hd",      desc = "Diff göster" },
      { key = "<Space>gs",      desc = "Git durumu (Telescope)" },
      { key = "<Space>gc",      desc = "Git commit geçmişi" },
    },
  },
  {
    icon  = " ",
    title = "TANI & SORUNLAR",
    color = "CSHelpYellow",
    entries = {
      { key = "[d / ]d",        desc = "Önceki / sonraki tanı" },
      { key = "<Space>cd",      desc = "Satır tanısını göster (float)" },
      { key = "<Space>xx",      desc = "Tüm tanılar listesi (Trouble)" },
      { key = "<Space>xb",      desc = "Bu dosyanın tanıları" },
      { key = "<Space>xs",      desc = "Sembol listesi" },
      { key = "<Space>xL",      desc = "Konum listesi" },
      { key = "<Space>xQ",      desc = "Quickfix listesi" },
      { key = "[q / ]q",        desc = "Önceki / sonraki quickfix" },
    },
  },
  {
    icon  = "󰆋 ",
    title = "HIZLI GEZİNTİ (FLASH)",
    color = "CSHelpCyan",
    entries = {
      { key = "s",              desc = "Flash: ekranda herhangi bir yere atla" },
      { key = "S",              desc = "Flash Treesitter: söz dizimi düğümüne atla" },
      { key = "Ctrl+D/U",       desc = "Yarım sayfa aşağı/yukarı (ortala)" },
      { key = "H / L",          desc = "Satır başı / satır sonu (görsel/normal)" },
      { key = "zz / zt / zb",   desc = "İmleci ortala / üste / alta" },
      { key = "% ",             desc = "Eşleşen paranteze atla" },
    },
  },
  {
    icon  = " ",
    title = "KATLAMA (FOLD)",
    color = "CSHelpBlue",
    entries = {
      { key = "za",             desc = "Katlamayı aç/kapat" },
      { key = "zo / zc",        desc = "Kat aç / kapat" },
      { key = "zR / zM",        desc = "Tüm katları aç / kapat" },
      { key = "zd",             desc = "Katlamayı sil" },
      { key = "[z / ]z",        desc = "Önceki / sonraki katlama" },
    },
  },
}

-- ─────────────────────────────────────────────────────────────────────────────
--  Yardım penceresi
-- ─────────────────────────────────────────────────────────────────────────────
local STATE = { buf = nil, win = nil }

local function close()
  if STATE.win and vim.api.nvim_win_is_valid(STATE.win) then
    vim.api.nvim_win_close(STATE.win, true)
  end
  if STATE.buf and vim.api.nvim_buf_is_valid(STATE.buf) then
    vim.api.nvim_buf_delete(STATE.buf, { force = true })
  end
  STATE.buf = nil
  STATE.win = nil
end

local function build_lines(width)
  local lines      = {}
  local highlights = {}   -- { line, col_start, col_end, hl_group }
  local col_width  = math.floor(width * 0.42)  -- tuş sütunu genişliği

  local function add_line(text, hl)
    lines[#lines + 1] = text
    if hl then
      highlights[#highlights + 1] = { #lines - 1, 0, #text, hl }
    end
  end

  -- Başlık
  local title = "  Neovim Türkçe Tuş Haritası Rehberi  "
  local pad   = math.floor((width - #title) / 2)
  add_line(string.rep(" ", pad) .. title, "CSHelpTitle")
  add_line(string.rep("─", width), "CSHelpBorder")
  add_line("  q veya Esc → kapat     ↑↓/j k → kaydır", "CSHelpMuted")
  add_line(string.rep("─", width), "CSHelpBorder")

  local per_col   = math.ceil(#sections / 2)
  local col_pairs = {}
  for i = 1, per_col do
    col_pairs[i] = { sections[i], sections[i + per_col] }
  end

  for _, pair in ipairs(col_pairs) do
    add_line("", nil)   -- boşluk satırı

    -- Bölüm başlıkları (yan yana)
    local function section_header(sec)
      if not sec then return "" end
      return (sec.icon or "") .. sec.title
    end
    local lh = section_header(pair[1])
    local rh = section_header(pair[2])
    local header_line = lh .. string.rep(" ", math.max(1, col_width - #lh)) .. "  " .. rh
    lines[#lines + 1] = header_line
    -- Sol başlık rengi
    if pair[1] then
      highlights[#highlights + 1] = { #lines - 1, 0, #lh, pair[1].color or "CSHelpBlue" }
    end
    -- Sağ başlık rengi
    if pair[2] then
      local off = col_width + 2
      highlights[#highlights + 1] = { #lines - 1, off, off + #rh, pair[2].color or "CSHelpBlue" }
    end
    add_line(
      string.rep("▔", col_width - 1) .. "  " .. string.rep("▔", col_width - 1),
      "CSHelpDim"
    )

    -- Girişler
    local max_rows = 0
    if pair[1] then max_rows = math.max(max_rows, #pair[1].entries) end
    if pair[2] then max_rows = math.max(max_rows, #pair[2].entries) end

    for i = 1, max_rows do
      local left_str  = ""
      local right_str = ""

      local function entry_str(sec, idx)
        if not sec or not sec.entries[idx] then return "" end
        local e   = sec.entries[idx]
        local key = e.key
        local gap = math.max(1, 18 - #key)
        return "  " .. key .. string.rep(" ", gap) .. e.desc
      end

      left_str  = entry_str(pair[1], i)
      right_str = entry_str(pair[2], i)

      -- Satırı birleştir
      local padded = left_str .. string.rep(" ", math.max(0, col_width - #left_str))
      local full   = padded .. "  " .. right_str

      lines[#lines + 1] = full

      -- Sol tuş rengi
      if pair[1] and pair[1].entries[i] then
        local ks = 2
        local ke = ks + #pair[1].entries[i].key
        highlights[#highlights + 1] = { #lines - 1, ks, ke, "CSHelpKey" }
      end
      -- Sağ tuş rengi
      if pair[2] and pair[2].entries[i] then
        local offset = col_width + 4
        local ke     = offset + #pair[2].entries[i].key
        highlights[#highlights + 1] = { #lines - 1, offset, ke, "CSHelpKey" }
      end
    end
  end

  add_line("", nil)
  add_line(string.rep("─", width), "CSHelpBorder")
  add_line("  F1 veya <Space>? → bu pencereyi aç/kapat", "CSHelpMuted")

  return lines, highlights
end

function M.open()
  if STATE.win and vim.api.nvim_win_is_valid(STATE.win) then
    close()
    return
  end

  -- Pencere boyutları
  local ui      = vim.api.nvim_list_uis()[1]
  local width   = math.min(math.floor(ui.width  * 0.94), 160)
  local height  = math.min(math.floor(ui.height * 0.90), 52)
  local row     = math.floor((ui.height - height) / 2)
  local col     = math.floor((ui.width  - width)  / 2)

  -- Buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden  = "wipe"
  vim.bo[buf].buftype    = "nofile"
  vim.bo[buf].filetype   = "systemcmd-help"
  vim.bo[buf].modifiable = true

  local lines, highlights = build_lines(width)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Highlight grupları
  local ns = vim.api.nvim_create_namespace("systemcmd_help")
  for _, h in ipairs(highlights) do
    local l, cs, ce, grp = h[1], h[2], h[3], h[4]
    pcall(vim.api.nvim_buf_add_highlight, buf, ns, grp, l, cs, ce)
  end

  -- Pencere
  local win = vim.api.nvim_open_win(buf, true, {
    style    = "minimal",
    relative = "editor",
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    border   = "rounded",
    title    = "  Neovim Yardım  ",
    title_pos= "center",
  })
  vim.wo[win].wrap        = false
  vim.wo[win].cursorline  = true
  vim.wo[win].number      = false
  vim.wo[win].scrolloff   = 3

  STATE.buf = buf
  STATE.win = win

  -- Kapat tuşları
  for _, key in ipairs({ "q", "<Esc>", "<F1>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, silent = true })
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Highlight grupları (tema ile uyumlu)
-- ─────────────────────────────────────────────────────────────────────────────
function M.setup_highlights()
  local hi = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end
  hi("CSHelpTitle",   { fg = "#5c78ff", bold = true })
  hi("CSHelpBorder",  { fg = "#3a3a3a" })
  hi("CSHelpDim",     { fg = "#2f2f2f" })
  hi("CSHelpMuted",   { fg = "#7e7e7e", italic = true })
  hi("CSHelpKey",     { fg = "#5ac8ff", bold = true })
  hi("CSHelpBlue",    { fg = "#5c78ff", bold = true })
  hi("CSHelpCyan",    { fg = "#5ac8ff", bold = true })
  hi("CSHelpGreen",   { fg = "#5effc3", bold = true })
  hi("CSHelpMagenta", { fg = "#ff5eed", bold = true })
  hi("CSHelpYellow",  { fg = "#ffd080", bold = true })
  hi("CSHelpOrange",  { fg = "#d38454", bold = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
--  :h / :help komutunu ele geç
--    • argümansız → Türkçe yardım aç
--    • argümanlı  → orijinal :help devam eder (motion.txt, options…)
-- ─────────────────────────────────────────────────────────────────────────────
local function setup_help_override()
  -- :Yardim komutu
  vim.api.nvim_create_user_command("Yardim", function()
    M.open()
  end, { desc = "Türkçe yardım penceresini aç" })

  -- :Help argümansız → Türkçe, argümanlı → orijinal
  vim.api.nvim_create_user_command("Help", function(opts)
    if opts.args == "" then
      M.open()
    else
      vim.cmd("help " .. opts.args)
    end
  end, { nargs = "?", complete = "help", desc = "Türkçe yardım veya :help <konu>" })

  -- :h ve :help kısaltmalarını ele geç
  -- (cnoreabbrev: sadece komut satırının başında çalışır)
  vim.cmd([[
    cnoreabbrev <expr> h  (getcmdtype() ==# ':' && getcmdline() ==# 'h')  ? 'Help' : 'h'
    cnoreabbrev <expr> he (getcmdtype() ==# ':' && getcmdline() ==# 'he') ? 'Help' : 'he'
    cnoreabbrev <expr> hel (getcmdtype() ==# ':' && getcmdline() ==# 'hel') ? 'Help' : 'hel'
    cnoreabbrev <expr> help (getcmdtype() ==# ':' && getcmdline() ==# 'help') ? 'Help' : 'help'
  ]])
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Ana kurulum (init.lua'dan çağrılır)
-- ─────────────────────────────────────────────────────────────────────────────
function M.setup()
  M.setup_highlights()
  setup_help_override()
end

return M
