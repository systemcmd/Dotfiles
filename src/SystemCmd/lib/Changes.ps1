# SystemCmd.Changes — a terminal-native git "changes" experience (no GUI).
# Static summary, interactive browser (j/k nav, diff, stage/unstage/commit) and --watch.

function Get-SystemCmdChangeStatusGlyph {
    param([string]$Status)
    switch ($Status) {
        'modified' { @{ L = 'M'; Role = 'mod' } }
        'added' { @{ L = 'A'; Role = 'add' } }
        'deleted' { @{ L = 'D'; Role = 'del' } }
        'renamed' { @{ L = 'R'; Role = 'info' } }
        'untracked' { @{ L = 'U'; Role = 'add' } }
        'conflicted' { @{ L = 'C'; Role = 'err' } }
        default { @{ L = '?'; Role = 'dim' } }
    }
}

function Get-SystemCmdChangesHeader {
    param($Status)
    $ui = Get-SystemCmdUi
    $files = "$($Status.FileCount) files changed"
    $add = Format-SystemCmdText -Text "+$($Status.Insertions)" -Role 'add'
    $del = Format-SystemCmdText -Text "-$($Status.Deletions)" -Role 'del'
    $branch = Format-SystemCmdText -Text "$($ui.Glyphs.Dot) $($Status.Branch)" -Role 'accent'
    $sync = ''
    if ($Status.Ahead -or $Status.Behind) { $sync = Format-SystemCmdText -Text "  ^$($Status.Ahead) v$($Status.Behind)" -Role 'dim' }
    return "$(Format-SystemCmdText -Text $files -Role 'title' -Bold)  $add $del   $branch$sync"
}

function Get-SystemCmdChangeRow {
    param($File, [bool]$Selected, [int]$PathWidth)
    $ui = Get-SystemCmdUi
    $g = Get-SystemCmdChangeStatusGlyph $File.Status
    $marker = if ($Selected) { Format-SystemCmdText -Text "$($ui.Glyphs.Arrow) " -Role 'accent' } else { '  ' }
    $letter = Format-SystemCmdText -Text $g.L -Role $g.Role
    $stageMark = if ($File.Staged) { Format-SystemCmdText -Text '*' -Role 'ok' } else { ' ' }
    $path = $File.Path
    if ($File.OrigPath) { $path = "$($File.OrigPath) -> $($File.Path)" }
    $pathText = Format-SystemCmdFit -Text $path -Width $PathWidth
    $pathRole = if ($Selected) { 'title' } else { 'dim' }
    $pathText = Format-SystemCmdText -Text $pathText -Role $pathRole
    $statsText = (Format-SystemCmdText -Text ("+$($File.Insertions)") -Role 'add') + ' ' + (Format-SystemCmdText -Text ("-$($File.Deletions)") -Role 'del')
    return "$marker$stageMark $letter  $pathText  $statsText"
}

function Get-SystemCmdChangesLines {
    param($Status, [int]$Selected = -1)
    $ui = Get-SystemCmdUi
    $term = $ui.Caps.Width
    $maxPath = 0
    foreach ($f in $Status.Files) {
        $p = if ($f.OrigPath) { "$($f.OrigPath) -> $($f.Path)" } else { $f.Path }
        if ($p.Length -gt $maxPath) { $maxPath = $p.Length }
    }
    $pathWidth = [Math]::Min([Math]::Max(20, $maxPath + 1), $term - 26)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add((Get-SystemCmdChangesHeader $Status))
    $lines.Add((Format-SystemCmdText -Text ($ui.Glyphs.H * [Math]::Min($term - 1, 60)) -Role 'muted'))
    if ($Status.Files.Count -eq 0) {
        $lines.Add((Format-SystemCmdText -Text 'Calisma alani temiz.' -Role 'dim'))
    }
    for ($i = 0; $i -lt $Status.Files.Count; $i++) {
        $lines.Add((Get-SystemCmdChangeRow -File $Status.Files[$i] -Selected ($i -eq $Selected) -PathWidth $pathWidth))
    }
    return $lines.ToArray()
}

# --- screen helpers ---
function Enter-SystemCmdAltScreen { [Console]::Write("$([char]27)[?1049h$([char]27)[H"); try { [Console]::CursorVisible = $false } catch { } }
function Exit-SystemCmdAltScreen { try { [Console]::CursorVisible = $true } catch { }; [Console]::Write("$([char]27)[?1049l") }
function Write-SystemCmdFrame {
    param([string[]]$Lines)
    $e = [char]27
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("$e[H")
    foreach ($l in $Lines) { [void]$sb.Append($l); [void]$sb.Append("$e[K`n") }
    [void]$sb.Append("$e[J")
    [Console]::Write($sb.ToString())
}

