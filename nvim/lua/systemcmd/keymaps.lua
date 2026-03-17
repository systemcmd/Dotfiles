local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { silent = true, desc = "Clear search highlight" })

map({ "n", "v" }, "<C-s>", "<cmd>write<cr>", { silent = true, desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>write<cr>a", { silent = true, desc = "Save file" })

map("n", "<leader>w", "<cmd>write<cr>", { silent = true, desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { silent = true, desc = "Quit window" })
map("n", "<leader>e", "<cmd>Ex<cr>", { silent = true, desc = "Open file explorer" })

map("n", "<C-c>", '"+yy', { silent = true, desc = "Copy current line to clipboard" })
map("v", "<C-c>", '"+y', { silent = true, desc = "Copy selection to clipboard" })

map("n", "<C-v>", '"+p', { silent = true, desc = "Paste clipboard after cursor" })
map("v", "<C-v>", '"_d"+P', { silent = true, desc = "Paste clipboard over selection" })
map("i", "<C-v>", "<C-r>+", { silent = true, desc = "Paste clipboard" })
map("c", "<C-v>", "<C-r>+", { silent = true, desc = "Paste clipboard" })
