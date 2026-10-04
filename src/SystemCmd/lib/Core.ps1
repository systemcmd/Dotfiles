# SystemCmd.Core — diagnostics, run, status, the command dispatcher and completion.

function Get-SystemCmdDoctor {
    $tools = @('git', 'fzf', 'bat', 'nvim')
    if ((Get-SystemCmdPlatform) -eq 'macOS') { $tools += 'brew' }
    foreach ($tool in $tools) {
        [pscustomobject]@{ Tool = $tool; Available = [bool](Get-Command $tool -ErrorAction SilentlyContinue); Path = (Get-Command $tool -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source) }
    }
}

function Show-SystemCmdDoctor {
    $rows = Get-SystemCmdDoctor
    $rows | Format-Table Tool, Available, Path -AutoSize
    if (($rows | Where-Object { -not $_.Available }).Count) { Write-Warning 'Eksik araclar bulundu. macOS: brew install fzf bat neovim git' }
}

function Get-SystemCmdPorts {
    if ($IsWindows -and (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue)) {
        Get-NetTCPConnection | Sort-Object LocalPort | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess
        return
    }
    if (Get-Command lsof -ErrorAction SilentlyContinue) { & lsof -nP -iTCP -sTCP:LISTEN; return }
    if (Get-Command ss -ErrorAction SilentlyContinue) { & ss -tulpn; return }
    Write-Warning 'Portlari listelemek icin lsof veya ss gerekli.'
}

function Get-SystemCmdDashboardData {
    $data = [ordered]@{ Platform = Get-SystemCmdPlatform; CPU = $null; Memory = $null; Disk = $null; Battery = $null }
    try {
        if ($IsMacOS) {
            $data.CPU = ((& sysctl -n hw.ncpu) + ' cores')
            $mem = [math]::Round(([int64](& sysctl -n hw.memsize) / 1GB), 1)
            $pages = (& vm_stat) -join "`n"
            $freePages = [regex]::Match($pages, 'Pages free:\s+(\d+)').Groups[1].Value
            if ($freePages) { $data.Memory = "~$([math]::Round($mem - (([int64]$freePages * 16384) / 1GB), 1)) / $mem GB" }
            $data.Battery = (& pmset -g batt 2>$null | Select-Object -First 1).Trim()
        } elseif ($IsLinux) {
            $data.CPU = ((& nproc) + ' cores')
            $data.Memory = ((& free -h | Select-Object -Skip 1 -First 1) -replace '\s+', ' ').Trim()
        } elseif ($IsWindows) {
            $data.CPU = (Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name).Trim()
            $os = Get-CimInstance Win32_OperatingSystem
            $data.Memory = "{0:N1} / {1:N1} GB" -f (($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB), ($os.TotalVisibleMemorySize / 1MB)
        }
        $data.Disk = ((Get-PSDrive -PSProvider FileSystem | Sort-Object Free | Select-Object -First 1 | ForEach-Object { "{0:N1} GB free ({1})" -f ($_.Free / 1GB), $_.Root }))
    } catch { Write-Verbose "Dashboard data unavailable: $($_.Exception.Message)" }
    [pscustomobject]$data
}

function Show-SystemCmdDashboard { Get-SystemCmdDashboardData | Format-List }

function Get-SystemCmdRunTarget {
    $root = $PWD.Path
    $checks = @(
        @{ File = 'package.json'; Command = 'npm'; Args = @('run', 'dev') }, @{ File = 'Cargo.toml'; Command = 'cargo'; Args = @('run') },
        @{ File = 'go.mod'; Command = 'go'; Args = @('run', '.') }, @{ File = 'main.py'; Command = 'python3'; Args = @('main.py') },
        @{ File = 'Makefile'; Command = 'make'; Args = @() }, @{ File = 'compose.yml'; Command = 'docker'; Args = @('compose', 'up') }
    )
    foreach ($check in $checks) { if (Test-Path -LiteralPath (Join-Path $root $check.File)) { return [pscustomobject]$check } }
}

function Invoke-SystemCmdRun {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments)][string[]]$ExtraArgs)
    $target = Get-SystemCmdRunTarget
    if (-not $target) { Write-Warning 'Taninan proje bulunamadi.'; return }
    if (-not (Get-Command $target.Command -ErrorAction SilentlyContinue)) { Write-Warning "'$($target.Command)' bulunamadi."; return }
    Invoke-SystemCmdOwnedOperation -Mode RUN -Command $target.Command -Arguments @($target.Args + $ExtraArgs)
}

