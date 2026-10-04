# Add this file to $PROFILE on macOS. It deliberately imports only the portable core.
$systemCmdModule = Join-Path $PSScriptRoot '..\src\SystemCmd\SystemCmd.psd1'
Import-Module $systemCmdModule -Force
