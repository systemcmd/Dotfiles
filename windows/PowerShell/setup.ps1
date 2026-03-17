[CmdletBinding()]
param(
    [string]$SourceDir
)

if (-not $PSScriptRoot) {
    Invoke-Expression ((Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/systemcmd/Dotfiles/main/windows/install.ps1').Content)
    return
}

$installerPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'install.ps1'
if (-not (Test-Path -LiteralPath $installerPath)) {
    throw 'Installer bulunamadi.'
}

& $installerPath @PSBoundParameters
