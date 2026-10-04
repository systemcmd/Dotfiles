# SystemCmd.Brain — interface to systemcmd-brain. Lazy and non-blocking by design:
# it must never slow terminal startup or the prompt. When no brain is configured or
# reachable, everything degrades cleanly to "offline".

$script:SystemCmdBrainCache = @{}
$script:SystemCmdBrainLabel = 'offline'

function Get-SystemCmdBrainConfig {
    $cfg = try { Get-SystemCmdConfig } catch { $null }
    if ($cfg -and $cfg.PSObject.Properties['brain']) { return $cfg.brain }
    if ($env:SYSTEMCMD_BRAIN_URL) { return [pscustomobject]@{ endpoint = $env:SYSTEMCMD_BRAIN_URL } }
    return $null
}

function Test-SystemCmdBrainAvailable {
    $cfg = Get-SystemCmdBrainConfig
    return [bool]($cfg -and $cfg.PSObject.Properties['endpoint'] -and $cfg.endpoint)
}

function Get-SystemCmdBrainStateLabel {
    if ($script:SystemCmdBrainLabel -eq 'ONLINE') { return 'ONLINE (cached)' }
    if (Test-SystemCmdBrainAvailable) { return 'configured (lazy)' }
    return 'offline'
}

<#
.SYNOPSIS
Fetch project context from the brain asynchronously so `cd`/prompt never block.
Returns a runspace job handle; callers poll or ignore it. Offline -> $null.
#>
function Start-SystemCmdBrainContext {
    param([string]$Project)
    if (-not (Test-SystemCmdBrainAvailable)) { return $null }
    $cfg = Get-SystemCmdBrainConfig
    return (Start-ThreadJob -ScriptBlock {
            param($endpoint, $project)
            try { Invoke-RestMethod -Uri ($endpoint.TrimEnd('/') + '/project/' + [uri]::EscapeDataString($project)) -TimeoutSec 4 } catch { $null }
        } -ArgumentList $cfg.endpoint, $Project -ErrorAction SilentlyContinue)
}

function Show-SystemCmdBrain {
    param([string]$Path = $PWD.Path)
    $proj = Get-SystemCmdProject -Path $Path
    if (-not (Test-SystemCmdBrainAvailable)) {
        Show-SystemCmdPanel -Title "Brain · $($proj.Name)" -Lines @(
            (Format-SystemCmdText -Text 'Brain baglantisi yok (offline).' -Role 'dim'),
            (Format-SystemCmdText -Text 'Ayar: config.json > brain.endpoint veya $env:SYSTEMCMD_BRAIN_URL' -Role 'muted')
        )
        return
    }
    $key = (Get-SystemCmdBrainConfig).endpoint + '|' + $proj.Root
    $data = $null
    if ($script:SystemCmdBrainCache.ContainsKey($key) -and $script:SystemCmdBrainCache[$key].Until -gt [DateTime]::UtcNow) {
        $data = $script:SystemCmdBrainCache[$key].Data
    } else {
        $job = Start-SystemCmdBrainContext -Project $proj.Name
        try { $data = if ($job) { $job | Wait-Job -Timeout 5 | Receive-Job } else { $null } }
        finally { if ($job) { $job | Stop-Job -ErrorAction SilentlyContinue; $job | Remove-Job -Force -ErrorAction SilentlyContinue } }
        $script:SystemCmdBrainCache[$key] = @{ Until = [DateTime]::UtcNow.AddSeconds(30); Data = $data }
    }
    $script:SystemCmdBrainLabel = if ($data) { 'ONLINE' } else { 'OFFLINE' }
    Update-SystemCmdLiveState -Mode BRAIN -Data @{ Title = "Brain | $($proj.Name)"; Lines = @($script:SystemCmdBrainLabel, $(if ($data) { $data | ConvertTo-Json -Depth 5 } else { 'No context available.' })) }
    if (-not $data) {
        Show-SystemCmdPanel -Title "Brain · $($proj.Name)" -Lines @((Format-SystemCmdText -Text 'Context alinamadi (zaman asimi).' -Role 'warn'))
        return
    }
    $rows = New-Object System.Collections.Generic.List[string]
    foreach ($section in @('decision', 'errors', 'todo', 'deployment')) {
        if ($data.PSObject.Properties[$section]) { $rows.Add((Format-SystemCmdRow -Label $section -Value ([string]$data.$section))) }
    }
    Show-SystemCmdPanel -Title "Brain · $($proj.Name)" -Lines $rows.ToArray()
}