function Show-SystemCmdChanges {
    [CmdletBinding()]
    param([string]$Path = $PWD.Path, [switch]$Watch, [switch]$Static, [string]$Layout = 'unified')

    if (-not (Test-SystemCmdGitAvailable)) { Write-Warning 'git bulunamadi.'; return }
    $status = Get-SystemCmdGitStatus -Path $Path
    if (-not $status) { Write-Warning "Bu dizin bir git deposu degil: $Path"; return }

    $ui = Get-SystemCmdUi
    $interactive = $ui.Caps.Interactive -and $ui.Caps.Color

    if ($Watch) { Invoke-SystemCmdChangesWatch -Path $status.Root; return }
    if ($Static -or -not $interactive) {
        Get-SystemCmdChangesLines -Status $status | ForEach-Object { Write-Host $_ }
        return
    }
    Invoke-SystemCmdChangesBrowser -Root $status.Root -Layout $Layout
}

function Invoke-SystemCmdChangesWatch {
    param([string]$Path)
    $ui = Get-SystemCmdUi
    Enter-SystemCmdAltScreen
    try {
        $lastHash = ''
        while ($true) {
            $status = Get-SystemCmdGitStatus -Path $Path
            $lines = @(Get-SystemCmdChangesLines -Status $status)
            $lines += ''
            $lines += (Format-SystemCmdText -Text '[q] cikis · degisiklik bekleniyor…' -Role 'dim')
            $hash = ($status.Files | ForEach-Object { "$($_.Path)$($_.Staged)$($_.Insertions)$($_.Deletions)" }) -join '|'
            $hash = "$($status.Branch)|$($status.FileCount)|$hash"
            if ($hash -ne $lastHash) { Write-SystemCmdFrame -Lines $lines; $lastHash = $hash }
            $waited = 0
            while ($waited -lt 1000) {
                if ([Console]::KeyAvailable) {
                    $k = [Console]::ReadKey($true)
                    if ($k.KeyChar -eq 'q' -or $k.Key -eq 'Escape') { return }
                }
                Start-Sleep -Milliseconds 80; $waited += 80
            }
        }
    } finally { Exit-SystemCmdAltScreen }
}

