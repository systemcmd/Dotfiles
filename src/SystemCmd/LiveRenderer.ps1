param([Parameter(Mandatory)][string]$Directory, [Parameter(Mandatory)][string]$Session)
$env:SYSTEMCMD_LIVE_RENDERER = '1'
Import-Module (Join-Path $PSScriptRoot 'SystemCmd.psd1') -ErrorAction Stop
if (-not (Test-Path -LiteralPath $Directory)) { exit }
$watcher = $null
try {
    $owner = Get-Content -LiteralPath (Join-Path $Directory 'owner.json') -Raw | ConvertFrom-Json
    if (-not (Test-SystemCmdLiveOwner $owner)) { exit }
    $watcher = [IO.FileSystemWatcher]::new($Directory)
    $watcher.EnableRaisingEvents = $true
    Write-SystemCmdLiveJson (Join-Path $Directory 'ready.json') @{ Pid = $PID; StartTicks = [Diagnostics.Process]::GetCurrentProcess().StartTime.ToUniversalTime().Ticks }
    Enter-SystemCmdAltScreen
    $revision = -1; $width = 0; $height = 0
    while ([IO.Directory]::Exists($Directory) -and (Test-SystemCmdLiveOwner $owner)) {
        $state = Read-SystemCmdLiveState $Directory $Session
        $w = Get-SystemCmdTerminalWidth
        $h = 24
        try { $h = [Math]::Max(4, [Console]::WindowHeight) } catch { }
        if ($state -and ($state.Revision -ne $revision -or $w -ne $width -or $h -ne $height)) {
            Reset-SystemCmdUi
            $lines = @(Get-SystemCmdLiveLines $state $w)
            if ($lines.Count -ge $h) { $lines = @($lines | Select-Object -First ($h - 2)) + @('... Enter in main pane for scrollable diff') }
            Write-SystemCmdFrame $lines
            $revision = $state.Revision; $width = $w; $height = $h
        }
        # Notifications wake immediately; timeout covers missed events, resize and owner death.
        [void]$watcher.WaitForChanged([IO.WatcherChangeTypes]::All, 500)
    }
} finally {
    if ($watcher) { $watcher.Dispose() }
    Exit-SystemCmdAltScreen
    Remove-SystemCmdLiveDirectory $Directory
}
