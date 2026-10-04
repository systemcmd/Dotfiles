# SystemCmd — cross-platform intelligent shell environment.
# This module is the portable source of truth; it runs INSIDE an existing terminal
# and shell (PowerShell 7 primary), never as a standalone GUI/emulator.
#
# The .psm1 is a thin loader: each capability lives in its own lib/*.ps1 file
# (Platform, UI, Git, Projects, Brain, Buddy, Changes, Core).

Set-StrictMode -Version Latest

$script:SystemCmdLoadMs = $null
$__systemcmdStart = Get-Date
$__systemcmdHere = Split-Path -Parent $PSCommandPath

foreach ($lib in @('Platform', 'Ui', 'Git', 'Projects', 'Brain', 'Buddy', 'Diff', 'Live', 'Prompt', 'Find', 'Changes', 'Core')) {
    $path = Join-Path $__systemcmdHere "lib/$lib.ps1"
    if (Test-Path -LiteralPath $path) { . $path }
    else { Write-Warning "SystemCmd: eksik modul dosyasi: $path" }
}

$script:SystemCmdLoadMs = ((Get-Date) - $__systemcmdStart).TotalMilliseconds

Export-ModuleMember -Function *
$ExecutionContext.SessionState.Module.OnRemove = { Disable-SystemCmdPrompt; Stop-SystemCmdLiveSession }
