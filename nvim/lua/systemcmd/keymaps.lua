local map = vim.keymap.set

-- Arama temizle
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Aramayı temizle" })

-- Kaydet / Çık
map({ "n", "v" }, "<C-s>", "<cmd>write<cr>",       { silent = true, desc = "Kaydet" })
map("i",          "<C-s>", "<Esc><cmd>write<cr>a",  { silent = true, desc = "Kaydet" })
map("n", "<leader>w", "<cmd>write<cr>",             { desc = "Kaydet" })
map("n", "<leader>q", "<cmd>quit<cr>",              { desc = "Pencereyi kapat" })
map("n", "<leader>Q", "<cmd>qall!<cr>",             { desc = "Hepsini kapat" })

-- Pano  (Ctrl+C / Ctrl+V Windows tarzı)
map("n", "<C-c>", '"+yy',    { silent = true, desc = "Satırı panoya kopyala" })
map("v", "<C-c>", '"+y',     { silent = true, desc = "Seçimi panoya kopyala" })
map("n", "<C-v>", '"+p',     { silent = true, desc = "Panodan yapıştır" })
map("v", "<C-v>", '"_d"+P',  { silent = true, desc = "Seçimin üzerine yapıştır" })
map("i", "<C-v>", "<C-r>+",  { silent = true, desc = "Panodan yapıştır" })
map("c", "<C-v>", "<C-r>+",  { silent = true, desc = "Panodan yapıştır" })
map("n", "<C-a>", "ggVG",    { desc = "Hepsini seç" })
-- Visual block (Ctrl+V yeniden atandığından)
map("n", "<C-q>", "<C-v>",   { desc = "Görsel blok modu" })
-- Tek karakter silme yank'a gitmez
map("n", "x", '"_x', { desc = "Karakteri sil (yank yok)" })

-- Pencere gezinti
map("n", "<C-h>", "<C-w>h", { desc = "Sol pencere" })
map("n", "<C-j>", "<C-w>j", { desc = "Aşağı pencere" })
map("n", "<C-k>", "<C-w>k", { desc = "Yukarı pencere" })
map("n", "<C-l>", "<C-w>l", { desc = "Sağ pencere" })

-- Pencere boyutu
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Pencereyi büyüt" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Pencereyi küçült" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Pencereyi daralt" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Pencereyi genişlet" })

-- Buffer gezinti
map("n", "<Tab>",   "<cmd>bnext<cr>",     { desc = "Sonraki buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Önceki buffer" })

-- Satır taşı
map("n", "<A-j>", "<cmd>m .+1<cr>==",         { silent = true, desc = "Satırı aşağı taşı" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",         { silent = true, desc = "Satırı yukarı taşı" })
map("i", "<A-j>", "<Esc><cmd>m .+1<cr>==gi",  { silent = true, desc = "Satırı aşağı taşı" })
map("i", "<A-k>", "<Esc><cmd>m .-2<cr>==gi",  { silent = true, desc = "Satırı yukarı taşı" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",        { silent = true, desc = "Seçimi aşağı taşı" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",        { silent = true, desc = "Seçimi yukarı taşı" })

-- Girinti koru
map("v", "<", "<gv", { desc = "Sola girint" })
map("v", ">", ">gv", { desc = "Sağa girint" })

-- Yank olmadan sil
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Yank'sız sil" })

-- Sayfa yarısı gezerken ortala
map("n", "<C-d>", "<C-d>zz", { desc = "Yarım sayfa aşağı (ortala)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Yarım sayfa yukarı (ortala)" })
map("n", "n",     "nzzzv",   { desc = "Sonraki eşleşme (ortala)" })
map("n", "N",     "Nzzzv",   { desc = "Önceki eşleşme (ortala)" })

-- Satır birleştirirken imleci yerinde tut
map("n", "J", "mzJ`z", { desc = "Satırları birleştir" })

-- Diagnostics
map("n", "[d",         vim.diagnostic.goto_prev,   { desc = "Önceki tanı" })
map("n", "]d",         vim.diagnostic.goto_next,   { desc = "Sonraki tanı" })
map("n", "<leader>cd", vim.diagnostic.open_float,  { desc = "Tanı ayrıntıları" })

-- Terminal
map("n", "<leader>t",  "<cmd>split | terminal<cr>", { desc = "Terminal aç" })
map("t", "<Esc><Esc>", "<C-\\><C-n>",               { desc = "Terminal modundan çık" })

-- Quickfix
map("n", "]q", "<cmd>cnext<cr>",  { desc = "Sonraki quickfix" })
map("n", "[q", "<cmd>cprev<cr>",  { desc = "Önceki quickfix" })

-- Türkçe yardım penceresi
map("n", "<F1>",       function() require("systemcmd.cheatsheet").open() end, { desc = "Türkçe yardım" })
map("n", "<leader>?",  function() require("systemcmd.cheatsheet").open() end, { desc = "Türkçe yardım" })
