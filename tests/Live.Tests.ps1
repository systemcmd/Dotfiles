Describe 'Native Live Surface' {
BeforeAll {
    Import-Module "$PSScriptRoot/../src/SystemCmd/SystemCmd.psd1" -Force
    $script:modulePath = (Resolve-Path "$PSScriptRoot/../src/SystemCmd/SystemCmd.psd1").Path
}
AfterEach { Stop-SystemCmdLiveSession; Disable-SystemCmdPrompt }

Describe 'Live transport and lifecycle' {
    It 'falls back for redirected output even with inherited WT environment' {
        $cap = Test-SystemCmdLiveCapability
        if ([Console]::IsOutputRedirected) { $cap.Native | Should -BeFalse; $cap.Reason | Should -Match 'redirected' }
    }
    It 'prevents recursive pane creation' {
        $old = $env:SYSTEMCMD_LIVE_RENDERER
        try { $env:SYSTEMCMD_LIVE_RENDERER='1'; (Test-SystemCmdLiveCapability).Reason | Should -Match 'Preview process' }
        finally { $env:SYSTEMCMD_LIVE_RENDERER=$old }
    }
    It 'publishes and reads atomic state with identity and monotonic revisions' {
        $s = Start-SystemCmdLiveSession GIT
        Update-SystemCmdLiveState -Mode GIT -Data @{Title='a'; Diff="one`ntwo"}
        $state = Read-SystemCmdLiveState $s.Directory $s.Id
        $state.Revision | Should -Be 2
        $state.Data.Diff | Should -Be "one`ntwo"
        Read-SystemCmdLiveState $s.Directory 'different-session' | Should -BeNullOrEmpty
        @(Get-ChildItem $s.Directory -Filter '*.tmp').Count | Should -Be 0
    }
    It 'reuses one session and closes repeatedly without stale files' {
        $one = Start-SystemCmdLiveSession
        (Start-SystemCmdLiveSession).Id | Should -Be $one.Id
        Stop-SystemCmdLiveSession
        Test-Path $one.Directory | Should -BeFalse
        Stop-SystemCmdLiveSession
        $two = Start-SystemCmdLiveSession
        $two.Id | Should -Not -Be $one.Id
    }
    It 'does not accept PID reuse as a live owner' {
        Test-SystemCmdLiveOwner @{Pid=$PID;StartTicks=1} | Should -BeFalse
    }
    It 'removes dead-owner state and preserves active sessions' {
        $s = Start-SystemCmdLiveSession
        $stale = Join-Path (Get-SystemCmdLiveRoot) ([guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory $stale | Out-Null
        Write-SystemCmdLiveJson (Join-Path $stale 'owner.json') @{Pid=$PID;StartTicks=1}
        Clear-SystemCmdStaleLiveSessions
        Test-Path $stale | Should -BeFalse
        Test-Path $s.Directory | Should -BeTrue
    }
    It 'rejects cleanup outside a session directory' {
        { Remove-SystemCmdLiveDirectory $TestDrive } | Should -Throw
    }
    It 'tolerates incomplete or corrupt state' {
        $s = Start-SystemCmdLiveSession
        Set-Content (Join-Path $s.Directory state.json) '{'
        Read-SystemCmdLiveState $s.Directory $s.Id | Should -BeNullOrEmpty
    }
    It 'renders every shared mode without StrictMode failures' {
        $s = Start-SystemCmdLiveSession
        foreach ($mode in @('GIT','PROJECT','BRAIN','RUN','TEST','FIND','ERROR')) {
            Set-SystemCmdLiveMode $mode
            @(Get-SystemCmdLiveLines (Read-SystemCmdLiveState $s.Directory $s.Id)).Count | Should -BeGreaterThan 0
        }
    }
    It 'renderer acknowledges, reads updates, and exits after transport closes' {
        $s = Start-SystemCmdLiveSession
        $psi = [Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
        $psi.UseShellExecute=$false; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true
        foreach($arg in @('-NoProfile','-File',"$PSScriptRoot/../src/SystemCmd/LiveRenderer.ps1",'-Directory',$s.Directory,'-Session',$s.Id)) { $psi.ArgumentList.Add($arg) }
        $process = [Diagnostics.Process]::Start($psi)
        $stdout = $process.StandardOutput.ReadToEndAsync(); $stderr = $process.StandardError.ReadToEndAsync()
        try {
            $deadline=[DateTime]::UtcNow.AddSeconds(10)
            while (-not (Test-Path (Join-Path $s.Directory ready.json)) -and -not $process.HasExited -and [DateTime]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 50 }
            Test-Path (Join-Path $s.Directory ready.json) | Should -BeTrue
            Update-SystemCmdLiveState -Mode FIND -Data @{Title='TRANSPORT_CHECK';Lines=@('updated')}
            Start-Sleep -Milliseconds 650
            Stop-SystemCmdLiveSession
            $process.WaitForExit(5000) | Should -BeTrue
            $process.ExitCode | Should -Be 0
            $stderr.Result | Should -BeNullOrEmpty
            $stdout.Result | Should -Match 'TRANSPORT_CHECK'
        } finally { if (-not $process.HasExited) { $process.Kill() }; $process.Dispose() }
    }
}

Describe 'Real Git selection and action previews' {
    BeforeEach {
        $repo = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory $repo | Out-Null
        git -C $repo init -q
        git -C $repo config user.name Test
        git -C $repo config user.email test@example.invalid
        git -C $repo config commit.gpgsign false
        Set-Content (Join-Path $repo 'a.txt') 'old-a'
        Set-Content (Join-Path $repo 'b.txt') 'old-b'
        git -C $repo add .
        git -C $repo commit -qm initial
        Set-Content (Join-Path $repo 'a.txt') 'new-a'
        Set-Content (Join-Path $repo 'b.txt') 'new-b'
        $s = Start-SystemCmdLiveSession GIT
    }
    It 'changes selection without changing session identity' {
        $status = Get-SystemCmdGitStatus $repo
        Update-SystemCmdChangesPreview $status 0
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Diff | Should -Match 'new-a'
        Update-SystemCmdChangesPreview $status 1
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Diff | Should -Match 'new-b'
        (Get-SystemCmdLivePane).Id | Should -Be $s.Id
    }
    It 'refreshes stage, unstage and discard from real Git state' {
        Invoke-SystemCmdGitStage $repo 'a.txt' | Should -BeTrue
        Update-SystemCmdChangesPreview (Get-SystemCmdGitStatus $repo) 0
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Title | Should -Match 'staged: True'
        Invoke-SystemCmdGitUnstage $repo 'a.txt' | Should -BeTrue
        Update-SystemCmdChangesPreview (Get-SystemCmdGitStatus $repo) 0
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Title | Should -Match 'staged: False'
        Invoke-SystemCmdGitDiscard $repo 'a.txt' | Should -BeTrue
        Update-SystemCmdChangesPreview (Get-SystemCmdGitStatus $repo) 0
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Title | Should -Match 'b.txt'
    }
    It 'handles an empty repository selection safely' {
        Update-SystemCmdChangesPreview ([pscustomobject]@{Files=@()}) 8
        (Read-SystemCmdLiveState $s.Directory $s.Id).Data.Title | Should -Be 'Working tree clean'
    }
}

Describe 'Prompt, finder and diff behavior' {
    It 'renders compact, normal and rich prompts without discovering projects' {
        Get-SystemCmdPromptText compact '/example/repo' | Should -Be 'repo > '
        Get-SystemCmdPromptText normal '/example/repo' 7 | Should -Match '!7 >'
        Get-SystemCmdPromptText rich '/example/repo' | Should -Match 'Buddy'
    }
    It 'restores the exact previous prompt and supports repeated enabling' {
        $original = (Get-Command prompt -CommandType Function).ScriptBlock
        Enable-SystemCmdPrompt compact
        Enable-SystemCmdPrompt rich
        Disable-SystemCmdPrompt
        (Get-Command prompt -CommandType Function).ScriptBlock | Should -Be $original
    }
    It 'preserves a prompt installed after SYSTEMCMD' {
        $original = (Get-Command prompt -CommandType Function).ScriptBlock
        try {
            Enable-SystemCmdPrompt
            $replacement = { 'replacement> ' }
            Set-Item Function:global:prompt $replacement
            Disable-SystemCmdPrompt
            (Get-Command prompt -CommandType Function).ScriptBlock | Should -Be $replacement
        } finally { Set-Item Function:global:prompt $original }
    }
    It 'matches ordered fuzzy subsequences and rejects nonmatches' {
        @(Find-SystemCmdAction chg)[0].Name | Should -Be changes
        @(Find-SystemCmdAction zzzzz).Count | Should -Be 0
    }
    It 'command center exposes core actions in noninteractive shells' {
        @(Get-SystemCmdActions).Name | Should -Contain changes
        @(Get-SystemCmdActions).Name | Should -Contain live
        { Invoke-SystemCmdAction ([pscustomobject]@{Command='injected';Path=''}) } | Should -Throw
    }
    It 'selects readable diff layouts and strips terminal control input' {
        Get-SystemCmdDiffLayout side-by-side 80 | Should -Be unified
        Get-SystemCmdDiffLayout side-by-side 120 | Should -Be side-by-side
        $diff="@@ -1 +1 @@`n-old`n+new"
        (@(Format-SystemCmdDiffView $diff side-by-side 120) -join "`n") | Should -Match 'old.*\|.*new'
        Protect-SystemCmdTerminalText "a$([char]27)]52;payload$([char]7)" | Should -Not -Match ([string][char]27)
    }
    It 'uses offline Brain without starting a job' {
        InModuleScope SystemCmd {
            Mock Get-SystemCmdBrainConfig { $null }
            Start-SystemCmdBrainContext demo | Should -BeNullOrEmpty
            Get-SystemCmdBrainStateLabel | Should -Be offline
        }
    }
    It 'publishes structured test counts without parsing console text' {
        $s=Start-SystemCmdLiveSession TEST
        Publish-SystemCmdTestResult -Passed 3 -Failed 1 -Current 'unit' -Failure 'assertion'
        ((Read-SystemCmdLiveState $s.Directory $s.Id).Data.Lines -join ' ') | Should -Match 'Passed: 3.*Failed: 1'
    }
}

Describe 'Portable installer' {
    It 'installs all files, preserves profiles, is idempotent and uninstalls only its block' {
        $dest=Join-Path $TestDrive 'install with spaces'
        $profile=Join-Path $TestDrive 'profile.ps1'
        $bash=Join-Path $TestDrive '.bashrc'
        Set-Content $profile '# custom profile'
        Set-Content $bash '# custom bash'
        & "$PSScriptRoot/../scripts/Install-Core.ps1" -Destination $dest -ProfilePath $profile -BashProfile $bash
        $first=Get-Content $profile -Raw
        & "$PSScriptRoot/../scripts/Install-Core.ps1" -Destination $dest -ProfilePath $profile -BashProfile $bash
        (Get-Content $profile -Raw) | Should -Be $first
        Test-Path (Join-Path $dest 'src/SystemCmd/LiveRenderer.ps1') | Should -BeTrue
        Test-Path (Join-Path $dest 'shell/systemcmd.zsh') | Should -BeTrue
        & "$PSScriptRoot/../scripts/Install-Core.ps1" -Destination $dest -ProfilePath $profile -BashProfile $bash -Uninstall
        (Get-Content $profile -Raw) | Should -Match '# custom profile'
        (Get-Content $profile -Raw) | Should -Not -Match 'Import-Module'
        (Get-Content $bash -Raw) | Should -Match '# custom bash'
    }
    It 'refuses an unmanaged installation directory' {
        $dest=Join-Path $TestDrive 'unmanaged'
        New-Item -ItemType Directory $dest | Out-Null
        { & "$PSScriptRoot/../scripts/Install-Core.ps1" -Destination $dest -ProfilePath (Join-Path $TestDrive p.ps1) } | Should -Throw
    }
}
}