function Show-SystemCmdStatus {
    $ui = Get-SystemCmdUi
    $proj = Get-SystemCmdProject
    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add((Format-SystemCmdRow -Label 'OS' -Value (Get-SystemCmdPlatform)))
    $rows.Add((Format-SystemCmdRow -Label 'Shell' -Value "PowerShell $($PSVersionTable.PSVersion)"))
    $rows.Add((Format-SystemCmdRow -Label 'Project' -Value $proj.Name))
    if ($proj.Kinds -contains 'git') {
        $st = Get-SystemCmdGitStatus
        if ($st) {
            $rows.Add((Format-SystemCmdRow -Label 'Branch' -Value $st.Branch))
            $rows.Add((Format-SystemCmdRow -Label 'Changes' -Value "$($st.FileCount)"))
        }
    }
    $rows.Add((Format-SystemCmdRow -Label 'Brain' -Value (Get-SystemCmdBrainStateLabel)))
    $load = if ($script:SystemCmdLoadMs) { '{0:N0} ms' -f $script:SystemCmdLoadMs } else { 'n/a' }
    $rows.Add((Format-SystemCmdRow -Label 'Startup' -Value $load))
    Show-SystemCmdPanel -Title 'SYSTEMCMD' -Lines $rows.ToArray()
}

# --- Performance (§18) ---
function Get-SystemCmdPerformance {
    $git = (Measure-Command { try { Get-SystemCmdGitStatus | Out-Null } catch { } }).TotalMilliseconds
    $proj = (Measure-Command { try { Get-SystemCmdProject | Out-Null } catch { } }).TotalMilliseconds
    $caps = (Measure-Command { Get-SystemCmdCapabilities | Out-Null }).TotalMilliseconds
    [ordered]@{
        'Profile load'    = $script:SystemCmdLoadMs
        'Capabilities'    = [math]::Round($caps, 1)
        'Git status'      = [math]::Round($git, 1)
        'Project detect'  = [math]::Round($proj, 1)
        'Brain'           = 'lazy'
    }
}

function Show-SystemCmdPerformance {
    $ui = Get-SystemCmdUi
    $perf = Get-SystemCmdPerformance
    $rows = New-Object System.Collections.Generic.List[string]
    foreach ($k in $perf.Keys) {
        $v = $perf[$k]
        $mark = $ui.Glyphs.Check
        $role = 'ok'
        if ($v -is [double] -or $v -is [int]) {
            $txt = '{0,7:N1} ms' -f $v
            if ($v -gt 200) { $mark = $ui.Glyphs.Cross; $role = 'warn' }
        } else { $txt = "$v" }
        $rows.Add((Format-SystemCmdFit -Text ((Format-SystemCmdText -Text ($k.PadRight(16)) -Role 'dim') + (Format-SystemCmdText -Text $txt -Role 'title') + '  ' + (Format-SystemCmdText -Text $mark -Role $role)) -Width 34))
    }
    Show-SystemCmdPanel -Title 'performance' -Lines $rows.ToArray()
}

# --- Themes (§23) ---
function Get-SystemCmdThemeNames { return @($script:SystemCmdThemes.Keys) }
function Set-SystemCmdTheme {
    param([Parameter(Mandatory)][string]$Name)
    if (-not $script:SystemCmdThemes.ContainsKey($Name)) { Write-Warning "Tema yok: $Name. Mevcut: $((Get-SystemCmdThemeNames) -join ', ')"; return }
    Set-SystemCmdConfig -Values @{ theme = $Name }
    Reset-SystemCmdUi
    Write-Host (Format-SystemCmdText -Text "Tema: $Name" -Role 'ok')
}
function Show-SystemCmdThemePreview {
    foreach ($role in @('accent', 'title', 'add', 'del', 'mod', 'info', 'warn', 'err', 'dim')) {
        Write-Host (Format-SystemCmdText -Text ("  $role".PadRight(12)) -Role 'dim') (Format-SystemCmdText -Text 'Ornek metin 123' -Role $role)
    }
}

