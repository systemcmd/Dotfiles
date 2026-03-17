function Register-SystemCmdAlias {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Target,

        [switch]$WindowsOnly,
        [switch]$LinuxOnly
    )

    if ($WindowsOnly -and -not $script:SystemCmdIsWindows) {
        return
    }

    if ($LinuxOnly -and -not $script:SystemCmdIsLinux) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return
    }

    if (-not (Test-Path -LiteralPath $Target) -and -not (Get-Command -Name $Target -ErrorAction SilentlyContinue)) {
        return
    }

    Set-Alias -Name $Name -Value $Target -Option AllScope -Scope Global -Force
}

function Import-SystemCmdModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        return $false
    }

    $previousErrorPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Stop'
        Import-Module -Name $Name -ErrorAction Stop 2>$null
        return $true
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $previousErrorPreference
    }
}

function Import-SystemCmdScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $candidate = Join-Path $script:SystemCmdRoot $RelativePath
    if (Test-Path -LiteralPath $candidate) {
        . $candidate
    }
}

function Test-SystemCmdCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

$script:SystemCmdRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($PSCommandPath) {
    Split-Path -Parent $PSCommandPath
} else {
    Join-Path $HOME 'Documents\PowerShell\systemcmd'
}

$script:SystemCmdIsWindows = $env:OS -eq 'Windows_NT'
$script:SystemCmdIsLinux = -not $script:SystemCmdIsWindows
$script:SystemCmdHistoryEntriesCache = $null
$script:SystemCmdHistoryFavoritesCache = $null

