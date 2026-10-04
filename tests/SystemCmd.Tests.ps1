Describe 'SystemCmd' {
    BeforeDiscovery {
        # Evaluated during discovery so -Skip on git-dependent tests works correctly.
        $HasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)
    }
    BeforeAll {
        Import-Module "$PSScriptRoot/../src/SystemCmd/SystemCmd.psd1" -Force

        function New-TestRepo {
            param([string]$Path)
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            git -C $Path init -q | Out-Null
            git -C $Path config user.email 't@e.st' | Out-Null
            git -C $Path config user.name 'test' | Out-Null
            git -C $Path config commit.gpgsign false | Out-Null
            Set-Content -LiteralPath (Join-Path $Path 'keep.txt') -Value "l1`nl2`n"
            Set-Content -LiteralPath (Join-Path $Path 'gone.txt') -Value "bye`n"
            git -C $Path add -A | Out-Null
            git -C $Path commit -q -m init | Out-Null
        }
    }

    Context 'Platform' {
        It 'identifies a supported platform' { (Get-SystemCmdPlatform) | Should -BeIn @('Windows', 'macOS', 'Linux') }
        It 'exposes a valid default config' { (Get-SystemCmdConfig).language | Should -BeIn @('tr', 'en') }
        It 'detects terminal capabilities' {
            $c = Get-SystemCmdCapabilities
            $c.Width | Should -BeGreaterThan 0
            $c.Platform | Should -BeIn @('Windows', 'macOS', 'Linux')
        }
    }

    Context 'UI engine' {
        It 'strips ANSI for width measurement' {
            $s = Format-SystemCmdText -Text 'abc' -Role 'accent'
            (Remove-SystemCmdAnsi $s) | Should -Be 'abc'
        }
        It 'fits text to an exact visible width (pad and truncate)' {
            (Measure-SystemCmdWidth (Format-SystemCmdFit 'abcdef' 3)) | Should -Be 3
            (Measure-SystemCmdWidth (Format-SystemCmdFit 'ab' 5)) | Should -Be 5
        }
        It 'renders a panel with borders' {
            $panel = Get-SystemCmdPanel -Title 'T' -Lines @('one', 'two')
            $panel.Count | Should -BeGreaterThan 3
        }
    }

    Context 'Git parsing' {
        It 'parses numstat lines' {
            $m = ConvertFrom-SystemCmdNumstat @("3`t1`tsrc/a.ps1", "-`t-`tbin", "12`t4`tsrc/b.ps1")
            $m['src/a.ps1'].Ins | Should -Be 3
            $m['src/b.ps1'].Del | Should -Be 4
        }
        It 'maps porcelain status codes' {
            (Get-SystemCmdGitStatusLabel ([char]'M')) | Should -Be 'modified'
            (Get-SystemCmdGitStatusLabel ([char]'D')) | Should -Be 'deleted'
            (Get-SystemCmdGitStatusLabel ([char]'?')) | Should -Be 'untracked'
        }
        It 'reads a real repo status/diff' -Skip:(-not $HasGit) {
            $repo = Join-Path $TestDrive 'repo'
            New-TestRepo $repo
            Set-Content -LiteralPath (Join-Path $repo 'keep.txt') -Value "l1`nCHANGED`nl3`n"
            Set-Content -LiteralPath (Join-Path $repo 'fresh.txt') -Value "new`n"
            Remove-Item (Join-Path $repo 'gone.txt')

            $st = Get-SystemCmdGitStatus -Path $repo
            $st.Branch | Should -Not -BeNullOrEmpty
            ($st.Files | Where-Object { $_.Path -eq 'keep.txt' -and -not $_.Staged }).Status | Should -Be 'modified'
            ($st.Files | Where-Object { $_.Path -eq 'fresh.txt' }).Status | Should -Be 'untracked'
            ($st.Files | Where-Object { $_.Path -eq 'gone.txt' }).Status | Should -Be 'deleted'
            $st.Insertions | Should -BeGreaterThan 0

            $diff = Get-SystemCmdGitFileDiff -Root $repo -File 'keep.txt'
            $diff | Should -Match 'CHANGED'
            (Format-SystemCmdDiff -DiffText $diff).Count | Should -BeGreaterThan 0
        }
        It 'stages a file' -Skip:(-not $HasGit) {
            $repo = Join-Path $TestDrive 'repo2'
            New-TestRepo $repo
            Set-Content -LiteralPath (Join-Path $repo 'fresh.txt') -Value "x`n"
            (Invoke-SystemCmdGitStage -Root $repo -File 'fresh.txt') | Should -BeTrue
            $st = Get-SystemCmdGitStatus -Path $repo
            ($st.Files | Where-Object { $_.Path -eq 'fresh.txt' -and $_.Staged }).Status | Should -Be 'added'
        }
    }

    Context 'Changes UI' {
        It 'produces a header with the change summary' -Skip:(-not $HasGit) {
            $repo = Join-Path $TestDrive 'repo3'
            New-TestRepo $repo
            Set-Content -LiteralPath (Join-Path $repo 'keep.txt') -Value "changed`n"
            $st = Get-SystemCmdGitStatus -Path $repo
            $lines = Get-SystemCmdChangesLines -Status $st
            (Remove-SystemCmdAnsi $lines[0]) | Should -Match 'files changed'
        }
    }

    Context 'Project detection' {
        It 'detects node + pnpm from marker files' {
            $dir = Join-Path $TestDrive 'proj'
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $dir 'package.json') -Value '{"scripts":{"dev":"vite"}}'
            Set-Content -LiteralPath (Join-Path $dir 'pnpm-lock.yaml') -Value "lockfileVersion: '9.0'"
            $p = Get-SystemCmdProject -Path $dir
            $p.Kinds | Should -Contain 'node'
            $p.Kinds | Should -Contain 'pnpm'
        }
        It 'invents nothing for an empty directory' {
            $dir = Join-Path $TestDrive 'empty'
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            (Get-SystemCmdProject -Path $dir).Kinds.Count | Should -Be 0
        }
    }

    Context 'Buddy 3.0' {
        It 'builds a context object' {
            $ctx = Get-SystemCmdBuddyContext
            $ctx.Session | Should -Not -BeNullOrEmpty
            $ctx.PSObject.Properties.Name | Should -Contain 'LastExit'
        }
        It 'records repeated error fingerprints without storing output' {
            Update-SystemCmdBuddyState -Command 'pnpm build' -ExitCode 1
            Update-SystemCmdBuddyState -Command 'pnpm build' -ExitCode 1
            $line = Get-SystemCmdBuddyLine
            (Remove-SystemCmdAnsi $line) | Should -Match 'Buddy'
        }
    }

    Context 'Commands' {
        It 'exports the systemcmd command' { (Get-Command systemcmd).CommandType | Should -Be 'Function' }
        It 'exports sc alias command' { (Get-Command sc).CommandType | Should -Be 'Function' }
        It 'help runs without throwing' { { systemcmd help | Out-Null } | Should -Not -Throw }
    }
}
