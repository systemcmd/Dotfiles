# SystemCmd.Buddy (3.0) — a terminal companion that *knows* the working context but
# stays quiet. This is the module-side context engine; the existing gamified pet in
# the live profile (systemcmd-companion.ps1) is preserved and untouched.

if (-not (Get-Variable -Scope Script -Name SystemCmdSessionStart -ErrorAction SilentlyContinue)) {
    $script:SystemCmdSessionStart = Get-Date
}
$script:SystemCmdBuddyState = @{ LastCommand = ''; LastExit = 0; Errors = @{}; LastError = '' }

function Format-SystemCmdDuration {
    param([timespan]$Span)
    if ($Span.TotalHours -ge 1) { return ('{0}h {1:00}m' -f [int]$Span.TotalHours, $Span.Minutes) }
    if ($Span.TotalMinutes -ge 1) { return ('{0}m {1:00}s' -f [int]$Span.TotalMinutes, $Span.Seconds) }
    return ('{0}s' -f [int]$Span.TotalSeconds)
}

# Called from a prompt hook (opt-in) to observe the last command + its exit code.
function Update-SystemCmdBuddyState {
    param([string]$Command, [int]$ExitCode = 0)
    if ($Command) { $script:SystemCmdBuddyState.LastCommand = $Command.Trim() }
    $script:SystemCmdBuddyState.LastExit = $ExitCode
    if ($ExitCode -ne 0 -and $Command) {
        # Fingerprint on the command's leading token only — never store output.
        $fp = ($Command.Trim() -split '\s+')[0]
        if (-not $script:SystemCmdBuddyState.Errors.ContainsKey($fp)) { $script:SystemCmdBuddyState.Errors[$fp] = 0 }
        $script:SystemCmdBuddyState.Errors[$fp]++
        $script:SystemCmdBuddyState.LastError = $Command.Trim()
    }
}

function Get-SystemCmdBuddyContext {
    param([string]$Path = $PWD.Path)
    $proj = Get-SystemCmdProject -Path $Path
    $branch = $null; $changes = $null
    if ($proj.Kinds -contains 'git') {
        $st = Get-SystemCmdGitStatus -Path $Path
        if ($st) { $branch = $st.Branch; $changes = $st.FileCount }
    }
    $lastExit = $script:SystemCmdBuddyState.LastExit
    if (-not $script:SystemCmdBuddyState.LastCommand) {
        $h = Get-History -Count 1 -ErrorAction SilentlyContinue
        if ($h) { $script:SystemCmdBuddyState.LastCommand = $h.CommandLine }
    }
    [pscustomobject]@{
        Project     = $proj.Name
        Kinds       = $proj.Kinds
        Branch      = $branch
        GitChanges  = $changes
        Session     = Format-SystemCmdDuration ((Get-Date) - $script:SystemCmdSessionStart)
        LastCommand = $script:SystemCmdBuddyState.LastCommand
        LastExit    = $lastExit
        LastOk      = ($lastExit -eq 0)
    }
}

function Get-SystemCmdBuddyLine {
    param([string]$Path = $PWD.Path)
    $ui = Get-SystemCmdUi
    $ctx = Get-SystemCmdBuddyContext -Path $Path
    $mark = if ($ctx.LastOk) { Format-SystemCmdText -Text $ui.Glyphs.Check -Role 'ok' } else { Format-SystemCmdText -Text $ui.Glyphs.Cross -Role 'err' }
    $parts = @(Format-SystemCmdText -Text "$($ui.Glyphs.Ring) Buddy" -Role 'accent')
    if ($ctx.Project) { $parts += Format-SystemCmdText -Text $ctx.Project -Role 'title' }
    if ($ctx.Branch) { $parts += Format-SystemCmdText -Text $ctx.Branch -Role 'dim' }
    $parts += $mark
    $line = ($parts -join (Format-SystemCmdText -Text ' · ' -Role 'muted'))
    # Repeated-error nudge (§11), no spam: only when the same command failed >=3x.
    $repeat = $script:SystemCmdBuddyState.Errors.Values | Where-Object { $_ -ge 3 } | Select-Object -First 1
    if ($repeat) { $line += (Format-SystemCmdText -Text "  · ayni hata $repeat kez · sc explain" -Role 'warn') }
    return $line
}

function Show-SystemCmdBuddyPanel {
    param([string]$Path = $PWD.Path)
    $ctx = Get-SystemCmdBuddyContext -Path $Path
    $ui = Get-SystemCmdUi
    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add((Format-SystemCmdRow -Label 'Project' -Value ($ctx.Project ?? '—')))
    $rows.Add((Format-SystemCmdRow -Label 'Branch' -Value ($ctx.Branch ?? '—')))
    if ($null -ne $ctx.GitChanges) { $rows.Add((Format-SystemCmdRow -Label 'Git' -Value "$($ctx.GitChanges) modified")) }
    $runtime = ($ctx.Kinds | Where-Object { $_ -notin @('git') }) -join ' + '
    if (-not $runtime) { $runtime = '—' }
    $rows.Add((Format-SystemCmdRow -Label 'Runtime' -Value $runtime))
    $rows.Add((Format-SystemCmdRow -Label 'Session' -Value $ctx.Session))
    $lastMark = if ($ctx.LastOk) { "$($ui.Glyphs.Check)" } else { "$($ui.Glyphs.Cross)" }
    if ($ctx.LastCommand) { $rows.Add((Format-SystemCmdRow -Label 'Last' -Value "$($ctx.LastCommand)  $lastMark")) }
    $rows.Add((Format-SystemCmdRow -Label 'Brain' -Value (Get-SystemCmdBrainStateLabel)))
    Show-SystemCmdPanel -Title 'Buddy' -Lines $rows.ToArray()
}

# Heuristic, offline explanation of the last failed command (§10). No auto-execution.
function Show-SystemCmdBuddyExplain {
    $cmd = $script:SystemCmdBuddyState.LastError
    if (-not $cmd) { Write-Host (Format-SystemCmdText -Text 'Bu oturumda aciklanacak bir hata yok.' -Role 'dim'); return }
    $tool = ($cmd -split '\s+')[0]
    $hint = switch -Regex ($tool) {
        'pnpm|npm|yarn|bun' { 'Bagimliliklari kurmayi deneyin: `pnpm install`. Script adi package.json ile eslesiyor mu?' }
        'cargo' { 'Derleme hatasi olabilir: `cargo check` ile ok isaretli satiri inceleyin.' }
        'git' { 'Git durumunu kontrol edin: `git status`. Yol/branch dogru mu?' }
        'python|python3|pytest' { 'Sanal ortam aktif mi? Eksik paket icin `pip install -r requirements.txt`.' }
        'docker' { 'Docker daemon calisiyor mu? `docker ps` ile kontrol edin.' }
        default { "Komut sifirdan farkli kod dondurdu. `$tool --help` veya cikti son satirlarina bakin." }
    }
    Show-SystemCmdPanel -Title 'Buddy · explain' -Lines @(
        (Format-SystemCmdRow -Label 'Komut' -Value $cmd),
        (Format-SystemCmdText -Text $hint -Role 'title')
    )
}