$moduleRoots = @(
    (Join-Path $script:SystemCmdRoot 'Modules'),
    (Join-Path (Split-Path $script:SystemCmdRoot -Parent) 'Modules')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -Unique

foreach ($moduleRoot in $moduleRoots) {
    $pathEntries = $env:PSModulePath -split [IO.Path]::PathSeparator
    if ($pathEntries -notcontains $moduleRoot) {
        $env:PSModulePath = $moduleRoot + [IO.Path]::PathSeparator + $env:PSModulePath
    }
}

Register-SystemCmdAlias -Name 'c' -Target 'Clear-Host'
Register-SystemCmdAlias -Name 'sil' -Target 'Clear-Host'
Register-SystemCmdAlias -Name 'st' -Target 'Start-Process'
Register-SystemCmdAlias -Name 'wn' -Target 'winget' -WindowsOnly
Register-SystemCmdAlias -Name 'ifconfig' -Target 'ipconfig' -WindowsOnly
Register-SystemCmdAlias -Name 'vim' -Target 'nvim'
Register-SystemCmdAlias -Name 'tig' -Target 'C:\Program Files\Git\usr\bin\tig.exe' -WindowsOnly
Register-SystemCmdAlias -Name 'less' -Target 'C:\Program Files\Git\usr\bin\less.exe' -WindowsOnly
Register-SystemCmdAlias -Name 'csc' -Target 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe' -WindowsOnly

function ll {
    param(
        [string]$Path = '.'
    )

    Get-ChildItem -Path $Path -Force
}

function rmrf {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Remove-Item -LiteralPath $Path -Recurse -Force
}

function which {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    Get-Command -Name $Command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Show-Ports {
    if ($script:SystemCmdIsWindows -and (Get-Command -Name Get-NetTCPConnection -ErrorAction SilentlyContinue)) {
        Get-NetTCPConnection |
            Sort-Object -Property LocalPort |
            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess
        return
    }

    if (Get-Command -Name ss -ErrorAction SilentlyContinue) {
        ss -tulpn
        return
    }

    if (Get-Command -Name netstat -ErrorAction SilentlyContinue) {
        netstat -tulpn
        return
    }

    Write-Host 'Acilabilecek bir port komutu bulunamadi.' -ForegroundColor Yellow
}

function Get-SystemCmdFileCacheSignature {
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    try {
        $item = Get-Item -LiteralPath $Path -ErrorAction Stop
        return ('{0}|{1}|{2}' -f $item.FullName, $item.Length, $item.LastWriteTimeUtc.Ticks)
    } catch {
        return $null
    }
}

function Get-SystemCmdFzfFilePreviewCommand {
    if (Test-SystemCmdCommand 'bat') {
        return 'bat --style=numbers --color=always --line-range :300 {}'
    }

    if (Test-SystemCmdCommand 'batcat') {
        return 'batcat --style=numbers --color=always --line-range :300 {}'
    }

    if ($script:SystemCmdIsWindows) {
        return 'type {}'
    }

    return 'cat {}'
}

function Get-SystemCmdCtrlFListScriptPath {
    return (Join-Path $script:SystemCmdRoot 'systemcmd-ctrlf-list.ps1')
}

function Get-SystemCmdCtrlFWalkerSkip {
    return '.git,node_modules,dist,build,target,.venv,venv,__pycache__,.next,.nuxt,.cache,bin,obj,vendor,coverage,out,release,debug,.pytest_cache,.mypy_cache,.tox'
}

function Get-SystemCmdCurrentTokenState {
    $line = ''
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line.Length -eq 0) {
        return [PSCustomObject]@{
            Line   = $line
            Cursor = $cursor
            Left   = 0
            Right  = 0
            Token  = $null
        }
    }

    if ($cursor -ge $line.Length) {
        $leftCursor = $cursor - 1
    } else {
        $leftCursor = $cursor
    }

    :leftSearch for (; $leftCursor -ge 0; $leftCursor--) {
        if ([string]::IsNullOrWhiteSpace($line[$leftCursor])) {
            if (($leftCursor -lt $cursor) -and ($leftCursor -lt $line.Length - 1)) {
                $leftCursorQuote = $leftCursor - 1
                $leftCursor = $leftCursor + 1
            } else {
                $leftCursorQuote = $leftCursor
            }

            for (; $leftCursorQuote -ge 0; $leftCursorQuote--) {
                if (($line[$leftCursorQuote] -eq '"') -and (($leftCursorQuote -le 0) -or ($line[$leftCursorQuote - 1] -ne '"'))) {
                    $leftCursor = $leftCursorQuote
                    break leftSearch
                }

                if (($line[$leftCursorQuote] -eq "'") -and (($leftCursorQuote -le 0) -or ($line[$leftCursorQuote - 1] -ne "'"))) {
                    $leftCursor = $leftCursorQuote
                    break leftSearch
                }
            }

            break leftSearch
        }
    }

    :rightSearch for ($rightCursor = $cursor; $rightCursor -lt $line.Length; $rightCursor++) {
        if ([string]::IsNullOrWhiteSpace($line[$rightCursor])) {
            if ($rightCursor -gt $cursor) {
                $rightCursor = $rightCursor - 1
            }

            for ($rightCursorQuote = $rightCursor + 1; $rightCursorQuote -lt $line.Length; $rightCursorQuote++) {
                if (($line[$rightCursorQuote] -eq '"') -and (($rightCursorQuote -gt $line.Length) -or ($line[$rightCursorQuote + 1] -ne '"'))) {
                    $rightCursor = $rightCursorQuote
                    break rightSearch
                }

                if (($line[$rightCursorQuote] -eq "'") -and (($rightCursorQuote -gt $line.Length) -or ($line[$rightCursorQuote + 1] -ne "'"))) {
                    $rightCursor = $rightCursorQuote
                    break rightSearch
                }
            }

            break rightSearch
        }
    }

    if ($leftCursor -lt 0 -or $leftCursor -gt $line.Length - 1) {
        $leftCursor = 0
    }

    if ($rightCursor -ge $line.Length) {
        $rightCursor = $line.Length - 1
    }

    $token = (-join ($line[$leftCursor..$rightCursor])).Trim("'").Trim('"')

    return [PSCustomObject]@{
        Line   = $line
        Cursor = $cursor
        Left   = $leftCursor
        Right  = $rightCursor
        Token  = $token
    }
}

function Resolve-SystemCmdCtrlFRootFromToken {
    param(
        [string]$Token
    )

    if ([string]::IsNullOrWhiteSpace($Token)) {
        return $null
    }

    $normalizedToken = $Token.Trim().Trim('"').Trim("'")
    if ([string]::IsNullOrWhiteSpace($normalizedToken)) {
        return $null
    }

    if ($normalizedToken -like '~*') {
        $homeRelative = $normalizedToken.Substring(1).TrimStart('/','\')
        $homeCandidate = if ([string]::IsNullOrWhiteSpace($homeRelative)) {
            $HOME
        } else {
            Join-Path $HOME $homeRelative
        }

        if (Test-Path -LiteralPath $homeCandidate -PathType Container) {
            return (Resolve-Path -LiteralPath $homeCandidate).ProviderPath
        }
    }

    if (Test-Path -LiteralPath $normalizedToken -PathType Container) {
        return (Resolve-Path -LiteralPath $normalizedToken).ProviderPath
    }

    if (-not $script:SystemCmdIsWindows) {
        return $null
    }

    if ($normalizedToken -notmatch '^[\\/]') {
        return $null
    }

    $relativeToken = $normalizedToken.TrimStart('/','\')
    $currentDriveRoot = $null
    $systemRootParent = $null
    $systemDriveRoot = $null

    try {
        if ($PWD -and $PWD.Drive) {
            $currentDriveRoot = $PWD.Drive.Root
        }
    } catch {
        $currentDriveRoot = $null
    }

    if ($env:SystemRoot) {
        $systemRootParent = Split-Path -Parent $env:SystemRoot
    }

    if ($env:SystemDrive) {
        $systemDriveRoot = $env:SystemDrive + '\'
    }

    $candidateRoots = @(
        $env:SystemRoot,
        $systemRootParent,
        $currentDriveRoot,
        $systemDriveRoot
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

    foreach ($root in $candidateRoots) {
        if ([string]::IsNullOrWhiteSpace($relativeToken)) {
            if (Test-Path -LiteralPath $root -PathType Container) {
                return (Resolve-Path -LiteralPath $root).ProviderPath
            }

            continue
        }

        $candidatePath = Join-Path $root $relativeToken
        if (Test-Path -LiteralPath $candidatePath -PathType Container) {
            return (Resolve-Path -LiteralPath $candidatePath).ProviderPath
        }
    }

    return $null
}

function Format-SystemCmdCtrlFInsertion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Path.Contains(' ') -or $Path.Contains("`t")) {
        return '"' + ($Path -replace '"', '\"') + '"'
    }

    return $Path
}

function Invoke-SystemCmdCtrlFPicker {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [string]$InitialQuery,

        [switch]$DirectoryMode
    )

    $scriptPath = Get-SystemCmdCtrlFListScriptPath
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        return $null
    }

    $previewCommand = Get-SystemCmdFzfFilePreviewCommand
    $fzfArgs = @(
        '--layout', 'reverse',
        '--border',
        '--cycle',
        '--prompt', 'files > ',
        '--preview', $previewCommand,
        '--preview-window', 'right:60%:wrap'
    )

    if (-not [string]::IsNullOrWhiteSpace($InitialQuery)) {
        $fzfArgs += @('--query', $InitialQuery)
    }

    if ($DirectoryMode) {
        $items = @(& $scriptPath -RootPath $RootPath -Shallow)
        if ($items.Count -eq 0) {
            return $null
        }

        $selectedItems = @($items | & fzf @fzfArgs)
        if ($LASTEXITCODE -ne 0 -or $selectedItems.Count -eq 0) {
            return $null
        }

        return [string]$selectedItems[0]
    }

    $fzfArgs += @(
        '--scheme', 'path',
        '--walker', 'file,dir,hidden',
        '--walker-root', $RootPath,
        '--walker-skip', (Get-SystemCmdCtrlFWalkerSkip)
    )

    Push-Location $RootPath
    try {
        $selectedItems = @(& fzf @fzfArgs)
    } finally {
        Pop-Location
    }

    if ($LASTEXITCODE -ne 0 -or $selectedItems.Count -eq 0) {
        return $null
    }

    $selectedPath = [string]$selectedItems[0]
    if (-not [IO.Path]::IsPathRooted($selectedPath)) {
        $selectedPath = Join-Path $RootPath $selectedPath
    }

    try {
        return (Resolve-Path -LiteralPath $selectedPath -ErrorAction Stop).ProviderPath
    } catch {
        return $selectedPath
    }
}

