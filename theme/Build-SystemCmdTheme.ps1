[CmdletBinding()]
param(
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

function Resolve-SystemCmdThemeProjectRoot {
    param([string]$PreferredPath)

    $candidates = @()

    if ($PreferredPath) {
        $candidates += $PreferredPath
    }

    $candidates += @(
        (Split-Path -Parent $PSScriptRoot),
        (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    )

    foreach ($candidate in $candidates | Where-Object { $_ }) {
        try {
            $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
        } catch {
            continue
        }

        if (Test-Path -LiteralPath (Join-Path $resolved 'vscode\systemcmd-color\themes')) {
            return $resolved
        }
    }

    throw 'systemcmd proje koku bulunamadi.'
}

function Get-SystemCmdWorkspaceRoot {
    param([string]$ResolvedProjectRoot)

    if ((Split-Path -Leaf $ResolvedProjectRoot) -eq 'Dotfiles') {
        return (Split-Path -Parent $ResolvedProjectRoot)
    }

    return $ResolvedProjectRoot
}

function Get-SystemCmdPaletteValue {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Palette,

        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    if ($Key -eq '-1' -or $Key.StartsWith('#')) {
        return $Key
    }

    $property = $Palette.PSObject.Properties[$Key]
    if ($property) {
        return [string]$property.Value
    }

    throw "Palette anahtari bulunamadi: $Key"
}

function Set-SystemCmdUtf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function ConvertTo-SystemCmdIndentedJson {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    return ($InputObject | ConvertTo-Json -Depth 32)
}

$resolvedProjectRoot = Resolve-SystemCmdThemeProjectRoot -PreferredPath $ProjectRoot
$workspaceRoot = Get-SystemCmdWorkspaceRoot -ResolvedProjectRoot $resolvedProjectRoot
$themeSourcePath = Join-Path $PSScriptRoot 'systemcmd-theme-source.json'

if (-not (Test-Path -LiteralPath $themeSourcePath)) {
    throw 'Tema kaynak dosyasi bulunamadi.'
}

$themeSource = Get-Content -LiteralPath $themeSourcePath -Raw | ConvertFrom-Json
$palette = $themeSource.palette

$fzfParts = foreach ($property in $themeSource.fzf.PSObject.Properties) {
    '{0}:{1}' -f $property.Name, (Get-SystemCmdPaletteValue -Palette $palette -Key ([string]$property.Value))
}
$fzfColor = ($fzfParts -join ',')

$vscodeTheme = [ordered]@{
    name                 = [string]$themeSource.name
    type                 = [string]$themeSource.type
    semanticHighlighting = $true
    colors               = [ordered]@{
        'editor.background'             = [string]$palette.bg
        'editor.foreground'             = [string]$palette.fg
        'editorLineNumber.foreground'   = [string]$palette.muted
        'editorLineNumber.activeForeground' = [string]$palette.fg
        'editorCursor.foreground'       = [string]$palette.cyan
        'editor.selectionBackground'    = [string]$palette.selection
        'editor.lineHighlightBackground' = [string]$palette.line
        'editorIndentGuide.background1' = [string]$palette.line
        'editorIndentGuide.activeBackground1' = [string]$palette.surface
        'editorWidget.background'       = [string]$palette.panel
        'editorWidget.border'           = [string]$palette.surface
        'sideBar.background'            = [string]$palette.panel
        'sideBar.foreground'            = [string]$palette.fg
        'activityBar.background'        = [string]$palette.panel
        'activityBar.foreground'        = [string]$palette.fg
        'titleBar.activeBackground'     = [string]$palette.panel
        'titleBar.activeForeground'     = [string]$palette.fg
        'statusBar.background'          = [string]$palette.panel
        'statusBar.foreground'          = [string]$palette.fg
        'panel.background'              = [string]$palette.bg
        'panel.border'                  = [string]$palette.surface
        'terminal.background'           = [string]$palette.bg
        'terminal.foreground'           = [string]$palette.fg
        'terminalCursor.foreground'     = [string]$palette.cyan
        'terminal.ansiBlack'            = [string]$palette.bg
        'terminal.ansiBlue'             = [string]$palette.blue
        'terminal.ansiCyan'             = [string]$palette.cyan
        'terminal.ansiGreen'            = [string]$palette.green
        'terminal.ansiMagenta'          = [string]$palette.magenta
        'terminal.ansiRed'              = [string]$palette.red
        'terminal.ansiWhite'            = [string]$palette.fg
        'terminal.ansiYellow'           = [string]$palette.orange
        'terminal.ansiBrightBlack'      = [string]$palette.muted
        'terminal.ansiBrightBlue'       = [string]$palette.blue
        'terminal.ansiBrightCyan'       = [string]$palette.cyan
        'terminal.ansiBrightGreen'      = [string]$palette.green
        'terminal.ansiBrightMagenta'    = [string]$palette.purple
        'terminal.ansiBrightRed'        = [string]$palette.red
        'terminal.ansiBrightWhite'      = [string]$palette.fg
        'terminal.ansiBrightYellow'     = [string]$palette.orange
    }
    semanticTokenColors  = [ordered]@{
        'enumMember'              = @{ foreground = [string]$palette.fg }
        'variable.constant'       = @{ foreground = [string]$palette.green }
        'variable.defaultLibrary' = @{ foreground = [string]$palette.fg }
    }
    tokenColors          = @(
        @{
            name     = 'Comments'
            scope    = @('comment', 'punctuation.definition.comment')
            settings = @{ foreground = [string]$palette.comment; fontStyle = 'italic' }
        },
        @{
            name     = 'Keywords'
            scope    = @('keyword', 'storage', 'storage.type')
            settings = @{ foreground = [string]$palette.magenta }
        },
        @{
            name     = 'Strings'
            scope    = @('string', 'string.quoted', 'punctuation.definition.string')
            settings = @{ foreground = [string]$palette.purple }
        },
        @{
            name     = 'Numbers and Constants'
            scope    = @('constant.numeric', 'constant.language', 'constant.character')
            settings = @{ foreground = [string]$palette.green }
        },
        @{
            name     = 'Functions'
            scope    = @('entity.name.function', 'support.function', 'meta.function-call', 'variable.function')
            settings = @{ foreground = [string]$palette.cyan }
        },
        @{
            name     = 'Types'
            scope    = @('entity.name.type', 'support.type', 'storage.type')
            settings = @{ foreground = [string]$palette.fg }
        },
        @{
            name     = 'Variables'
            scope    = @('variable', 'variable.other.readwrite', 'meta.definition.variable')
            settings = @{ foreground = [string]$palette.blue }
        },
        @{
            name     = 'Parameters'
            scope    = @('variable.parameter')
            settings = @{ foreground = [string]$palette.fg }
        },
        @{
            name     = 'Punctuation'
            scope    = @('punctuation', 'meta.brace', 'meta.delimiter')
            settings = @{ foreground = [string]$palette.fg }
        },
        @{
            name     = 'Invalid'
            scope    = @('invalid', 'invalid.illegal')
            settings = @{ foreground = [string]$palette.red }
        }
    )
}

$themeJson = ConvertTo-SystemCmdIndentedJson -InputObject $vscodeTheme

$psThemeLines = @(
    '$script:SystemCmdTheme = @{'
    "    Name = '$($themeSource.name)'"
    "    Type = '$($themeSource.type)'"
    "    FzfColor = '$fzfColor'"
    '    Palette = @{'
)

foreach ($property in $palette.PSObject.Properties) {
    $psThemeLines += ("        {0} = '{1}'" -f $property.Name, [string]$property.Value)
}

$psThemeLines += @(
    '    }'
    '}'
    ''
)
$psThemeContent = ($psThemeLines -join [Environment]::NewLine)

$shThemeLines = @(
    '# shellcheck shell=bash',
    ("export SYSTEMCMD_THEME_NAME='{0}'" -f [string]$themeSource.name),
    ("export SYSTEMCMD_FZF_COLOR='{0}'" -f $fzfColor)
)

foreach ($property in $palette.PSObject.Properties) {
    $shThemeLines += ("export SYSTEMCMD_COLOR_{0}='{1}'" -f $property.Name.ToUpperInvariant(), [string]$property.Value)
}

$shThemeLines += ''
$shThemeContent = ($shThemeLines -join "`n")

$luaThemeContent = @"
local M = {}

local palette = {
  bg = "$($palette.bg)",
  panel = "$($palette.panel)",
  surface = "$($palette.surface)",
  line = "$($palette.line)",
  fg = "$($palette.fg)",
  muted = "$($palette.muted)",
  comment = "$($palette.comment)",
  blue = "$($palette.blue)",
  cyan = "$($palette.cyan)",
  magenta = "$($palette.magenta)",
  purple = "$($palette.purple)",
  green = "$($palette.green)",
  red = "$($palette.red)",
  orange = "$($palette.orange)",
  selection = "$($palette.selection)",
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
"@

$windowsPowerShellRoot = if (Test-Path -LiteralPath (Join-Path $resolvedProjectRoot 'windows\PowerShell')) {
    Join-Path $resolvedProjectRoot 'windows\PowerShell'
} else {
    $resolvedProjectRoot
}

$outputs = @(
    @{ Path = Join-Path $workspaceRoot 'systemcmd-color-theme.json'; Content = $themeJson },
    @{ Path = Join-Path $resolvedProjectRoot 'vscode\systemcmd-color\themes\systemcmd-color-theme.json'; Content = $themeJson },
    @{ Path = Join-Path $workspaceRoot 'systemcmd-theme.generated.ps1'; Content = $psThemeContent },
    @{ Path = Join-Path $windowsPowerShellRoot 'systemcmd-theme.generated.ps1'; Content = $psThemeContent },
    @{ Path = Join-Path $resolvedProjectRoot 'linux\systemcmd-theme.generated.sh'; Content = $shThemeContent },
    @{ Path = Join-Path $resolvedProjectRoot 'nvim\lua\systemcmd\theme.lua'; Content = $luaThemeContent }
)

foreach ($output in $outputs) {
    Set-SystemCmdUtf8File -Path $output.Path -Content $output.Content
}

Write-Host "systemcmd theme build tamamlandi: $resolvedProjectRoot" -ForegroundColor Green
