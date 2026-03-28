local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup("systemcmd_" .. name, { clear = true })
end

-- Yank sonrası vurgula
api.nvim_create_autocmd("TextYankPost", {
  group    = augroup("yank_highlight"),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Dosya açıldığında imleç son pozisyona git
api.nvim_create_autocmd("BufReadPost", {
  group    = augroup("restore_cursor"),
  callback = function(event)
    local mark       = api.nvim_buf_get_mark(event.buf, '"')
    local line_count = api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Terminal açıldığında insert moduna geç
api.nvim_create_autocmd("TermOpen", {
  group   = augroup("terminal_mode"),
  command = "startinsert | setlocal nonumber norelativenumber signcolumn=no",
})

-- Büyük dosyalarda ağır özellikleri kapat
api.nvim_create_autocmd("BufReadPre", {
  group    = augroup("large_file"),
  callback = function(event)
    local ok, stat = pcall(vim.loop.fs_stat, event.match)
    if ok and stat and stat.size > 1024 * 1024 then  -- 1 MB
      vim.b[event.buf].large_file = true
      vim.opt_local.syntax = "off"
      vim.opt_local.filetype = ""
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.list = false
    end
  end,
})

-- Pencereye geçince satır numaralarını ayarla
api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group    = augroup("smart_numbers"),
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = true
      vim.opt_local.number         = true
    end
  end,
})
api.nvim_create_autocmd({ "WinLeave" }, {
  group    = augroup("smart_numbers_leave"),
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Özel filetypes için wrap aç
api.nvim_create_autocmd("FileType", {
  group   = augroup("wrap_spell"),
  pattern = { "markdown", "gitcommit", "text" },
  command = "setlocal wrap spell spelllang=tr,en",
})

-- Parantez denge imlecini vurgulama gecikmesini kaldır
api.nvim_create_autocmd("CursorMoved", {
  group    = augroup("match_paren_fast"),
  callback = function()
    if vim.o.updatetime > 100 then return end
  end,
})

-- Otomatik hlsearch kapat
api.nvim_create_autocmd("InsertEnter", {
  group   = augroup("no_hlsearch_insert"),
  command = "nohlsearch",
})

-- Resize pencereleri eşitle
api.nvim_create_autocmd("VimResized", {
  group   = augroup("resize_splits"),
  command = "tabdo wincmd =",
})

-- LSP bağlantısında tanılama Türkçe başlık göster
api.nvim_create_autocmd("LspAttach", {
  group    = augroup("lsp_attach_msg"),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      vim.notify(
        "  " .. client.name .. " bağlandı",
        vim.log.levels.INFO,
        { title = "Dil Sunucusu" }
      )
    end
  end,
})

-- Neovim başlangıç mesajı Türkçe
api.nvim_create_autocmd("VimEnter", {
  group    = augroup("welcome"),
  once     = true,
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        vim.cmd("echo ''")
      end)
    end
  end,
})