function Invoke-SystemCmdCtrlF {
    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf kurulu degil.' -ForegroundColor Yellow
        return
    }

    if (-not ('Microsoft.PowerShell.PSConsoleReadLine' -as [type])) {
        return
    }

    $tokenState = Get-SystemCmdCurrentTokenState
    $resolvedRoot = Resolve-SystemCmdCtrlFRootFromToken -Token $tokenState.Token
    $rootPath = if ([string]::IsNullOrWhiteSpace($resolvedRoot)) {
        $PWD.ProviderPath
    } else {
        $resolvedRoot
    }
    $directoryMode = -not [string]::IsNullOrWhiteSpace($resolvedRoot)

    $initialQuery = if ([string]::IsNullOrWhiteSpace($resolvedRoot)) {
        $tokenState.Token
    } else {
        ''
    }

    $selectedPath = Invoke-SystemCmdCtrlFPicker -RootPath $rootPath -InitialQuery $initialQuery -DirectoryMode:$directoryMode
    if ([string]::IsNullOrWhiteSpace($selectedPath)) {
        return
    }

    $insertValue = Format-SystemCmdCtrlFInsertion -Path $selectedPath
    if ([string]::IsNullOrWhiteSpace($tokenState.Token)) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($insertValue)
        return
    }

    $replaceLength = $tokenState.Right - $tokenState.Left + 1
    if ($replaceLength -lt 0) {
        $replaceLength = 0
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($tokenState.Left, $replaceLength, $insertValue)
}

function Set-SystemCmdFzfEnvironment {
    $previewCommand = Get-SystemCmdFzfFilePreviewCommand

    $env:_PSFZF_FZF_DEFAULT_OPTS = '--layout=reverse --border --ansi --cycle --info=inline-right'
    $env:FZF_CTRL_T_OPTS = ('--prompt "files > " --header "Tab: coklu secim | Ctrl+/: onizleme" --bind "ctrl-/:toggle-preview" --preview "{0}" --preview-window "right:60%:wrap"' -f $previewCommand)
    $env:FZF_CTRL_R_OPTS = '--prompt "history > " --header "Ctrl+R: siralama degistir | Enter: komutu satira getir"'
}

