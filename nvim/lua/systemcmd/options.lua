local opt = vim.opt

-- Görünüm
opt.termguicolors  = true
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes:1"
opt.showmode       = false
opt.laststatus     = 3
opt.cmdheight      = 1
opt.pumheight      = 12
opt.fillchars      = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸", foldsep = "│" }
opt.list           = true
opt.listchars      = { tab = "→ ", trail = "·", nbsp = "·" }

-- Düzenleme
opt.mouse        = "a"
opt.clipboard    = "unnamedplus"
opt.tabstop      = 2
opt.shiftwidth   = 2
opt.softtabstop  = 2
opt.expandtab    = true
opt.smartindent  = true
opt.autoindent   = true
opt.wrap         = false
opt.undofile     = true
opt.undolevels   = 10000
opt.confirm      = true
opt.virtualedit  = "block"
opt.formatoptions = "jcroqlnt"

-- Arama
opt.ignorecase  = true
opt.smartcase   = true
opt.hlsearch    = true
opt.incsearch   = true
opt.inccommand  = "split"
opt.grepprg     = "rg --vimgrep --smart-case"
opt.grepformat  = "%f:%l:%c:%m"

-- Performans
opt.updatetime  = 200
opt.timeoutlen  = 300
opt.redrawtime  = 10000

-- Pencere
opt.splitright    = true
opt.splitbelow    = true
opt.scrolloff     = 8
opt.sidescrolloff = 8

-- Tamamlama
opt.completeopt = { "menu", "menuone", "noselect" }

-- Katlama (treesitter)
opt.foldmethod = "expr"
opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel  = 99
opt.foldtext   = ""

-- Mesaj kısaltmaları (gereksiz İngilizce bildirimleri bastır)
opt.shortmess:append("sWcC")

-- Türkçe yardım (varsa)
opt.helplang = "tr,en"
