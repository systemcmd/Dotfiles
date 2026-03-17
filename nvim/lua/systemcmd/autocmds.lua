local api = vim.api

api.nvim_create_autocmd("TextYankPost", {
  group = api.nvim_create_augroup("SystemcmdYankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 120 })
  end,
})

api.nvim_create_autocmd("BufReadPost", {
  group = api.nvim_create_augroup("SystemcmdRestoreCursor", { clear = true }),
  callback = function(event)
    local mark = api.nvim_buf_get_mark(event.buf, '"')
    local line_count = api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

api.nvim_create_autocmd("TermOpen", {
  group = api.nvim_create_augroup("SystemcmdTerminalMode", { clear = true }),
  command = "startinsert",
})