function Get-SystemCmdHistoryFavoritesPath {
    if (-not [string]::IsNullOrWhiteSpace($env:SYSTEMCMD_HISTORY_FAVORITES_PATH)) {
        return $env:SYSTEMCMD_HISTORY_FAVORITES_PATH
    }

    return (Join-Path $HOME '.systemcmd-history-favorites.json')
}

function Get-SystemCmdHistoryFavorites {
    $favoritesPath = Get-SystemCmdHistoryFavoritesPath
    $signature = Get-SystemCmdFileCacheSignature -Path $favoritesPath

    if ($script:SystemCmdHistoryFavoritesCache -and $script:SystemCmdHistoryFavoritesCache.Signature -eq $signature) {
        return @($script:SystemCmdHistoryFavoritesCache.Items)
    }

    if (-not $signature) {
        $script:SystemCmdHistoryFavoritesCache = @{
            Signature = $null
            Items     = @()
        }
        return @()
    }

    $favorites = @()
    try {
        $rawContent = Get-Content -LiteralPath $favoritesPath -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($rawContent)) {
            $favorites = @()
        } else {
            $parsedFavorites = $rawContent | ConvertFrom-Json -ErrorAction Stop
            if ($parsedFavorites -is [string]) {
                $favorites = @($parsedFavorites)
            } else {
                $favorites = @(
                    $parsedFavorites |
                        Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) }
                )
            }
        }
    } catch {
        $favorites = @()
    }

    $script:SystemCmdHistoryFavoritesCache = @{
        Signature = $signature
        Items     = @($favorites)
    }

    return @($favorites)
}

function Save-SystemCmdHistoryFavorites {
    param(
        [string[]]$Commands
    )

    $favoritesPath = Get-SystemCmdHistoryFavoritesPath
    $directoryPath = Split-Path -Parent $favoritesPath
    if (-not [string]::IsNullOrWhiteSpace($directoryPath) -and -not (Test-Path -LiteralPath $directoryPath)) {
        New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
    }

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $uniqueCommands = [System.Collections.Generic.List[string]]::new()

    foreach ($command in @($Commands)) {
        if ([string]::IsNullOrWhiteSpace($command)) {
            continue
        }

        if ($seen.Add($command)) {
            [void]$uniqueCommands.Add($command)
        }
    }

    $jsonContent = $uniqueCommands.ToArray() | ConvertTo-Json -Depth 3
    Set-Content -LiteralPath $favoritesPath -Value $jsonContent -Encoding UTF8

    $script:SystemCmdHistoryFavoritesCache = @{
        Signature = Get-SystemCmdFileCacheSignature -Path $favoritesPath
        Items     = $uniqueCommands.ToArray()
    }
}

function Set-SystemCmdHistoryFavorite {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [bool]$IsFavorite
    )

    $favorites = [System.Collections.Generic.List[string]]::new()
    foreach ($item in @(Get-SystemCmdHistoryFavorites)) {
        [void]$favorites.Add($item)
    }

    $existingIndex = -1
    for ($index = 0; $index -lt $favorites.Count; $index++) {
        if ($favorites[$index] -ceq $Command) {
            $existingIndex = $index
            break
        }
    }

    if ($IsFavorite) {
        if ($existingIndex -ge 0) {
            $favorites.RemoveAt($existingIndex)
        }

        $favorites.Insert(0, $Command)
    } elseif ($existingIndex -ge 0) {
        $favorites.RemoveAt($existingIndex)
    }

    Save-SystemCmdHistoryFavorites -Commands $favorites.ToArray()
}

