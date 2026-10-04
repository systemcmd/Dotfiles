# Session-scoped local transport. Features publish data; only adapters create panes.
$script:SystemCmdLiveSession = $null
$script:SystemCmdLiveModule = Join-Path (Split-Path $PSScriptRoot -Parent) 'SystemCmd.psd1'

function Get-SystemCmdLiveConfig {
    $result = @{ enabled = $true; autoOpen = $true; position = 'right'; size = 35 }
    $cfg = Get-SystemCmdConfig
    if ($cfg.PSObject.Properties['livePane']) {
        foreach ($key in @($result.Keys)) {
            if ($cfg.livePane.PSObject.Properties[$key]) { $result[$key] = $cfg.livePane.$key }
        }
    }
    $result.size = [Math]::Clamp([int]$result.size, 20, 50)
    return [pscustomobject]$result
}

function Test-SystemCmdLiveCapability {
    $cfg = Get-SystemCmdLiveConfig
    $caps = Get-SystemCmdCapabilities
    $adapter = 'inline'; $reason = ''; $terminal = ($env:TERM_PROGRAM ?? $env:TERM ?? 'unknown')
    if ($env:WT_SESSION) { $terminal = 'Windows Terminal (inherited signal)' }
    if ($env:TMUX) { $terminal = 'tmux' }
    if (-not $cfg.enabled) { $reason = 'Live Pane disabled in config.' }
    elseif ($env:SYSTEMCMD_LIVE_RENDERER) { $reason = 'Preview process cannot open another pane.' }
    elseif (-not $caps.Interactive -or [Console]::IsInputRedirected) { $reason = 'Input/output is redirected; no interactive terminal.' }
    elseif ($caps.Width -lt 90) { $reason = 'Terminal is too narrow for a readable split.' }
    elseif ($env:TMUX -and $env:TMUX_PANE -and (Get-Command tmux -ErrorAction SilentlyContinue)) {
        $pane = & tmux display-message -p -t $env:TMUX_PANE '#{pane_id}' 2>$null
        if ($LASTEXITCODE -eq 0 -and $pane -eq $env:TMUX_PANE) { $adapter = 'tmux' }
        else { $reason = 'tmux pane is no longer available.' }
    }
    elseif ($IsWindows -and $env:WT_SESSION -and $env:TERM_PROGRAM -ne 'vscode' -and (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
        if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) { $adapter = 'windows-terminal' }
        else { $reason = 'Inherited WT_SESSION without a running Windows Terminal.' }
    } else { $reason = 'No supported native pane in this terminal. Use tmux or Windows Terminal.' }
    [pscustomobject]@{ Enabled = [bool]$cfg.enabled; Terminal = $terminal; Adapter = $adapter; Native = ($adapter -ne 'inline'); Reason = $reason }
}

function Get-SystemCmdLiveRoot {
    # The OS per-user temp directory supplies Windows ACLs. Unix gets mode 0700.
    $root = Join-Path ([IO.Path]::GetTempPath()) ('systemcmd-live-' + [Environment]::UserName)
    if (-not [IO.Directory]::Exists($root)) { [void][IO.Directory]::CreateDirectory($root) }
    if (-not $IsWindows) { & chmod 700 -- $root }
    return $root
}

function Test-SystemCmdLiveOwner {
    param($Owner)
    try {
        $p = [Diagnostics.Process]::GetProcessById([int]$Owner.Pid)
        return (-not $p.HasExited -and $p.StartTime.ToUniversalTime().Ticks -eq [long]$Owner.StartTicks)
    } catch { return $false }
}

