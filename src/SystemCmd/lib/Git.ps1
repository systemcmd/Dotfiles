# SystemCmd.Git — git status/diff parsing and rendering over the git CLI.
# Cross-platform; no libgit2 dependency.

function Test-SystemCmdGitAvailable { [bool](Get-Command git -ErrorAction SilentlyContinue) }

function Get-SystemCmdGitRoot {
    param([string]$Path = $PWD.Path)
    if (-not (Test-SystemCmdGitAvailable)) { return $null }
    $root = & git -C $Path rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $root) { return ([string]$root).Trim() }
    return $null
}

function Test-SystemCmdGitRepo {
    param([string]$Path = $PWD.Path)
    return [bool](Get-SystemCmdGitRoot -Path $Path)
}

function ConvertFrom-SystemCmdNumstat {
    param([string[]]$Lines)
    $map = @{}
    foreach ($line in $Lines) {
        if (-not $line) { continue }
        $parts = $line -split "`t", 3
        if ($parts.Count -lt 3) { continue }
        $ins = if ($parts[0] -eq '-') { 0 } else { [int]($parts[0]) }
        $del = if ($parts[1] -eq '-') { 0 } else { [int]($parts[1]) }
        $path = $parts[2].Trim()
        # Renames: "old => new" (or brace form) — key on the reported new name.
        if ($path -match ' => ') { $path = ($path -split ' => ')[-1].TrimEnd('}') }
        $map[$path] = @{ Ins = $ins; Del = $del }
    }
    return $map
}

function Get-SystemCmdGitStatusLabel {
    param([char]$Code)
    switch ($Code) {
        'M' { 'modified' } 'A' { 'added' } 'D' { 'deleted' } 'R' { 'renamed' }
        'C' { 'added' } 'U' { 'conflicted' } '?' { 'untracked' } default { 'modified' }
    }
}

<#
.SYNOPSIS
Parse real git status into a structured object: branch, ahead/behind, and per-file
staged/unstaged changes with insertion/deletion counts.
#>
function Get-SystemCmdGitStatus {
    param([string]$Path = $PWD.Path)
    $root = Get-SystemCmdGitRoot -Path $Path
    if (-not $root) { return $null }

    $porcelain = @(& git -C $root status --porcelain=v1 -b --untracked-files=all 2>$null)
    $stagedNum = ConvertFrom-SystemCmdNumstat (@(& git -C $root diff --cached --numstat 2>$null))
    $unstagedNum = ConvertFrom-SystemCmdNumstat (@(& git -C $root diff --numstat 2>$null))

    $branch = '(detached)'; $upstream = $null; $ahead = 0; $behind = 0
    $files = New-Object System.Collections.Generic.List[object]

    foreach ($line in $porcelain) {
        if (-not $line) { continue }
        if ($line.StartsWith('## ')) {
            $header = $line.Substring(3)
            $trackIdx = $header.IndexOf(' [')
            $branchPart = if ($trackIdx -ge 0) { $header.Substring(0, $trackIdx) } else { $header }
            $tracking = if ($trackIdx -ge 0) { $header.Substring($trackIdx + 2).TrimEnd(']') } else { '' }
            if ($branchPart -match '\.\.\.') {
                $branch = ($branchPart -split '\.\.\.')[0]
                $upstream = ($branchPart -split '\.\.\.')[1]
            } else { $branch = $branchPart }
            foreach ($tok in ($tracking -split ', ')) {
                if ($tok -match '^ahead (\d+)') { $ahead = [int]$Matches[1] }
                elseif ($tok -match '^behind (\d+)') { $behind = [int]$Matches[1] }
            }
            continue
        }
        if ($line.Length -lt 3) { continue }
        $index = $line[0]; $work = $line[1]; $rest = $line.Substring(3)
        $orig = $null; $pathStr = $rest
        if ($rest -match ' -> ') { $parts = $rest -split ' -> ', 2; $orig = $parts[0]; $pathStr = $parts[1] }

        if ($index -eq '?' -and $work -eq '?') {
            $files.Add([pscustomobject]@{ Path = $pathStr; OrigPath = $null; Status = 'untracked'; Staged = $false; Insertions = 0; Deletions = 0 })
            continue
        }
        if ($index -ne ' ' -and $index -ne '?') {
            $n = if ($stagedNum.ContainsKey($pathStr)) { $stagedNum[$pathStr] } else { @{ Ins = 0; Del = 0 } }
            $files.Add([pscustomobject]@{ Path = $pathStr; OrigPath = $orig; Status = (Get-SystemCmdGitStatusLabel $index); Staged = $true; Insertions = $n.Ins; Deletions = $n.Del })
        }
        if ($work -ne ' ' -and $work -ne '?') {
            $n = if ($unstagedNum.ContainsKey($pathStr)) { $unstagedNum[$pathStr] } else { @{ Ins = 0; Del = 0 } }
            $files.Add([pscustomobject]@{ Path = $pathStr; OrigPath = $orig; Status = (Get-SystemCmdGitStatusLabel $work); Staged = $false; Insertions = $n.Ins; Deletions = $n.Del })
        }
    }

    $fileArray = @($files.ToArray())
    $distinct = @($fileArray | Select-Object -ExpandProperty Path -Unique).Count
    $ins = ($fileArray | Measure-Object -Property Insertions -Sum).Sum
    $del = ($fileArray | Measure-Object -Property Deletions -Sum).Sum

    return [pscustomobject]@{
        Root = $root; Branch = $branch; Upstream = $upstream; Ahead = $ahead; Behind = $behind
        Files = $fileArray; FileCount = [int]$distinct; Insertions = [int]$ins; Deletions = [int]$del
    }
}