function Get-SystemCmdHistoryEntries {
    $entries = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $historyPath = $null

    try {
        if (Get-Command -Name Get-PSReadLineOption -ErrorAction SilentlyContinue) {
            $historyPath = (Get-PSReadLineOption).HistorySavePath
        }
    } catch {
        $historyPath = $null
    }

    $historySignature = Get-SystemCmdFileCacheSignature -Path $historyPath
    if ($historySignature -and $script:SystemCmdHistoryEntriesCache -and $script:SystemCmdHistoryEntriesCache.Signature -eq $historySignature) {
        return @($script:SystemCmdHistoryEntriesCache.Entries)
    }

    if (-not [string]::IsNullOrWhiteSpace($historyPath) -and (Test-Path -LiteralPath $historyPath)) {
        try {
            $reader = New-Object PSFzf.IO.ReverseLineReader -ArgumentList $historyPath
            try {
                foreach ($entry in $reader.GetEnumerator()) {
                    if ([string]::IsNullOrWhiteSpace($entry)) {
                        continue
                    }

                    if ($seen.Add($entry)) {
                        [void]$entries.Add($entry)
                    }
                }
            } finally {
                if ($reader) {
                    $reader.Dispose()
                }
            }
        } catch {
            $historyLines = @(Get-Content -LiteralPath $historyPath -ErrorAction SilentlyContinue)
            [array]::Reverse($historyLines)

            foreach ($entry in $historyLines) {
                if ([string]::IsNullOrWhiteSpace($entry)) {
                    continue
                }

                if ($seen.Add($entry)) {
                    [void]$entries.Add($entry)
                }
            }
        }
    }

    if ($entries.Count -eq 0) {
        foreach ($entry in (Get-History | Sort-Object Id -Descending | ForEach-Object { $_.CommandLine })) {
            if ([string]::IsNullOrWhiteSpace($entry)) {
                continue
            }

            if ($seen.Add($entry)) {
                [void]$entries.Add($entry)
            }
        }
    }

    $result = $entries.ToArray()
    if ($historySignature) {
        $script:SystemCmdHistoryEntriesCache = @{
            Signature = $historySignature
            Entries   = $result
        }
    } else {
        $script:SystemCmdHistoryEntriesCache = $null
    }

    return $result
}

function ConvertTo-SystemCmdHistoryDisplayText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $singleLine = $Command -replace "\r?\n", ' <nl> ' -replace "`t", ' '
    $singleLine = $singleLine.Trim()

    if ($singleLine.Length -gt 220) {
        return ($singleLine.Substring(0, 220) + '...')
    }

    return $singleLine
}

function Get-SystemCmdHistoryPreviewCachePath {
    return (Join-Path $script:SystemCmdRoot '.systemcmd-history-preview.txt')
}

function Update-SystemCmdHistoryPreviewCache {
    param(
        [string[]]$Favorites
    )

    $previewPath = Get-SystemCmdHistoryPreviewCachePath
    $previewLines = [System.Collections.Generic.List[string]]::new()
    [void]$previewLines.Add('Favoriler')
    [void]$previewLines.Add('')

    if (@($Favorites).Count -eq 0) {
        [void]$previewLines.Add('Henuz favori yok.')
    } else {
        for ($index = 0; $index -lt $Favorites.Count; $index++) {
            $singleLine = ($Favorites[$index] -replace "\r?\n", ' <nl> ' -replace "`t", ' ').Trim()
            if ($singleLine.Length -gt 140) {
                $singleLine = $singleLine.Substring(0, 140) + '...'
            }

            [void]$previewLines.Add(('[{0:D2}] {1}' -f ($index + 1), $singleLine))
        }
    }

    Set-Content -LiteralPath $previewPath -Value $previewLines -Encoding UTF8
}

function Get-SystemCmdHistoryPreviewCommand {
    $previewPath = Get-SystemCmdHistoryPreviewCachePath
    if (-not (Test-Path -LiteralPath $previewPath)) {
        Update-SystemCmdHistoryPreviewCache -Favorites @()
    }

    if (Test-SystemCmdCommand 'bat') {
        return ('bat --style=plain --color=always --paging=never "{0}"' -f $previewPath)
    }

    if (Test-SystemCmdCommand 'batcat') {
        return ('batcat --style=plain --color=always --paging=never "{0}"' -f $previewPath)
    }

    if ($script:SystemCmdIsWindows) {
        return ('cmd /d /c type "{0}"' -f $previewPath)
    }

    return ('cat "{0}"' -f $previewPath)
}

function ConvertTo-SystemCmdHistoryPickerItem {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Id,

        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [bool]$IsFavorite
    )

    $marker = if ($IsFavorite) { '*' } else { ' ' }
    $displayText = ConvertTo-SystemCmdHistoryDisplayText -Command $Command
    $idText = "`e[38;5;245m[{0:D4}]`e[0m" -f $Id
    $visibleText = ('{0} {1} {2}' -f $marker, $idText, $displayText)
    $payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Command))
    $favoriteFlag = if ($IsFavorite) { '1' } else { '0' }

    if ($IsFavorite) {
        $visibleText = ("`e[38;5;214m{0}`e[0m {1} `e[38;5;214m{2}`e[0m" -f $marker, $idText, $displayText)
    }

    return ('{0}' + "`t" + '{1}' + "`t" + '{2}' + "`t" + '{3}') -f $visibleText, $Id, $favoriteFlag, $payload
}

function ConvertFrom-SystemCmdHistoryPickerItem {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    $parts = $Line -split "`t", 4
    if ($parts.Count -lt 4) {
        return $null
    }

    try {
        $command = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($parts[3]))
    } catch {
        return $null
    }

    return [PSCustomObject]@{
        Display    = $parts[0]
        Id         = [int]$parts[1]
        IsFavorite = $parts[2] -eq '1'
        Command    = $command
    }
}

