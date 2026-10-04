function Get-SystemCmdActions {
    foreach ($name in @('changes','project','status','buddy','brain','doctor','ports','dashboard','live','theme','help')) {
        [pscustomobject]@{ Name = $name; Command = $name; Path = ''; Description = "systemcmd $name" }
    }
    foreach ($entry in $script:SystemCmdProjectCache.Values) {
        [pscustomobject]@{ Name = $entry.Info.Name; Command = 'project'; Path = $entry.Info.Root; Description = $entry.Info.Root }
    }
}

function Find-SystemCmdAction {
    param([string]$Query = '', [object[]]$Actions = @(Get-SystemCmdActions))
    $matchesFound = foreach ($action in $Actions) {
        $name = $action.Name.ToLowerInvariant(); $needle = $Query.ToLowerInvariant()
        $pos = -1; $score = 0; $matched = $true
        foreach ($ch in $needle.ToCharArray()) {
            $next = $name.IndexOf($ch, $pos + 1)
            if ($next -lt 0) { $matched = $false; break }
            $score += $next - $pos - 1; $pos = $next
        }
        if ($matched) { [pscustomobject]@{ Action = $action; Score = $score + $name.Length - $needle.Length } }
    }
    @($matchesFound | Sort-Object Score, @{Expression={$_.Action.Name}} | ForEach-Object { $_.Action })
}

function Invoke-SystemCmdAction {
    param($Action)
    if ($Action.Command -notin @('changes','project','status','buddy','brain','doctor','ports','dashboard','live','theme','help')) { throw 'Unknown command center action.' }
    if ($Action.Path) { Push-Location -LiteralPath $Action.Path }
    try { Invoke-SystemCmd -Command $Action.Command } finally { if ($Action.Path) { Pop-Location } }
}

function Show-SystemCmdCommandCenter {
    param([string]$Query = '', [switch]$Find)
    if (-not (Get-SystemCmdCapabilities).Interactive -or [Console]::IsInputRedirected) { Find-SystemCmdAction $Query; return }
    $previous = Get-SystemCmdLivePane
    $savedState = if ($previous) { $previous.State } else { $null }
    $session = Open-SystemCmdLivePane -Mode FIND -Automatic
    $selected = 0; $chosen = $null
    Enter-SystemCmdAltScreen
    try {
        while ($true) {
            $items = @(Find-SystemCmdAction $Query)
            $selected = [Math]::Clamp($selected, 0, [Math]::Max(0, $items.Count - 1))
            $lines = @("SYSTEMCMD | $Query", 'Type to filter | arrows/j/k select | Enter run | Esc close', '')
            for ($i=0; $i -lt $items.Count; $i++) { $lines += ('{0} {1}' -f $(if ($i -eq $selected) { '>' } else { ' ' }), $items[$i].Name) }
            if ($items.Count) { Update-SystemCmdLiveState -Mode FIND -Data @{ Title = $items[$selected].Name; Lines = @($items[$selected].Description) } }
            Write-SystemCmdFrame $lines
            $key = Read-SystemCmdKey
            if (-not $key -or $key -eq 'Esc') { break }
            if ($key -eq 'Enter' -and $items.Count) { $chosen = $items[$selected]; break }
            if ($key -in @('Down','j')) { $selected++; continue }
            if ($key -in @('Up','k')) { $selected--; continue }
            if ($key -eq 'Backspace' -or $key -eq [string][char]8) { if ($Query.Length) { $Query = $Query.Substring(0, $Query.Length - 1) }; continue }
            if ($key.Length -eq 1 -and -not [char]::IsControl($key[0])) { $Query += $key; $selected = 0 }
        }
    } finally {
        Exit-SystemCmdAltScreen
        if (-not $previous) { Stop-SystemCmdLiveSession }
        elseif ($savedState) { Update-SystemCmdLiveState -Mode $savedState.Mode -Data $savedState.Data }
    }
    if ($chosen) { Invoke-SystemCmdAction $chosen }
}