function Invoke-SystemCmd {
    param([Parameter(Position = 0)][string]$Command = '', [Parameter(ValueFromRemainingArguments)][string[]]$Rest)
    # Normalise: @($null).Count is 1, so strip nulls to a clean (possibly empty) array.
    $Rest = @($Rest | Where-Object { $null -ne $_ -and $_ -ne '' })
    switch ($Command.ToLowerInvariant()) {
        '' { Show-SystemCmdCommandCenter }
        'find' { Show-SystemCmdCommandCenter -Find -Query ($Rest -join ' ') }
        'live' { Invoke-SystemCmdLive -Arguments $Rest }
        'prompt' { if ($Rest -contains 'off') { Disable-SystemCmdPrompt } else { Enable-SystemCmdPrompt -Mode $(if ($Rest.Count) { $Rest[0] } else { 'normal' }) } }
        'test' { Invoke-SystemCmdTest -Arguments $Rest }
        'changes' { Show-SystemCmdChanges -Watch:([bool]($Rest -contains '--watch' -or $Rest -contains 'watch')) -Static:($Rest -contains '--static') -Layout $(if ($Rest -contains '--side-by-side') { 'side-by-side' } else { 'unified' }) }
        'projects' { Show-SystemCmdProject }
        'project' { Show-SystemCmdProject }
        'status' { Show-SystemCmdStatus }
        'buddy' {
            $sub = if (@($Rest).Count) { $Rest[0].ToLowerInvariant() } else { 'panel' }
            switch ($sub) { 'explain' { Show-SystemCmdBuddyExplain } default { Show-SystemCmdBuddyPanel } }
        }
        'brain' { Show-SystemCmdBrain }
        'doctor' { if ($Rest -contains '--performance' -or $Rest -contains 'performance') { Show-SystemCmdPerformance } else { Show-SystemCmdDoctor } }
        'ports' { Get-SystemCmdPorts }
        'dashboard' { Show-SystemCmdDashboard }
        'run' { Invoke-SystemCmdRun @Rest }
        'config' { Get-SystemCmdConfig | ConvertTo-Json -Depth 8 }
        'theme' {
            $sub = if (@($Rest).Count) { $Rest[0].ToLowerInvariant() } else { 'list' }
            switch ($sub) {
                'set' { if (@($Rest).Count -ge 2) { Set-SystemCmdTheme -Name $Rest[1] } else { Write-Warning 'Kullanim: systemcmd theme set <ad>' } }
                'preview' { Show-SystemCmdThemePreview }
                default { Write-Host "Temalar: $((Get-SystemCmdThemeNames) -join ', ')" }
            }
        }
        'help' { Show-SystemCmdHelp }
        default { Show-SystemCmdHelp }
    }
}

function Show-SystemCmdHelp {
    $ui = Get-SystemCmdUi
    $cmds = @(
        @('changes', 'git degisiklik gorunumu (--watch)'), @('project', 'proje HUD'), @('status', 'hizli durum panosu'),
        @('buddy', 'companion paneli (explain)'), @('brain', 'brain context'), @('doctor', 'kurulum sagligi (--performance)'),
        @('ports', 'dinlenen portlar'), @('dashboard', 'sistem panosu'), @('run', 'projeyi calistir'),
        @('theme', 'tema list/set/preview'), @('config', 'konfigurasyon'),
        @('live', 'status/open/close/toggle [MODE]'), @('prompt', 'compact/normal/rich/off'),
        @('find', 'fuzzy action finder'), @('test', '<executable> [arguments]')
    )
    $lines = foreach ($c in $cmds) { (Format-SystemCmdText -Text ("  " + $c[0].PadRight(12)) -Role 'accent') + (Format-SystemCmdText -Text $c[1] -Role 'dim') }
    Show-SystemCmdPanel -Title 'SYSTEMCMD' -Lines @($lines)
}