function Invoke-SystemCmdPromptHack {
    if (-not ('Microsoft.PowerShell.PSConsoleReadLine' -as [type])) {
        return
    }

    $previousOutputEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [Text.Encoding]::UTF8

    try {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    } finally {
        [Console]::OutputEncoding = $previousOutputEncoding
    }
}

function Invoke-SystemCmdHistoryPicker {
    if (-not (Test-SystemCmdCommand 'fzf')) {
        Write-Host 'fzf kurulu degil.' -ForegroundColor Yellow
        return
    }

    if (-not ('Microsoft.PowerShell.PSConsoleReadLine' -as [type])) {
        Write-Host 'PSReadLine aktif degil.' -ForegroundColor Yellow
        return
    }

    $originalLine = ''
    $cursor = 0
    $canReplaceBuffer = $true

    try {
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$originalLine, [ref]$cursor)
    } catch {
        $canReplaceBuffer = $false
    }

    $query = if ($canReplaceBuffer) { $originalLine } else { '' }
    $historyEntries = @(Get-SystemCmdHistoryEntries)
    $favorites = [System.Collections.Generic.List[string]]::new()

    foreach ($favorite in @(Get-SystemCmdHistoryFavorites)) {
        if (-not [string]::IsNullOrWhiteSpace($favorite) -and -not $favorites.Contains($favorite)) {
            [void]$favorites.Add($favorite)
        }
    }

    if ($historyEntries.Count -eq 0) {
        if ($canReplaceBuffer) {
            Invoke-SystemCmdPromptHack
        }

        Write-Host 'Gecmis kaydi bulunamadi.' -ForegroundColor Yellow
        return
    }

    $previewDirty = $true

    while ($true) {
        $favoriteSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($favorite in $favorites) {
            if ($favoriteSet.Add($favorite)) {
                continue
            }
        }

        if ($previewDirty) {
            Update-SystemCmdHistoryPreviewCache -Favorites $favorites.ToArray()
            $previewDirty = $false
        }

        $orderedEntries = [System.Collections.Generic.List[string]]::new()

        foreach ($favorite in $favorites) {
            if ($historyEntries -contains $favorite) {
                [void]$orderedEntries.Add($favorite)
            }
        }

        foreach ($entry in $historyEntries) {
            if (-not $favoriteSet.Contains($entry)) {
                [void]$orderedEntries.Add($entry)
            }
        }

        if ($orderedEntries.Count -eq 0) {
            if ($canReplaceBuffer) {
                Invoke-SystemCmdPromptHack
            }

            Write-Host 'Gecmis kaydi bulunamadi.' -ForegroundColor Yellow
            return
        }

        $entryMap = @{}
        $items = for ($index = 0; $index -lt $orderedEntries.Count; $index++) {
            $id = $index + 1
            $entryMap[$id] = $orderedEntries[$index]
            ConvertTo-SystemCmdHistoryPickerItem -Id $id -Command $orderedEntries[$index] -IsFavorite:$favoriteSet.Contains($orderedEntries[$index])
        }

        $fzfArgs = @(
            '--ansi',
            '--layout', 'reverse',
            '--border',
            '--cycle',
            '--color', 'fg:#d6d3d1,fg+:#fdba74,bg:-1,bg+:-1,gutter:-1,prompt:#a8a29e,pointer:#f97316,marker:#f59e0b,spinner:#a8a29e,hl:#f59e0b,hl+:#fb923c,info:#78716c,border:#6b4f2c,preview-border:#6b4f2c',
            '--delimiter', "`t",
            '--with-nth', '1',
            '--nth', '1',
            '--print-query',
            '--expect', 'f',
            '--prompt', 'history > ',
            '--bind', 'ctrl-r:toggle-sort',
            '--preview', (Get-SystemCmdHistoryPreviewCommand),
            '--preview-window', 'right,50%,wrap,border-left'
        )

        if (-not [string]::IsNullOrWhiteSpace($query)) {
            $fzfArgs += @('--query', $query)
        }

        $outputLines = @($items | & fzf @fzfArgs)
        if ($LASTEXITCODE -ne 0 -or $outputLines.Count -lt 3) {
            if ($canReplaceBuffer) {
                Invoke-SystemCmdPromptHack
            }
            return
        }

        $query = $outputLines[0]
        $pressedKey = $outputLines[1]
        $selectedItem = ConvertFrom-SystemCmdHistoryPickerItem -Line $outputLines[2]
        if (-not $selectedItem -or -not $entryMap.ContainsKey($selectedItem.Id)) {
            if ($canReplaceBuffer) {
                Invoke-SystemCmdPromptHack
            }
            return
        }

        $selectedCommand = [string]$selectedItem.Command

        switch ($pressedKey) {
            'f' {
                $existingIndex = -1
                for ($index = 0; $index -lt $favorites.Count; $index++) {
                    if ($favorites[$index] -ceq $selectedCommand) {
                        $existingIndex = $index
                        break
                    }
                }

                if ($selectedItem.IsFavorite) {
                    if ($existingIndex -ge 0) {
                        $favorites.RemoveAt($existingIndex)
                    }
                } else {
                    if ($existingIndex -ge 0) {
                        $favorites.RemoveAt($existingIndex)
                    }

                    $favorites.Insert(0, $selectedCommand)
                }

                Save-SystemCmdHistoryFavorites -Commands $favorites.ToArray()
                $previewDirty = $true
                continue
            }
            default {
                if ($canReplaceBuffer) {
                    Invoke-SystemCmdPromptHack
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $originalLine.Length, $selectedCommand)
                } else {
                    $selectedCommand
                }
                return
            }
        }
    }
}