function Get-SystemCmdGitFileDiff {
    param([Parameter(Mandatory)][string]$Root, [Parameter(Mandatory)][string]$File, [switch]$Staged)
    $gitArgs = @('-C', $Root, 'diff')
    if ($Staged) { $gitArgs += '--cached' }
    $gitArgs += @('--', $File)
    $diff = (@(& git @gitArgs 2>$null) -join "`n")
    if (-not $diff.Trim() -and -not $Staged) {
        $full = Join-Path $Root $File
        if (Test-Path -LiteralPath $full) {
            $body = (Get-Content -LiteralPath $full -ErrorAction SilentlyContinue | ForEach-Object { "+$_" }) -join "`n"
            return "diff --git a/$File b/$File`n--- /dev/null`n+++ b/$File`n$body"
        }
    }
    return $diff
}

# Render a unified diff into coloured lines with old/new line numbers.
function Format-SystemCmdDiff {
    param([Parameter(Mandatory)][string]$DiffText)
    $out = New-Object System.Collections.Generic.List[string]
    $oldNo = 0; $newNo = 0
    foreach ($line in ($DiffText -split "`n")) {
        if ($line -match '^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@') {
            $oldNo = [int]$Matches[1]; $newNo = [int]$Matches[2]
            $out.Add((Format-SystemCmdText -Text $line -Role 'info')); continue
        }
        if ($line.StartsWith('diff ') -or $line.StartsWith('index ') -or $line.StartsWith('--- ') -or $line.StartsWith('+++ ')) {
            $out.Add((Format-SystemCmdText -Text $line -Role 'muted')); continue
        }
        if ($line.StartsWith('+')) {
            $num = ('{0,5}' -f $newNo); $newNo++
            $out.Add((Format-SystemCmdText -Text "$num $line" -Role 'add')); continue
        }
        if ($line.StartsWith('-')) {
            $num = ('{0,5}' -f $oldNo); $oldNo++
            $out.Add((Format-SystemCmdText -Text "$num $line" -Role 'del')); continue
        }
        $num = ('{0,5}' -f $newNo); $oldNo++; $newNo++
        $out.Add((Format-SystemCmdText -Text "$num $line" -Role 'dim'))
    }
    return $out.ToArray()
}

# --- Actions (discard is destructive → callers must confirm) ---
function Invoke-SystemCmdGitStage { param([string]$Root, [string]$File) & git -C $Root add -- $File 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }
function Invoke-SystemCmdGitUnstage { param([string]$Root, [string]$File) & git -C $Root reset -q HEAD -- $File 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }
function Invoke-SystemCmdGitDiscard { param([string]$Root, [string]$File) & git -C $Root checkout -- $File 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }
function Invoke-SystemCmdGitCommit { param([string]$Root, [string]$Message) & git -C $Root commit -m $Message 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }
