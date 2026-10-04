[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $HOME '.local/share/systemcmd'),
    [string]$ProfilePath = $PROFILE.CurrentUserAllHosts,
    [string]$BashProfile = '',
    [string]$ZshProfile = '',
    [switch]$Uninstall,
    [switch]$Rollback
)
$ErrorActionPreference = 'Stop'
$source = Split-Path $PSScriptRoot -Parent
$Destination = [IO.Path]::GetFullPath($Destination)
$marker = Join-Path $Destination '.systemcmd-core-install'
$backup = "$Destination.previous"

function Set-CoreProfileBlock {
    param([string]$Path, [string]$Body, [switch]$Remove)
    if (-not $Path) { return }
    $text = if (Test-Path -LiteralPath $Path) { [IO.File]::ReadAllText($Path) } else { '' }
    $begin = '# >>> SYSTEMCMD portable core >>>'; $end = '# <<< SYSTEMCMD portable core <<<'
    $pattern = '(?ms)^' + [regex]::Escape($begin) + '\r?\n.*?^' + [regex]::Escape($end) + '(?:\r?\n)?'
    $clean = [regex]::Replace($text, $pattern, '')
    $updated = if ($Remove) { $clean } else { $clean.TrimEnd("`r","`n") + "`n$begin`n$Body`n$end`n" }
    if ($updated -ne $text) {
        [void][IO.Directory]::CreateDirectory((Split-Path ([IO.Path]::GetFullPath($Path)) -Parent))
        if ((Test-Path -LiteralPath $Path) -and -not (Test-Path -LiteralPath "$Path.systemcmd-before")) { Copy-Item -LiteralPath $Path -Destination "$Path.systemcmd-before" }
        [IO.File]::WriteAllText($Path, $updated, [Text.UTF8Encoding]::new($false))
    }
}

if ($Uninstall -or $Rollback) {
    if (-not (Test-Path -LiteralPath $marker)) { throw 'Destination is not a managed SYSTEMCMD core installation.' }
    # Only explicitly marked install directories may be removed/moved.
    if ($Destination -eq [IO.Path]::GetPathRoot($Destination) -or $Destination -eq $HOME -or $Destination -eq $source) { throw 'Unsafe installation destination.' }
    if ($Rollback) {
        if (-not (Test-Path -LiteralPath (Join-Path $backup '.systemcmd-core-install'))) { throw 'No previous version to restore.' }
        Remove-Item -LiteralPath $Destination -Recurse -Force
        Move-Item -LiteralPath $backup -Destination $Destination
    } else {
        foreach ($path in @($ProfilePath,$BashProfile,$ZshProfile)) { Set-CoreProfileBlock -Path $path -Remove }
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    return
}
if (Test-Path -LiteralPath $Destination) {
    if (-not (Test-Path -LiteralPath $marker)) { throw 'Refusing to overwrite an unmanaged directory.' }
    if (Test-Path -LiteralPath $backup) {
        if (-not (Test-Path -LiteralPath (Join-Path $backup '.systemcmd-core-install'))) { throw 'Unmanaged backup directory.' }
        Remove-Item -LiteralPath $backup -Recurse -Force
    }
    Move-Item -LiteralPath $Destination -Destination $backup
}
try {
    [void][IO.Directory]::CreateDirectory($Destination)
    foreach ($name in @('src','shell','scripts')) { Copy-Item -LiteralPath (Join-Path $source $name) -Destination (Join-Path $Destination $name) -Recurse }
    [IO.File]::WriteAllText($marker, 'SYSTEMCMD portable core v1')
    $modulePath = (Join-Path $Destination 'src/SystemCmd/SystemCmd.psd1').Replace("'", "''")
    Set-CoreProfileBlock -Path $ProfilePath -Body "Import-Module '$modulePath'"
    $shellPath = $Destination.Replace("'", "'\''")
    Set-CoreProfileBlock -Path $BashProfile -Body ". '$shellPath/shell/systemcmd.sh'"
    Set-CoreProfileBlock -Path $ZshProfile -Body ". '$shellPath/shell/systemcmd.zsh'"
} catch {
    if ((Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $marker)) {
        if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Recurse -Force }
        Move-Item -LiteralPath $backup -Destination $Destination
    }
    throw
}