$env:FZF_HISTORY_FILE = Join-Path $HOME '.fzf_history'
$env:FZF_DEFAULT_OPTS = '--layout=reverse --border'
Set-SystemCmdFzfEnvironment

if ($script:SystemCmdIsWindows) {
    $env:GIT_SSH = 'C:\Windows\System32\OpenSSH\ssh.exe'
}

$terminalIconsLoaded = Import-SystemCmdModule 'Terminal-Icons'
$psFzfLoaded = Import-SystemCmdModule 'PSFzf'
$psReadLineLoaded = Import-SystemCmdModule 'PSReadLine'

if ($psReadLineLoaded) {
    try { Set-PSReadLineOption -EditMode Emacs } catch {}
    try { Set-PSReadLineOption -BellStyle None } catch {}
    try { Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar } catch {}
    try { Set-PSReadLineOption -PredictionSource History } catch {}
}

if ($psReadLineLoaded -and $psFzfLoaded -and (Get-Command -Name Set-PsFzfOption -ErrorAction SilentlyContinue)) {
    try {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
    } catch {}
}

if ($psReadLineLoaded) {
    try {
        Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -BriefDescription 'systemcmd file picker' -LongDescription 'Yol tokeni ve provider dosya secici' -ScriptBlock {
            Invoke-SystemCmdCtrlF
        }
    } catch {}
    try {
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -BriefDescription 'systemcmd history picker' -LongDescription 'Gecmis aramasi ve favori yonetimi' -ScriptBlock {
            Invoke-SystemCmdHistoryPicker
        }
    } catch {}
}

if ($script:SystemCmdIsWindows) {
    function /system32 {
        Set-Location (Join-Path $env:SystemRoot 'System32')
    }

    $windowsScriptImports = @(
        'nmphcmfs\Nmap.ps1',
        'nmphcmfs\Hashcat.ps1',
        'nmphcmfs\Msfconsole.ps1',
        'nmphcmfs\PentestMenu.ps1',
        'nmphcmfs\dork.ps1',
        'nmphcmfs\ncat.ps1',
        'nmphcmfs\systemctl.ps1',
        'nmphcmfs\dockerhelp.ps1',
        'nmphcmfs\blueteam.ps1',
        'nmphcmfs\redteam.ps1',
        'nmphcmfs\crypto_resources.ps1',
        'nmphcmfs\SistemArac.ps1',
        'nmphcmfs\adminhck.ps1',
        'pc\ip-bt.ps1',
        'pc\ascii.ps1',
        'pc\ram-gpu-cpu.ps1',
        'pc\bios.ps1',
        'pc\money.ps1'
    )

    foreach ($relativePath in $windowsScriptImports) {
        $candidate = Join-Path $script:SystemCmdRoot $relativePath
        if (-not (Test-Path -LiteralPath $candidate)) {
            continue
        }

        try {
            . $candidate
        } catch {
            Write-Host ("systemcmd script yuklenemedi: {0}" -f $relativePath) -ForegroundColor Yellow
        }
    }
}

function Type-Text {
    param(
        [string]$Text,
        [int]$Delay = 15
    )

    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline "`e[1;92m$char`e[0m"
        Start-Sleep -Milliseconds $Delay
    }

    Write-Host ''
}

