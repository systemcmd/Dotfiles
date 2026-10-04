param([Parameter(ValueFromRemainingArguments)][string[]]$Arguments)
Import-Module (Join-Path $PSScriptRoot '../src/SystemCmd/SystemCmd.psd1') -ErrorAction Stop
$command = if ($Arguments.Count) { $Arguments[0] } else { '' }
$rest = @($Arguments | Select-Object -Skip 1)
try { Invoke-SystemCmd -Command $command -Rest $rest }
finally { Stop-SystemCmdLiveSession }
if ($command -in @('run','test') -and $null -ne $LASTEXITCODE) { exit $LASTEXITCODE }
