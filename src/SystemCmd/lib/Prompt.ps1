$script:SystemCmdPromptPrevious = $null
$script:SystemCmdPromptInstalled = $null
$script:SystemCmdPromptMode = 'normal'
$script:SystemCmdPromptHistoryId = -1

function Get-SystemCmdPromptText {
    param([ValidateSet('compact','normal','rich')][string]$Mode = 'normal', [string]$Path = $PWD.Path, [int]$ExitCode = 0)
    $name = Split-Path -Leaf $Path
    $mark = if ($ExitCode -eq 0) { '>' } else { "!$ExitCode >" }
    if ($Mode -eq 'compact') { return "$name $mark " }
    # Prompt reads only already cached context: no git, network, live state or project scan.
    $context = ''
    if ($script:SystemCmdProjectCache.ContainsKey($Path)) { $context = ' [' + ($script:SystemCmdProjectCache[$Path].Info.Kinds -join ',') + ']' }
    if ($Mode -eq 'rich') { return "Buddy | $name$context | $(Format-SystemCmdDuration ((Get-Date) - $script:SystemCmdSessionStart))`nPS $Path $mark " }
    return "PS $Path$context $mark "
}

function Enable-SystemCmdPrompt {
    param([ValidateSet('compact','normal','rich')][string]$Mode = 'normal')
    $script:SystemCmdPromptMode = $Mode
    if ($script:SystemCmdPromptInstalled) { return }
    $previous = Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue
    $script:SystemCmdPromptPrevious = if ($previous) { $previous.ScriptBlock } else { $null }
    $module = $ExecutionContext.SessionState.Module
    $script:SystemCmdPromptInstalled = {
        $ok = $?; $nativeExit = $global:LASTEXITCODE
        & $module {
            param($ok, $nativeExit)
            $history = Get-History -Count 1 -ErrorAction SilentlyContinue
            $code = if ($ok) { 0 } elseif ($nativeExit) { [int]$nativeExit } else { 1 }
            if ($history -and $history.Id -ne $script:SystemCmdPromptHistoryId) {
                Update-SystemCmdBuddyState -Command $history.CommandLine -ExitCode $code
                $script:SystemCmdPromptHistoryId = $history.Id
            }
            Get-SystemCmdPromptText -Mode $script:SystemCmdPromptMode -ExitCode $code
        } $ok $nativeExit
    }.GetNewClosure()
    Set-Item Function:global:prompt $script:SystemCmdPromptInstalled
}

function Disable-SystemCmdPrompt {
    if (-not $script:SystemCmdPromptInstalled) { return }
    # A prompt installed by someone else after ours belongs to them.
    if ((Get-Command prompt -CommandType Function).ScriptBlock -eq $script:SystemCmdPromptInstalled) {
        if ($script:SystemCmdPromptPrevious) { Set-Item Function:global:prompt $script:SystemCmdPromptPrevious }
        else { Remove-Item Function:global:prompt }
    }
    $script:SystemCmdPromptInstalled = $null
}
