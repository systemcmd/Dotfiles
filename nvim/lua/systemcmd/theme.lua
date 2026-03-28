local M = {}

local p = {
  bg        = "#1d1d1d",
  panel     = "#171717",
  surface   = "#2a2a2a",
  line      = "#242424",
  border    = "#3a3a3a",
  fg        = "#d1d1d1",
  muted     = "#7e7e7e",
  comment   = "#6f7480",
  blue      = "#5c78ff",
  cyan      = "#5ac8ff",
  magenta   = "#ff5eed",
  purple    = "#ba5aff",
  green     = "#5effc3",
  yellow    = "#ffd080",
  red       = "#d35454",
  orange    = "#d38454",
  selection = "#303030",
  -- Diff arka planlar
  diff_add  = "#1a2d22",
  diff_chg  = "#1a2535",
  diff_del  = "#2d1a1a",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "systemcmd-color"

  -- ── Temel ──────────────────────────────────────────────────────────
  hi("Normal",          { fg = p.fg,     bg = p.bg })
  hi("NormalFloat",     { fg = p.fg,     bg = p.panel })
  hi("NormalNC",        { fg = p.fg,     bg = p.bg })
  hi("FloatBorder",     { fg = p.border, bg = p.panel })
  hi("FloatTitle",      { fg = p.blue,   bg = p.panel, bold = true })
  hi("FloatFooter",     { fg = p.muted,  bg = p.panel })
  hi("Pmenu",           { fg = p.fg,     bg = p.panel })
  hi("PmenuSel",        { fg = p.fg,     bg = p.surface, bold = true })
  hi("PmenuSbar",       { bg = p.surface })
  hi("PmenuThumb",      { bg = p.muted })
  hi("PmenuExtra",      { fg = p.muted,  bg = p.panel })
  hi("PmenuExtraSel",   { fg = p.fg,     bg = p.surface })
  hi("WildMenu",        { fg = p.bg,     bg = p.cyan })

  -- ── Söz dizimi ─────────────────────────────────────────────────────
  hi("Comment",         { fg = p.comment, italic = true })
  hi("Constant",        { fg = p.green })
  hi("String",          { fg = p.purple })
  hi("Character",       { fg = p.purple })
  hi("Number",          { fg = p.green })
  hi("Float",           { fg = p.green })
  hi("Boolean",         { fg = p.orange })
  hi("Identifier",      { fg = p.fg })
  hi("Function",        { fg = p.cyan })
  hi("Statement",       { fg = p.magenta })
  hi("Keyword",         { fg = p.magenta })
  hi("Conditional",     { fg = p.magenta })
  hi("Repeat",          { fg = p.magenta })
  hi("Label",           { fg = p.magenta })
  hi("Operator",        { fg = p.cyan })
  hi("Exception",       { fg = p.red })
  hi("PreProc",         { fg = p.orange })
  hi("Include",         { fg = p.magenta })
  hi("Define",          { fg = p.magenta })
  hi("Macro",           { fg = p.orange })
  hi("Type",            { fg = p.yellow })
  hi("StorageClass",    { fg = p.magenta })
  hi("Structure",       { fg = p.yellow })
  hi("Typedef",         { fg = p.yellow })
  hi("Special",         { fg = p.cyan })
  hi("SpecialChar",     { fg = p.orange })
  hi("Delimiter",       { fg = p.muted })
  hi("Todo",            { fg = p.orange, bold = true })
  hi("Underlined",      { fg = p.cyan,   underline = true })
  hi("Error",           { fg = p.red,    bold = true })

  -- ── Treesitter ─────────────────────────────────────────────────────
  hi("@comment",                  { link = "Comment" })
  hi("@comment.documentation",    { fg = p.comment, italic = true })
  hi("@keyword",                  { fg = p.magenta })
  hi("@keyword.function",         { fg = p.magenta })
  hi("@keyword.operator",         { fg = p.cyan })
  hi("@keyword.return",           { fg = p.magenta })
  hi("@keyword.import",           { fg = p.magenta })
  hi("@keyword.repeat",           { fg = p.magenta })
  hi("@keyword.conditional",      { fg = p.magenta })
  hi("@keyword.conditional.ternary", { fg = p.cyan })
  hi("@keyword.exception",        { fg = p.red })
  hi("@function",                 { fg = p.cyan })
  hi("@function.builtin",         { fg = p.cyan })
  hi("@function.call",            { fg = p.cyan })
  hi("@function.macro",           { fg = p.orange })
  hi("@function.method",          { fg = p.cyan })
  hi("@function.method.call",     { fg = p.cyan })
  hi("@constructor",              { fg = p.yellow })
  hi("@variable",                 { fg = p.fg })
  hi("@variable.builtin",         { fg = p.orange })
  hi("@variable.parameter",       { fg = p.fg })
  hi("@variable.member",          { fg = p.blue })
  hi("@property",                 { fg = p.blue })
  hi("@string",                   { fg = p.purple })
  hi("@string.escape",            { fg = p.orange })
  hi("@string.special",           { fg = p.orange })
  hi("@string.special.url",       { fg = p.cyan, underline = true })
  hi("@string.regex",             { fg = p.orange })
  hi("@number",                   { fg = p.green })
  hi("@number.float",             { fg = p.green })
  hi("@boolean",                  { fg = p.orange })
  hi("@constant",                 { fg = p.green })
  hi("@constant.builtin",         { fg = p.orange })
  hi("@constant.macro",           { fg = p.orange })
  hi("@type",                     { fg = p.yellow })
  hi("@type.builtin",             { fg = p.yellow })
  hi("@type.definition",          { fg = p.yellow })
  hi("@type.qualifier",           { fg = p.magenta })
  hi("@namespace",                { fg = p.blue })
  hi("@module",                   { fg = p.blue })
  hi("@label",                    { fg = p.magenta })
  hi("@operator",                 { fg = p.cyan })
  hi("@punctuation.bracket",      { fg = p.muted })
  hi("@punctuation.delimiter",    { fg = p.muted })
  hi("@punctuation.special",      { fg = p.cyan })
  hi("@tag",                      { fg = p.blue })
  hi("@tag.builtin",              { fg = p.magenta })
  hi("@tag.attribute",            { fg = p.green })
  hi("@tag.delimiter",            { fg = p.muted })
  hi("@markup.heading",           { fg = p.blue,  bold = true })
  hi("@markup.heading.1",         { fg = p.blue,  bold = true })
  hi("@markup.heading.2",         { fg = p.cyan,  bold = true })
  hi("@markup.heading.3",         { fg = p.green, bold = true })
  hi("@markup.italic",            { italic = true })
  hi("@markup.bold",              { bold = true })
  hi("@markup.underline",         { underline = true })
  hi("@markup.strikethrough",     { strikethrough = true })
  hi("@markup.link",              { fg = p.cyan, underline = true })
  hi("@markup.link.label",        { fg = p.blue })
  hi("@markup.raw",               { fg = p.green })
  hi("@markup.list",              { fg = p.magenta })
  hi("@markup.list.checked",      { fg = p.green })
  hi("@markup.list.unchecked",    { fg = p.muted })
  hi("@diff.plus",                { fg = p.green })
  hi("@diff.minus",               { fg = p.red })
  hi("@diff.delta",               { fg = p.cyan })

  -- ── LSP semantik ───────────────────────────────────────────────────
  hi("@lsp.type.class",           { link = "@type" })
  hi("@lsp.type.interface",       { link = "@type" })
  hi("@lsp.type.enum",            { link = "@type" })
  hi("@lsp.type.enumMember",      { link = "@constant" })
  hi("@lsp.type.function",        { link = "@function" })
  hi("@lsp.type.method",          { link = "@function.method" })
  hi("@lsp.type.namespace",       { link = "@namespace" })
  hi("@lsp.type.parameter",       { link = "@variable.parameter" })
  hi("@lsp.type.property",        { link = "@property" })
  hi("@lsp.type.variable",        { link = "@variable" })
  hi("@lsp.type.macro",           { link = "@function.macro" })
  hi("@lsp.type.keyword",         { link = "@keyword" })
  hi("@lsp.type.modifier",        { link = "@keyword" })
  hi("@lsp.type.string",          { link = "@string" })
  hi("@lsp.type.number",          { link = "@number" })
  hi("@lsp.type.operator",        { link = "@operator" })
  hi("@lsp.type.builtinType",     { link = "@type.builtin" })
  hi("@lsp.type.selfKeyword",     { fg = p.orange })
  hi("@lsp.typemod.variable.readonly",         { fg = p.green })
  hi("@lsp.typemod.function.defaultLibrary",   { link = "@function.builtin" })
  hi("@lsp.typemod.variable.defaultLibrary",   { link = "@variable.builtin" })

  -- ── Arayüz ─────────────────────────────────────────────────────────
  hi("Visual",          { bg = p.selection })
  hi("VisualNOS",       { bg = p.surface })
  hi("Search",          { fg = p.bg,     bg = p.green })
  hi("IncSearch",       { fg = p.bg,     bg = p.cyan })
  hi("CurSearch",       { fg = p.bg,     bg = p.orange })
  hi("Substitute",      { fg = p.bg,     bg = p.magenta })
  hi("LineNr",          { fg = p.muted,  bg = p.bg })
  hi("CursorLineNr",    { fg = p.blue,   bg = p.line, bold = true })
  hi("CursorLine",      { bg = p.line })
  hi("SignColumn",      { fg = p.muted,  bg = p.bg })
  hi("Folded",          { fg = p.muted,  bg = p.panel, italic = true })
  hi("FoldColumn",      { fg = p.muted,  bg = p.bg })
  hi("StatusLine",      { fg = p.fg,     bg = p.panel })
  hi("StatusLineNC",    { fg = p.muted,  bg = p.panel })
  hi("TabLine",         { fg = p.muted,  bg = p.panel })
  hi("TabLineSel",      { fg = p.fg,     bg = p.surface, bold = true })
  hi("TabLineFill",     { bg = p.panel })
  hi("VertSplit",       { fg = p.border, bg = p.bg })
  hi("WinSeparator",    { fg = p.border, bg = p.bg })
  hi("Directory",       { fg = p.cyan })
  hi("MatchParen",      { fg = p.orange, bold = true, underline = true })
  hi("NonText",         { fg = p.border })
  hi("SpecialKey",      { fg = p.border })
  hi("Whitespace",      { fg = p.border })
  hi("EndOfBuffer",     { fg = p.bg })
  hi("QuickFixLine",    { bg = p.surface })
  hi("Cursor",          { fg = p.bg,     bg = p.fg })
  hi("TermCursor",      { fg = p.bg,     bg = p.green })
  hi("MsgArea",         { fg = p.fg,     bg = p.bg })
  hi("MoreMsg",         { fg = p.cyan })
  hi("Question",        { fg = p.cyan })
  hi("ModeMsg",         { fg = p.muted })

  -- ── Tanılamalar ────────────────────────────────────────────────────
  hi("DiagnosticError",             { fg = p.red })
  hi("DiagnosticWarn",              { fg = p.orange })
  hi("DiagnosticInfo",              { fg = p.cyan })
  hi("DiagnosticHint",              { fg = p.blue })
  hi("DiagnosticOk",                { fg = p.green })
  hi("DiagnosticUnderlineError",    { underline = true, sp = p.red })
  hi("DiagnosticUnderlineWarn",     { underline = true, sp = p.orange })
  hi("DiagnosticUnderlineInfo",     { underline = true, sp = p.cyan })
  hi("DiagnosticUnderlineHint",     { underline = true, sp = p.blue })
  hi("DiagnosticVirtualTextError",  { fg = p.red,    italic = true })
  hi("DiagnosticVirtualTextWarn",   { fg = p.orange, italic = true })
  hi("DiagnosticVirtualTextInfo",   { fg = p.cyan,   italic = true })
  hi("DiagnosticVirtualTextHint",   { fg = p.blue,   italic = true })
  hi("DiagnosticSignError",         { fg = p.red,    bg = p.bg })
  hi("DiagnosticSignWarn",          { fg = p.orange, bg = p.bg })
  hi("DiagnosticSignInfo",          { fg = p.cyan,   bg = p.bg })
  hi("DiagnosticSignHint",          { fg = p.blue,   bg = p.bg })

  -- Tanılama işaretleri
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  -- ── Fark (Diff) ────────────────────────────────────────────────────
  hi("DiffAdd",     { fg = p.green,  bg = p.diff_add })
  hi("DiffChange",  { fg = p.cyan,   bg = p.diff_chg })
  hi("DiffDelete",  { fg = p.red,    bg = p.diff_del })
  hi("DiffText",    { fg = p.blue,   bg = p.diff_chg, bold = true })
  hi("Added",       { fg = p.green })
  hi("Changed",     { fg = p.cyan })
  hi("Removed",     { fg = p.red })

  -- ── Telescope ──────────────────────────────────────────────────────
  hi("TelescopeNormal",          { fg = p.fg,     bg = p.panel })
  hi("TelescopePromptNormal",    { fg = p.fg,     bg = p.surface })
  hi("TelescopeBorder",          { fg = p.border, bg = p.panel })
  hi("TelescopePromptBorder",    { fg = p.border, bg = p.surface })
  hi("TelescopeResultsBorder",   { fg = p.border, bg = p.panel })
  hi("TelescopePreviewBorder",   { fg = p.border, bg = p.panel })
  hi("TelescopeTitle",           { fg = p.blue,   bg = p.panel,   bold = true })
  hi("TelescopePromptTitle",     { fg = p.cyan,   bg = p.surface, bold = true })
  hi("TelescopeResultsTitle",    { fg = p.blue,   bg = p.panel,   bold = true })
  hi("TelescopePreviewTitle",    { fg = p.green,  bg = p.panel,   bold = true })
  hi("TelescopeSelection",       { bg = p.surface })
  hi("TelescopeSelectionCaret",  { fg = p.cyan,   bg = p.surface })
  hi("TelescopeMatching",        { fg = p.cyan,   bold = true })
  hi("TelescopePromptPrefix",    { fg = p.blue })
  hi("TelescopeResultsNormal",   { fg = p.fg,     bg = p.panel })
  hi("TelescopePreviewNormal",   { fg = p.fg,     bg = p.panel })

  -- ── Neo-tree ───────────────────────────────────────────────────────
  hi("NeoTreeNormal",            { fg = p.fg,     bg = p.panel })
  hi("NeoTreeNormalNC",          { fg = p.fg,     bg = p.panel })
  hi("NeoTreeEndOfBuffer",       { bg = p.panel })
  hi("NeoTreeRootName",          { fg = p.blue,   bold = true })
  hi("NeoTreeDirIcon",           { fg = p.cyan })
  hi("NeoTreeFileName",          { fg = p.fg })
  hi("NeoTreeFileNameOpened",    { fg = p.cyan })
  hi("NeoTreeIndentMarker",      { fg = p.border })
  hi("NeoTreeExpander",          { fg = p.muted })
  hi("NeoTreeGitAdded",          { fg = p.green })
  hi("NeoTreeGitModified",       { fg = p.cyan })
  hi("NeoTreeGitDeleted",        { fg = p.red })
  hi("NeoTreeGitUntracked",      { fg = p.muted })
  hi("NeoTreeGitConflict",       { fg = p.red, bold = true })
  hi("NeoTreeTitleBar",          { fg = p.fg,     bg = p.surface, bold = true })
  hi("NeoTreeDotfile",           { fg = p.muted })
  hi("NeoTreeCursorLine",        { bg = p.surface })
  hi("NeoTreeStatusLine",        { fg = p.muted,  bg = p.panel })

  -- ── Gitsigns ───────────────────────────────────────────────────────
  hi("GitSignsAdd",              { fg = p.green,  bg = p.bg })
  hi("GitSignsChange",           { fg = p.cyan,   bg = p.bg })
  hi("GitSignsDelete",           { fg = p.red,    bg = p.bg })
  hi("GitSignsAddNr",            { fg = p.green })
  hi("GitSignsChangeNr",         { fg = p.cyan })
  hi("GitSignsDeleteNr",         { fg = p.red })
  hi("GitSignsAddLn",            { bg = p.diff_add })
  hi("GitSignsChangeLn",         { bg = p.diff_chg })
  hi("GitSignsCurrentLineBlame", { fg = p.comment, italic = true })

  -- ── CMP (tamamlama) ────────────────────────────────────────────────
  hi("CmpItemAbbr",              { fg = p.fg })
  hi("CmpItemAbbrDeprecated",    { fg = p.muted, strikethrough = true })
  hi("CmpItemAbbrMatch",         { fg = p.cyan,  bold = true })
  hi("CmpItemAbbrMatchFuzzy",    { fg = p.cyan })
  hi("CmpItemMenu",              { fg = p.muted })
  hi("CmpItemKind",              { fg = p.blue })
  hi("CmpItemKindSnippet",       { fg = p.purple })
  hi("CmpItemKindFunction",      { fg = p.cyan })
  hi("CmpItemKindMethod",        { fg = p.cyan })
  hi("CmpItemKindConstructor",   { fg = p.yellow })
  hi("CmpItemKindField",         { fg = p.blue })
  hi("CmpItemKindVariable",      { fg = p.fg })
  hi("CmpItemKindClass",         { fg = p.yellow })
  hi("CmpItemKindInterface",     { fg = p.yellow })
  hi("CmpItemKindModule",        { fg = p.blue })
  hi("CmpItemKindProperty",      { fg = p.blue })
  hi("CmpItemKindKeyword",       { fg = p.magenta })
  hi("CmpItemKindEnum",          { fg = p.yellow })
  hi("CmpItemKindConstant",      { fg = p.green })
  hi("CmpItemKindReference",     { fg = p.orange })
  hi("CmpItemKindOperator",      { fg = p.cyan })

  -- ── Which-key ─────────────────────────────────────────────────────
  hi("WhichKey",          { fg = p.cyan })
  hi("WhichKeyGroup",     { fg = p.blue })
  hi("WhichKeyDesc",      { fg = p.fg })
  hi("WhichKeySeparator", { fg = p.muted })
  hi("WhichKeyFloat",     { bg = p.panel })
  hi("WhichKeyBorder",    { fg = p.border, bg = p.panel })
  hi("WhichKeyValue",     { fg = p.muted })

  -- ── Flash ─────────────────────────────────────────────────────────
  hi("FlashBackdrop",  { fg = p.muted })
  hi("FlashCurrent",   { fg = p.bg, bg = p.orange,  bold = true })
  hi("FlashLabel",     { fg = p.bg, bg = p.magenta, bold = true })
  hi("FlashMatch",     { fg = p.bg, bg = p.cyan })
  hi("FlashPrompt",    { fg = p.cyan })
  hi("FlashPromptIcon",{ fg = p.blue })
  hi("FlashCursor",    { reverse = true })

  -- ── Trouble ───────────────────────────────────────────────────────
  hi("TroubleNormal",      { fg = p.fg,    bg = p.panel })
  hi("TroubleNormalNC",    { fg = p.fg,    bg = p.panel })
  hi("TroubleCount",       { fg = p.magenta, bg = p.surface })
  hi("TroubleText",        { fg = p.fg })
  hi("TroublePreview",     { bg = p.surface })

  -- ── Indent blankline ──────────────────────────────────────────────
  hi("IblIndent", { fg = p.border })
  hi("IblScope",  { fg = "#383838" })

  -- ── Bufferline ────────────────────────────────────────────────────
  hi("BufferLineFill",               { bg = p.panel })
  hi("BufferLineBackground",         { fg = p.muted,  bg = p.panel })
  hi("BufferLineSelected",           { fg = p.fg,     bg = p.bg,    bold = true })
  hi("BufferLineIndicatorSelected",  { fg = p.blue,   bg = p.bg })
  hi("BufferLineCloseButton",        { fg = p.muted,  bg = p.panel })
  hi("BufferLineCloseButtonSelected",{ fg = p.red,    bg = p.bg })
  hi("BufferLineModified",           { fg = p.orange, bg = p.panel })
  hi("BufferLineModifiedSelected",   { fg = p.orange, bg = p.bg })
  hi("BufferLineSeparator",          { fg = p.border, bg = p.panel })
  hi("BufferLineSeparatorSelected",  { fg = p.border, bg = p.bg })

  -- ── Fidget ────────────────────────────────────────────────────────
  hi("FidgetTitle", { fg = p.blue })
  hi("FidgetTask",  { fg = p.muted })

  -- ── Todo-comments ─────────────────────────────────────────────────
  hi("TodoBgTodo", { fg = p.bg, bg = p.orange,  bold = true })
  hi("TodoFgTodo", { fg = p.orange })
  hi("TodoBgFix",  { fg = p.bg, bg = p.red,     bold = true })
  hi("TodoFgFix",  { fg = p.red })
  hi("TodoBgNote", { fg = p.bg, bg = p.blue,    bold = true })
  hi("TodoFgNote", { fg = p.blue })
  hi("TodoBgWarn", { fg = p.bg, bg = p.yellow,  bold = true })
  hi("TodoFgWarn", { fg = p.yellow })
  hi("TodoBgHack", { fg = p.bg, bg = p.red,     bold = true })
  hi("TodoFgHack", { fg = p.red })
  hi("TodoBgPerf", { fg = p.bg, bg = p.purple,  bold = true })
  hi("TodoFgPerf", { fg = p.purple })
  hi("TodoBgTest", { fg = p.bg, bg = p.green,   bold = true })
  hi("TodoFgTest", { fg = p.green })

  -- ── Mason ─────────────────────────────────────────────────────────
  hi("MasonNormal",           { fg = p.fg,     bg = p.panel })
  hi("MasonHighlight",        { fg = p.cyan })
  hi("MasonHighlightBlock",   { fg = p.bg,     bg = p.cyan })
  hi("MasonMuted",            { fg = p.muted })
  hi("MasonError",            { fg = p.red })
  hi("MasonHeading",          { fg = p.blue,   bold = true })

  -- Lualine: statusline'ı lualine'a bırak
  vim.opt.statusline = ""
end

-- Lualine renk teması
function M.lualine_theme()
  return {
    normal = {
      a = { bg = p.blue,    fg = "#0a0a0a", gui = "bold" },
      b = { bg = p.surface, fg = p.fg },
      c = { bg = p.panel,   fg = p.muted },
    },
    insert = {
      a = { bg = p.green,   fg = "#0a0a0a", gui = "bold" },
      b = { bg = p.surface, fg = p.fg },
      c = { bg = p.panel,   fg = p.muted },
    },
    visual = {
      a = { bg = p.magenta, fg = "#0a0a0a", gui = "bold" },
      b = { bg = p.surface, fg = p.fg },
      c = { bg = p.panel,   fg = p.muted },
    },
    replace = {
      a = { bg = p.red,     fg = "#0a0a0a", gui = "bold" },
      b = { bg = p.surface, fg = p.fg },
      c = { bg = p.panel,   fg = p.muted },
    },
    command = {
      a = { bg = p.orange,  fg = "#0a0a0a", gui = "bold" },
      b = { bg = p.surface, fg = p.fg },
      c = { bg = p.panel,   fg = p.muted },
    },
    inactive = {
      a = { bg = p.panel,   fg = p.muted },
      b = { bg = p.panel,   fg = p.muted },
      c = { bg = p.panel,   fg = p.muted },
    },
  }
end

return M