function Remove-SystemCmdLiveDirectory {
    param([string]$Directory)
    $root = [IO.Path]::GetFullPath((Get-SystemCmdLiveRoot))
    $full = [IO.Path]::GetFullPath($Directory)
    if ([IO.Path]::GetDirectoryName($full) -ne $root -or [IO.Path]::GetFileName($full) -notmatch '^[a-f0-9]{32}$') { throw 'Invalid Live session directory.' }
    if (Test-Path -LiteralPath $full) {
        if ((Get-Item -LiteralPath $full -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { return }
        Remove-Item -LiteralPath $full -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Clear-SystemCmdStaleLiveSessions {
    foreach ($dir in @(Get-ChildItem -LiteralPath (Get-SystemCmdLiveRoot) -Directory)) {
        if ($dir.Name -notmatch '^[a-f0-9]{32}$' -or ($dir.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
        try {
            $owner = Get-Content -LiteralPath (Join-Path $dir.FullName 'owner.json') -Raw -ErrorAction Stop | ConvertFrom-Json
            if (-not (Test-SystemCmdLiveOwner $owner)) { Remove-SystemCmdLiveDirectory $dir.FullName }
        } catch {
            if ($dir.LastWriteTimeUtc -lt [DateTime]::UtcNow.AddHours(-1)) { Remove-SystemCmdLiveDirectory $dir.FullName }
        }
    }
}

function Write-SystemCmdLiveJson {
    param([string]$Path, $Value)
    $temp = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp, ($Value | ConvertTo-Json -Depth 12 -Compress), [Text.UTF8Encoding]::new($false))
        [IO.File]::Move($temp, $Path, $true)
    } finally { if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) } }
}

function Start-SystemCmdLiveSession {
    param([ValidateSet('GIT','PROJECT','BRAIN','RUN','TEST','FIND','ERROR')][string]$Mode = 'PROJECT')
    if ($script:SystemCmdLiveSession) { return $script:SystemCmdLiveSession }
    Clear-SystemCmdStaleLiveSessions
    $id = [guid]::NewGuid().ToString('N')
    $dir = Join-Path (Get-SystemCmdLiveRoot) $id
    [void][IO.Directory]::CreateDirectory($dir)
    $owner = @{ Pid = $PID; StartTicks = [Diagnostics.Process]::GetCurrentProcess().StartTime.ToUniversalTime().Ticks }
    Write-SystemCmdLiveJson (Join-Path $dir 'owner.json') $owner
    $script:SystemCmdLiveSession = [pscustomobject]@{ Id = $id; Directory = $dir; Mode = $Mode; Adapter = 'inline'; PaneId = ''; Native = $false; Reason = ''; Revision = 0; State = $null }
    Update-SystemCmdLiveState -Mode $Mode -Data @{ Title = 'SYSTEMCMD LIVE'; Lines = @('Waiting for context') }
    return $script:SystemCmdLiveSession
}

function Get-SystemCmdLivePane { return $script:SystemCmdLiveSession }

function Update-SystemCmdLiveState {
    param([ValidateSet('GIT','PROJECT','BRAIN','RUN','TEST','FIND','ERROR')][string]$Mode, [Parameter(Mandatory)]$Data)
    $session = $script:SystemCmdLiveSession
    if (-not $session) { return }
    if ($Mode) { $session.Mode = $Mode }
    $session.Revision++
    $session.State = @{ Version = 1; Session = $session.Id; Revision = $session.Revision; Mode = $session.Mode; Data = $Data }
    try { Write-SystemCmdLiveJson (Join-Path $session.Directory 'state.json') $session.State }
    catch { $session.Native = $false; $session.Reason = 'State transport unavailable; inline preview retained.' }
}

function Read-SystemCmdLiveState {
    param([string]$Directory, [string]$Session)
    try {
        $state = Get-Content -LiteralPath (Join-Path $Directory 'state.json') -Raw -ErrorAction Stop | ConvertFrom-Json
        if ($state.Version -eq 1 -and $state.Session -eq $Session) { return $state }
    } catch { }
    return $null
}

function Set-SystemCmdLiveMode {
    param([ValidateSet('GIT','PROJECT','BRAIN','RUN','TEST','FIND','ERROR')][string]$Mode)
    Update-SystemCmdLiveState -Mode $Mode -Data (Get-SystemCmdLiveContext $Mode)
}

function Open-SystemCmdLivePane {
    param([ValidateSet('GIT','PROJECT','BRAIN','RUN','TEST','FIND','ERROR')][string]$Mode = 'PROJECT', [switch]$Automatic)
    $session = Start-SystemCmdLiveSession $Mode
    if ($session.Native) { return $session }
    $cap = Test-SystemCmdLiveCapability
    $cfg = Get-SystemCmdLiveConfig
    $session.Reason = $cap.Reason
    if (-not $cap.Native -or ($Automatic -and -not $cfg.autoOpen)) { return $session }
    $renderer = Join-Path (Split-Path $script:SystemCmdLiveModule -Parent) 'LiveRenderer.ps1'
    # Encoded command quotes paths as data and avoids WT's semicolon parser in paths.
    $command = '& ' + "'" + $renderer.Replace("'", "''") + "' -Directory '" + $session.Directory.Replace("'", "''") + "' -Session '" + $session.Id + "'"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $pwsh = (Get-Process -Id $PID).Path
    try {
        if ($cap.Adapter -eq 'windows-terminal') {
            $size = ($cfg.size / 100.0).ToString([Globalization.CultureInfo]::InvariantCulture)
            & wt.exe -w 0 split-pane -V --size $size --title 'SYSTEMCMD LIVE' $pwsh -NoLogo -NoProfile -EncodedCommand $encoded ';' move-focus previous
            if ($LASTEXITCODE -ne 0) { throw 'Windows Terminal rejected split-pane.' }
        } else {
            $pane = & tmux split-window -h -d -p $cfg.size -t $env:TMUX_PANE -P -F '#{pane_id}' $pwsh -NoLogo -NoProfile -EncodedCommand $encoded 2>$null
            if ($LASTEXITCODE -ne 0 -or $pane -notmatch '^%\d+$') { throw 'tmux rejected split-window.' }
            $session.PaneId = [string]$pane
        }
        $deadline = [DateTime]::UtcNow.AddSeconds(4)
        $ready = Join-Path $session.Directory 'ready.json'
        while (-not [IO.File]::Exists($ready) -and [DateTime]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 80 }
        if (-not [IO.File]::Exists($ready)) { throw 'Preview did not acknowledge startup.' }
        $session.Adapter = $cap.Adapter; $session.Native = $true; $session.Reason = ''
    } catch {
        $session.Reason = $_.Exception.Message
        # Closing the transport also cancels a renderer that starts late.
        $reason = $session.Reason
        Stop-SystemCmdLiveSession
        $session = Start-SystemCmdLiveSession $Mode
        $session.Reason = $reason
    }
    return $session
}

function Test-SystemCmdLivePaneAlive {
    $s = $script:SystemCmdLiveSession
    if (-not $s -or -not $s.Native) { return $false }
    try {
        $ready = Get-Content -LiteralPath (Join-Path $s.Directory 'ready.json') -Raw -ErrorAction Stop | ConvertFrom-Json
        if (Test-SystemCmdLiveOwner $ready) { return $true }
    } catch { }
    $s.Native = $false; $s.Reason = 'Preview closed; using inline view.'
    return $false
}

function Stop-SystemCmdLiveSession {
    $session = $script:SystemCmdLiveSession
    if (-not $session) { return }
    $script:SystemCmdLiveSession = $null
    Remove-SystemCmdLiveDirectory $session.Directory
}
function Close-SystemCmdLivePane { Stop-SystemCmdLiveSession }

function Get-SystemCmdLiveContext {
    param([string]$Mode = 'PROJECT')
    $p = Get-SystemCmdProject
    $lines = @("Project: $($p.Name)", "Ecosystem: $($p.Kinds -join ', ')")
    switch ($Mode) {
        'PROJECT' {
            $st = Get-SystemCmdGitStatus
            if ($st) { $lines += "Branch: $($st.Branch) | $($st.FileCount) changes" }
            $lines += "Shell: PowerShell $($PSVersionTable.PSVersion)"
        }
        'BRAIN' { $lines += "Brain: $(Get-SystemCmdBrainStateLabel)"; $lines += 'Context fetched only by an explicit brain command.' }
        'RUN' { $lines += 'Run a project with systemcmd run. Health and logs are not inferred.' }
        'TEST' { $lines += 'Use systemcmd test <executable> [arguments]. Counts require a structured result.' }
        'ERROR' { $lines += "Last error: $($script:SystemCmdBuddyState.LastError)" }
        'FIND' { $lines += 'Use systemcmd find to select an action.' }
        'GIT' { $lines += 'Use systemcmd changes to browse file diffs.' }
    }
    return @{ Title = "$Mode | $($p.Name)"; Lines = $lines }
}

function Get-SystemCmdLiveLines {
    param($State, [int]$Width = (Get-SystemCmdTerminalWidth))
    $data = $State.Data
    $lines = @("SYSTEMCMD LIVE | $($State.Mode)", [string]$data.Title, '')
    if ($data.PSObject.Properties['Diff'] -and $data.Diff) {
        $layout = if ($data.PSObject.Properties['Layout']) { $data.Layout } else { 'unified' }
        $lines += @(Format-SystemCmdDiffView -DiffText $data.Diff -Layout $layout -Width $Width)
    } elseif ($data.PSObject.Properties['Lines']) { $lines += @($data.Lines) }
    foreach ($line in $lines) { Format-SystemCmdFit -Text ([string]$line) -Width ([Math]::Max(1, $Width - 1)) }
}

function Invoke-SystemCmdLive {
    param([string[]]$Arguments)
    $action = if ($Arguments.Count) { $Arguments[0] } else { 'status' }
    switch ($action) {
        'close' { Close-SystemCmdLivePane }
        'toggle' { if (Get-SystemCmdLivePane) { Close-SystemCmdLivePane } else { Invoke-SystemCmdLive @('open') } }
        'open' {
            $mode = if ($Arguments.Count -gt 1) { $Arguments[1].ToUpperInvariant() } else { 'PROJECT' }
            $s = Open-SystemCmdLivePane -Mode $mode
            Set-SystemCmdLiveMode $mode
            if (-not $s.Native) { Get-SystemCmdLiveLines (Read-SystemCmdLiveState $s.Directory $s.Id) | ForEach-Object { Write-Host $_ } }
        }
        default {
            $cap = Test-SystemCmdLiveCapability
            $s = Get-SystemCmdLivePane
            [pscustomobject]@{ Enabled = $cap.Enabled; Terminal = $cap.Terminal; Adapter = $(if ($s) { $s.Adapter } else { $cap.Adapter }); NativeSupported = $cap.Native; Session = $(if ($s) { $s.Id } else { 'none' }); FallbackReason = $(if ($s -and $s.Reason) { $s.Reason } else { $cap.Reason }) }
        }
    }
}