function Invoke-SystemCmdChangesBrowser {
    param([string]$Root, [string]$Layout = 'unified')
    $ui = Get-SystemCmdUi
    $help = '[jk] gez  [enter] diff  [s]tage [u]nstage  [c]ommit  [x] discard  [o] ac  [r] yenile  [q] cikis'
    $state = @{ Sel = 0; Mode = 'list'; Diff = @(); Scroll = 0; Msg = '' }
    $previous = Get-SystemCmdLivePane
    $savedState = if ($previous) { $previous.State } else { $null }
    $live = Open-SystemCmdLivePane -Mode GIT -Automatic
    Enter-SystemCmdAltScreen
    try {
        $status = Get-SystemCmdGitStatus -Path $Root
        while ($true) {
            if ($status.Files.Count -eq 0 -and $state.Mode -eq 'list') { $state.Sel = 0 }
            if ($state.Sel -ge $status.Files.Count) { $state.Sel = [Math]::Max(0, $status.Files.Count - 1) }
            if ($state.Sel -lt 0) { $state.Sel = 0 }
            Reset-SystemCmdUi
            Update-SystemCmdChangesPreview -Status $status -Selected $state.Sel -Layout $Layout
            [void](Test-SystemCmdLivePaneAlive)

            if ($state.Mode -eq 'list') {
                $lines = @(Get-SystemCmdChangesLines -Status $status -Selected $state.Sel)
                $lines += ''
                if ($state.Msg) { $lines += (Format-SystemCmdText -Text $state.Msg -Role 'warn') }
                $lines += (Format-SystemCmdText -Text $help -Role 'dim')
                Write-SystemCmdFrame -Lines $lines
            } else {
                $termH = 20; try { $termH = [Console]::WindowHeight - 4 } catch { }
                $view = @($state.Diff | Select-Object -Skip $state.Scroll -First $termH)
                $head = @()
                $head += (Format-SystemCmdText -Text ("diff · " + $status.Files[$state.Sel].Path) -Role 'title' -Bold)
                $head += (Format-SystemCmdText -Text ($ui.Glyphs.H * 60) -Role 'muted')
                $foot = @('', (Format-SystemCmdText -Text '[jk] kaydir  [esc] geri  [q] cikis' -Role 'dim'))
                Write-SystemCmdFrame -Lines ($head + $view + $foot)
            }

            $key = Read-SystemCmdKey
            if (-not $key) { return }
            $state.Msg = ''
            if ($state.Mode -eq 'diff') {
                switch ($key) {
                    { $_ -in @('Down', 'j') } { if ($state.Scroll -lt $state.Diff.Count - 1) { $state.Scroll++ } }
                    { $_ -in @('Up', 'k') } { if ($state.Scroll -gt 0) { $state.Scroll-- } }
                    { $_ -in @('Esc', 'q') } { $state.Mode = 'list' }
                }
                continue
            }
            switch ($key) {
                { $_ -in @('Down', 'j') } { if ($state.Sel -lt $status.Files.Count - 1) { $state.Sel++ } }
                { $_ -in @('Up', 'k') } { if ($state.Sel -gt 0) { $state.Sel-- } }
                { $_ -in @('Enter', 'd') } {
                    if ($status.Files.Count -gt 0) {
                        $f = $status.Files[$state.Sel]
                        $diff = Get-SystemCmdGitFileDiff -Root $Root -File $f.Path -Staged:$f.Staged
                        $state.Diff = @(Format-SystemCmdDiffView -DiffText $diff -Layout $Layout); $state.Scroll = 0; $state.Mode = 'diff'
                    }
                }
                's' {
                    if ($status.Files.Count -gt 0) {
                        $f = $status.Files[$state.Sel]
                        if (-not $f.Staged) { [void](Invoke-SystemCmdGitStage -Root $Root -File $f.Path); $status = Get-SystemCmdGitStatus -Path $Root }
                        else { $state.Msg = 'Zaten stage edilmis.' }
                    }
                }
                'u' {
                    if ($status.Files.Count -gt 0) {
                        $f = $status.Files[$state.Sel]
                        if ($f.Staged) { [void](Invoke-SystemCmdGitUnstage -Root $Root -File $f.Path); $status = Get-SystemCmdGitStatus -Path $Root }
                        else { $state.Msg = 'Bu dosya stage degil.' }
                    }
                }
                'x' {
                    if ($status.Files.Count -gt 0) {
                        $f = $status.Files[$state.Sel]
                        if ($f.Status -eq 'untracked') { $state.Msg = 'Untracked dosya discard edilemez.' }
                        else {
                            Write-SystemCmdFrame -Lines @((Format-SystemCmdText -Text "DISCARD: $($f.Path) degisiklikleri geri alinsin mi? [y/N]" -Role 'err'))
                            $c = Read-SystemCmdKey
                            if ($c -eq 'y') { [void](Invoke-SystemCmdGitDiscard -Root $Root -File $f.Path); $status = Get-SystemCmdGitStatus -Path $Root; $state.Msg = 'Discard edildi.' }
                        }
                    }
                }
                'c' {
                    $staged = @($status.Files | Where-Object Staged)
                    if ($staged.Count -eq 0) { $state.Msg = 'Once stage edin (s).' }
                    else {
                        Exit-SystemCmdAltScreen
                        $msg = Read-Host 'Commit mesaji'
                        Enter-SystemCmdAltScreen
                        if ($msg) { if (Invoke-SystemCmdGitCommit -Root $Root -Message $msg) { $status = Get-SystemCmdGitStatus -Path $Root; $state.Msg = 'Commit olusturuldu.' } else { $state.Msg = 'Commit basarisiz.' } }
                    }
                }
                'o' {
                    if ($status.Files.Count -gt 0) { Open-SystemCmdFile -Path (Join-Path $Root $status.Files[$state.Sel].Path) }
                }
                'r' { $status = Get-SystemCmdGitStatus -Path $Root; $state.Msg = 'Yenilendi.' }
                { $_ -in @('q', 'Esc') } { return }
            }
        }
    } finally {
        Exit-SystemCmdAltScreen
        if (-not $previous) { Stop-SystemCmdLiveSession }
        elseif ($savedState) { Update-SystemCmdLiveState -Mode $savedState.Mode -Data $savedState.Data }
    }
}

function Open-SystemCmdFile {
    param([string]$Path)
    try {
        if ($env:EDITOR) { & $env:EDITOR $Path }
        elseif (Get-Command code -ErrorAction SilentlyContinue) { & code $Path }
        elseif ($IsWindows) { Start-Process $Path }
        elseif ($IsMacOS) { & open $Path }
        else { & xdg-open $Path }
    } catch { }
}
