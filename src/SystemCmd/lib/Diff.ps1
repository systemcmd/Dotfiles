function Get-SystemCmdDiffLayout {
    param([ValidateSet('unified','side-by-side','auto')][string]$Layout = 'unified', [int]$Width = (Get-SystemCmdTerminalWidth))
    if ($Layout -ne 'unified' -and $Width -ge 110) { return 'side-by-side' }
    return 'unified'
}

function Protect-SystemCmdTerminalText {
    param([AllowEmptyString()][string]$Text)
    # Repository contents are untrusted terminal text, never terminal commands.
    return [regex]::Replace($Text, '[\x00-\x08\x0B-\x1F\x7F-\x9F]', '')
}

function Format-SystemCmdDiffView {
    param([AllowEmptyString()][string]$DiffText, [string]$Layout = 'unified', [int]$Width = (Get-SystemCmdTerminalWidth))
    $DiffText = Protect-SystemCmdTerminalText $DiffText
    if (-not $DiffText) { return @('No diff.') }
    if ((Get-SystemCmdDiffLayout $Layout $Width) -eq 'unified') { return Format-SystemCmdDiff $DiffText }
    $half = [int][Math]::Floor(($Width - 3) / 2)
    $old = 0; $new = 0
    $removed = [Collections.Generic.List[string]]::new(); $added = [Collections.Generic.List[string]]::new()
    foreach ($line in @(($DiffText -split "`n")) + @('@@ END')) {
        if ($line -match '^-' -and $line -notmatch '^--- ') { $removed.Add(('{0,5} -{1}' -f $old, $line.Substring(1))); $old++; continue }
        if ($line -match '^\+' -and $line -notmatch '^\+\+\+ ') { $added.Add(('{0,5} +{1}' -f $new, $line.Substring(1))); $new++; continue }
        for ($i=0; $i -lt [Math]::Max($removed.Count,$added.Count); $i++) {
            $left = if ($i -lt $removed.Count) { $removed[$i] } else { '' }
            $right = if ($i -lt $added.Count) { $added[$i] } else { '' }
            (Format-SystemCmdText (Format-SystemCmdFit $left $half) -Role del) + ' | ' + (Format-SystemCmdText (Format-SystemCmdFit $right $half) -Role add)
        }
        $removed.Clear(); $added.Clear()
        if ($line -eq '@@ END') { break }
        if ($line -match '^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@') { $old=[int]$Matches[1]; $new=[int]$Matches[2]; Format-SystemCmdText $line -Role info }
        elseif ($line.StartsWith(' ')) {
            (Format-SystemCmdFit ('{0,5} {1}' -f $old,$line) $half) + ' | ' + (Format-SystemCmdFit ('{0,5} {1}' -f $new,$line) $half)
            $old++; $new++
        } else { Format-SystemCmdText $line -Role muted }
    }
}

function Update-SystemCmdChangesPreview {
    param($Status, [int]$Selected = 0, [string]$Layout = 'unified')
    if (-not (Get-SystemCmdLivePane)) { return }
    if (-not $Status -or $Status.Files.Count -eq 0) { Update-SystemCmdLiveState -Mode GIT -Data @{ Title = 'Working tree clean'; Lines = @('No changes.') }; return }
    $file = $Status.Files[[Math]::Clamp($Selected,0,$Status.Files.Count-1)]
    $diff = Get-SystemCmdGitFileDiff -Root $Status.Root -File $file.Path -Staged:$file.Staged
    Update-SystemCmdLiveState -Mode GIT -Data @{ Title = (Protect-SystemCmdTerminalText "$($file.Path) | staged: $($file.Staged) | $($Status.Branch)"); Diff = $diff; Layout = $Layout; Lines = @('No diff.') }
}