function Show-HelpMenu {
    Write-Host "`e[1;94m╔═════════════════════════════════════════════════════════════╗`e[0m"
    Write-Host "`e[1;94m║`e[0m         `e[1;95m✨ MEVCUT KOMUTLAR VE FONKSIYONLAR ✨`e[0m           `e[1;94m║`e[0m"
    Write-Host "`e[1;94m╠═════════════════════════════════════════════════════════════╣`e[0m"
    Write-Host ''

    $robots = @(
@"
`e[90m    ________   `e[0m
`e[90m   /        \  `e[0m
`e[90m  | `e[96m[]    [] `e[90m| `e[0m
`e[90m  | `e[93m  \____/  `e[90m| `e[0m
`e[90m   \________/  `e[0m
"@,
@"
`e[90m   .--------.  `e[0m
`e[90m  /   `e[96m0  0  `e[90m\ `e[0m
`e[90m |     __    | `e[0m
`e[90m |    /__\   | `e[0m
`e[90m  \__________/ `e[0m
"@,
@"
`e[90m    ________    `e[0m
`e[90m   /        \   `e[0m
`e[90m  |  `e[96m^    ^  `e[90m|  `e[0m
`e[90m  | `e[93m  \____/   `e[90m|  `e[0m
`e[90m   \___~~___/   `e[0m
"@,
@"
`e[90m    ________    `e[0m
`e[90m   /        \   `e[0m
`e[90m  |  `e[96m><   >< `e[90m|  `e[0m
`e[90m  | `e[93m  \____/   `e[90m|  `e[0m
`e[90m   \________/   `e[0m
"@
    )

    Write-Host "`e[92m[ OZEL TUS ATAMALARI ]`e[0m"
    Write-Host "  `e[96m• Ctrl+d`e[0m   : Imlecin altindaki karakteri siler."
    Write-Host "  `e[96m• Ctrl+f`e[0m   : Dosya aramasi, `/System32` gibi yol tokenini acabilir."
    Write-Host "  `e[96m• Ctrl+r`e[0m   : Gecmis aramasi, sari favoriler ve sag favori paneli."
    Write-Host ''

    Write-Host "`e[92m[ ALIASLAR ]`e[0m"
    Write-Host "  `e[93m• vim       `e[0m: nvim varsa onu acmak icin kisayol."
    Write-Host "  `e[93m• wn        `e[0m: winget kisayolu (Windows)."
    Write-Host "  `e[93m• sil / c   `e[0m: Ekrani temizler."
    Write-Host "  `e[93m• ifconfig  `e[0m: ipconfig kisayolu (Windows)."
    Write-Host "  `e[93m• st        `e[0m: Start-Process kisayolu."
    Write-Host ''

    Write-Host "`e[92m[ TEMEL FONKSIYONLAR ]`e[0m"
    Write-Host "  `e[96m• ll [path]      `e[0m: Gizli dosyalar dahil klasor listeler."
    Write-Host "  `e[96m• rmrf <path>    `e[0m: Klasor veya dosyayi zorla siler."
    Write-Host "  `e[96m• which <komut>  `e[0m: Komutun gercek yolunu gosterir."
    Write-Host "  `e[96m• Show-Ports     `e[0m: Acik portlari listeler."
    Write-Host ''

    if ($script:SystemCmdIsWindows) {
        Write-Host "`e[92m[ WINDOWS MENULERI ]`e[0m"
        $windowsMenuEntries = @(
            @{ Name = 'dockerhelp'; Description = 'Docker notlari.' },
            @{ Name = 'crypto'; Description = 'Kripto kaynak menusu.' },
            @{ Name = 'pentestmenu'; Description = 'Pentest baglantilari.' },
            @{ Name = 'blueteam'; Description = 'BlueTeam menusu.' },
            @{ Name = 'redteam'; Description = 'RedTeam menusu.' },
            @{ Name = 'nmp'; Description = 'Nmap komut menusu.' },
            @{ Name = 'ctl'; Description = 'systemctl ve journalctl yardimi.' },
            @{ Name = 'ncatmenu'; Description = 'Ncat komut menusu.' },
            @{ Name = 'hc'; Description = 'Hashcat menusu.' },
            @{ Name = 'msf'; Description = 'Metasploit menusu.' },
            @{ Name = 'dork'; Description = 'Google dork menusu.' },
            @{ Name = 'ascii'; Description = 'Metni ASCII koda cevirir.' },
            @{ Name = 'sistemarac'; Description = 'Sag tik sistem araclari.' },
            @{ Name = 'adminhck'; Description = 'Dosya sahipligini alir.' },
            @{ Name = 'ip'; Description = 'IP bilgileri.' },
            @{ Name = 'bios'; Description = 'BIOS bilgileri.' },
            @{ Name = 'para'; Description = 'Finansal hesaplama.' }
        )

        foreach ($entry in $windowsMenuEntries) {
            if (-not (Get-Command -Name $entry.Name -ErrorAction SilentlyContinue)) {
                continue
            }

            Write-Host ("  `e[95m• {0,-11}`e[0m: {1}" -f $entry.Name, $entry.Description)
        }
        Write-Host ''
    }

    Write-Host ($robots | Get-Random)
    Write-Host ''
    Type-Text "`e[┌──(X_O㉿System)-[~/Cmd]"
    Write-Host ''
}

function SystemCmd {
    param(
        [string]$Command = 'help'
    )

    switch ($Command.ToLowerInvariant()) {
        'help' { Show-HelpMenu }
        default { Show-HelpMenu }
    }
}

Set-Alias -Name 'system' -Value 'SystemCmd' -Option AllScope -Scope Global -Force
