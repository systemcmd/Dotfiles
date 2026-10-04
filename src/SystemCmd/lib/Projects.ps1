# SystemCmd.Projects — fast project-type detection (cached) and a HUD panel.

$script:SystemCmdProjectCache = @{}

function Test-SystemCmdPathHas {
    param([string]$Root, [string[]]$Names)
    foreach ($n in $Names) { if (Test-Path -LiteralPath (Join-Path $Root $n)) { return $true } }
    return $false
}

<#
.SYNOPSIS
Detect project kinds from marker files only (no process spawns) so it stays fast
enough to run on every prompt / cd. Results are cached per directory for 3s.
#>
function Get-SystemCmdProject {
    param([string]$Path = $PWD.Path)
    $key = $Path
    $now = Get-Date
    if ($script:SystemCmdProjectCache.ContainsKey($key)) {
        $cached = $script:SystemCmdProjectCache[$key]
        if (($now - $cached.Time).TotalMilliseconds -lt 3000) { return $cached.Info }
    }

    $root = $Path
    $gitRoot = Get-SystemCmdGitRoot -Path $Path
    if ($gitRoot) { $root = $gitRoot }

    $kinds = New-Object System.Collections.Generic.List[string]
    if ($gitRoot) { $kinds.Add('git') }
    if (Test-SystemCmdPathHas $Path @('package.json')) {
        $kinds.Add('node')
        if (Test-SystemCmdPathHas $Path @('pnpm-lock.yaml')) { $kinds.Add('pnpm') }
        elseif (Test-SystemCmdPathHas $Path @('bun.lockb', 'bun.lock')) { $kinds.Add('bun') }
        elseif (Test-SystemCmdPathHas $Path @('yarn.lock')) { $kinds.Add('yarn') }
        if (Test-SystemCmdPathHas $Path @('src-tauri/tauri.conf.json')) { $kinds.Add('tauri') }
    }
    if (Test-SystemCmdPathHas $Path @('Cargo.toml')) { $kinds.Add('rust') }
    if (Test-SystemCmdPathHas $Path @('pyproject.toml', 'requirements.txt', 'setup.py')) { $kinds.Add('python') }
    if (Test-SystemCmdPathHas $Path @('go.mod')) { $kinds.Add('go') }
    if (Test-SystemCmdPathHas $Path @('pubspec.yaml')) { $kinds.Add('flutter') }
    if (Test-SystemCmdPathHas $Path @('Dockerfile')) { $kinds.Add('docker') }
    if (Test-SystemCmdPathHas $Path @('docker-compose.yml', 'compose.yaml', 'compose.yml')) { $kinds.Add('compose') }
    if (Get-ChildItem -LiteralPath $Path -Filter '*.csproj' -ErrorAction SilentlyContinue | Select-Object -First 1) { $kinds.Add('dotnet') }

    $info = [pscustomobject]@{
        Root  = $root
        Name  = Split-Path -Leaf $root
        Kinds = $kinds.ToArray()
    }
    $script:SystemCmdProjectCache[$key] = @{ Info = $info; Time = $now }
    return $info
}

function Get-SystemCmdRuntimeVersion {
    param([string]$Command, [string[]]$VersionArgs = @('--version'))
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) { return $null }
    try { return (& $Command @VersionArgs 2>$null | Select-Object -First 1) } catch { return $null }
}

function Show-SystemCmdProject {
    param([string]$Path = $PWD.Path)
    $proj = Get-SystemCmdProject -Path $Path
    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add((Format-SystemCmdRow -Label 'Type' -Value (($proj.Kinds -join ' · ') -replace '^$', 'plain')))

    if ($proj.Kinds -contains 'git') {
        $status = Get-SystemCmdGitStatus -Path $Path
        if ($status) {
            $rows.Add((Format-SystemCmdRow -Label 'Git' -Value $status.Branch))
            $rows.Add((Format-SystemCmdRow -Label 'Changes' -Value "$($status.FileCount)  (+$($status.Insertions) -$($status.Deletions))"))
        }
    }
    $runtime = New-Object System.Collections.Generic.List[string]
    if ($proj.Kinds -contains 'node') { $v = Get-SystemCmdRuntimeVersion 'node'; if ($v) { $runtime.Add("Node $v") } }
    if ($proj.Kinds -contains 'python') { $v = Get-SystemCmdRuntimeVersion 'python'; if (-not $v) { $v = Get-SystemCmdRuntimeVersion 'python3' }; if ($v) { $runtime.Add(($v -replace 'Python ', 'Python ')) } }
    if ($proj.Kinds -contains 'rust') { $v = Get-SystemCmdRuntimeVersion 'rustc'; if ($v) { $runtime.Add(($v -split ' ')[0..1] -join ' ') } }
    if ($proj.Kinds -contains 'go') { $v = Get-SystemCmdRuntimeVersion 'go' @('version'); if ($v) { $runtime.Add((($v -replace 'go version ', '') -split ' ')[0]) } }
    if ($runtime.Count) { $rows.Add((Format-SystemCmdRow -Label 'Runtime' -Value ($runtime -join ' · '))) }

    Show-SystemCmdPanel -Title $proj.Name -Lines $rows.ToArray()
}