function systemcmd { param([Parameter(Position = 0)][string]$Command = '', [Parameter(ValueFromRemainingArguments)][string[]]$Rest); Invoke-SystemCmd -Command $Command -Rest $Rest }
function system { param([Parameter(Position = 0)][string]$Command = '', [Parameter(ValueFromRemainingArguments)][string[]]$Rest); Invoke-SystemCmd -Command $Command -Rest $Rest }
function sc { param([Parameter(Position = 0)][string]$Command = '', [Parameter(ValueFromRemainingArguments)][string[]]$Rest); Invoke-SystemCmd -Command $Command -Rest $Rest }

# --- Completion (§16) ---
function Register-SystemCmdCompletion {
    $top = 'changes', 'project', 'projects', 'status', 'buddy', 'brain', 'doctor', 'ports', 'dashboard', 'run', 'test', 'find', 'live', 'prompt', 'theme', 'config', 'help'
    $sub = @{ live = @('status','open','close','toggle'); prompt = @('compact','normal','rich','off'); buddy = @('panel', 'explain'); theme = @('list', 'set', 'preview'); doctor = @('--performance'); changes = @('--watch','--static','--side-by-side') }
    $block = {
        param($wordToComplete, $commandAst, $cursorPosition)
        $tokens = @($commandAst.CommandElements | ForEach-Object { $_.ToString() })
        if ($tokens.Count -le 2) {
            $top | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
        } elseif ($sub.ContainsKey($tokens[1])) {
            $sub[$tokens[1]] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
        }
    }.GetNewClosure()
    foreach ($name in @('systemcmd', 'system', 'sc')) { Register-ArgumentCompleter -CommandName $name -ScriptBlock $block }
}
Register-SystemCmdCompletion

function Invoke-SystemCmdOwnedOperation {
    param([ValidateSet('RUN','TEST')][string]$Mode, [string]$Command, [string[]]$Arguments)
    $resolved = Get-Command $Command -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $previous = Get-SystemCmdLivePane
    $saved = if ($previous) { $previous.State } else { $null }
    [void](Open-SystemCmdLivePane -Mode $Mode -Automatic)
    try {
        Update-SystemCmdLiveState -Mode $Mode -Data @{ Title = "$Mode | $Command"; Lines = @('RUNNING', "Command: $Command", 'Pass/fail counts: unknown (no structured test report)') }
        & $resolved.Source @Arguments
        $code = $LASTEXITCODE
        Update-SystemCmdLiveState -Mode $Mode -Data @{ Title = "$Mode | $Command"; Lines = @("Exit: $code", $(if ($code -eq 0) { 'Completed successfully' } else { 'Failed; see command output in main shell' })) }
        Update-SystemCmdBuddyState -Command $Command -ExitCode $code
        $global:LASTEXITCODE = $code
    } finally {
        if (-not $previous) { Stop-SystemCmdLiveSession }
        elseif ($saved) { Update-SystemCmdLiveState -Mode $saved.Mode -Data $saved.Data }
    }
}

function Invoke-SystemCmdTest {
    param([string[]]$Arguments)
    if (-not $Arguments.Count) { Write-Warning 'Usage: systemcmd test <executable> [arguments]'; return }
    $rest = @($Arguments | Select-Object -Skip 1)
    Invoke-SystemCmdOwnedOperation -Mode TEST -Command $Arguments[0] -Arguments $rest
}

function Publish-SystemCmdTestResult {
    param([int]$Passed, [int]$Failed, [int]$Skipped = 0, [string]$Current = '', [string]$Failure = '', [switch]$Running)
    Update-SystemCmdLiveState -Mode TEST -Data @{ Title = "Tests | $Current"; Lines = @("Running: $Running", "Passed: $Passed | Failed: $Failed | Skipped: $Skipped", (Protect-SystemCmdTerminalText $Failure)) }
}
