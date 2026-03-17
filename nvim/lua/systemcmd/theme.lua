local M = {}

local palette = {
  bg = "#1d1d1d",
  panel = "#171717",
  surface = "#2f2f2f",
  line = "#242424",
  fg = "#d1d1d1",
  muted = "#7e7e7e",
  comment = "#6f7480",
  blue = "#5c78ff",
  cyan = "#5ac8ff",
  magenta = "#ff5eed",
  purple = "#ba5aff",
  green = "#5effc3",
  red = "#d35454",
  orange = "#d38454",
  selection = "#2f2f2f",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "systemcmd-color"

  hi("Normal", { fg = palette.fg, bg = palette.bg })
  hi("NormalFloat", { fg = palette.fg, bg = palette.panel })
  hi("FloatBorder", { fg = palette.blue, bg = palette.panel })
  hi("Comment", { fg = palette.comment, italic = true })
  hi("Constant", { fg = palette.green })
  hi("String", { fg = palette.purple })
  hi("Character", { fg = palette.purple })
  hi("Number", { fg = palette.green })
  hi("Boolean", { fg = palette.green })
  hi("Identifier", { fg = palette.blue })
  hi("Function", { fg = palette.cyan })
  hi("Statement", { fg = palette.magenta })
  hi("Keyword", { fg = palette.magenta })
  hi("Operator", { fg = palette.magenta })
  hi("Type", { fg = palette.fg })
  hi("Special", { fg = palette.cyan })
  hi("Delimiter", { fg = palette.fg })
  hi("Visual", { bg = palette.selection })
  hi("Search", { fg = palette.bg, bg = palette.green })
  hi("IncSearch", { fg = palette.bg, bg = palette.cyan })
  hi("LineNr", { fg = palette.muted, bg = palette.bg })
  hi("CursorLineNr", { fg = palette.fg, bg = palette.line, bold = true })
  hi("CursorLine", { bg = palette.line })
  hi("SignColumn", { fg = palette.muted, bg = palette.bg })
  hi("Pmenu", { fg = palette.fg, bg = palette.panel })
  hi("PmenuSel", { fg = palette.fg, bg = palette.surface })
  hi("StatusLine", { fg = palette.fg, bg = palette.panel })
  hi("StatusLineNC", { fg = palette.muted, bg = palette.panel })
  hi("VertSplit", { fg = palette.surface, bg = palette.bg })
  hi("WinSeparator", { fg = palette.surface, bg = palette.bg })
  hi("Directory", { fg = palette.cyan })
  hi("Error", { fg = palette.red, bg = palette.bg, bold = true })
  hi("WarningMsg", { fg = palette.orange, bg = palette.bg })
  hi("DiffAdd", { fg = palette.green, bg = palette.bg })
  hi("DiffChange", { fg = palette.cyan, bg = palette.bg })
  hi("DiffDelete", { fg = palette.magenta, bg = palette.bg })
  hi("DiffText", { fg = palette.blue, bg = palette.bg, bold = true })

  vim.opt.statusline =
    table.concat({
      "%#StatusLine#",
      " %f",
      "%m%r",
      "%=",
      "%#StatusLine#",
      " %y ",
      "%#StatusLineNC#",
      " %l:%c ",
    })
end

return M
