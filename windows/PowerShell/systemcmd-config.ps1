# ── Config yolları ────────────────────────────────────────────────────────────
$script:SystemCmdConfigDir  = Join-Path $HOME '.systemcmd'
$script:SystemCmdConfigPath = Join-Path $script:SystemCmdConfigDir 'config.json'

# ── Varsayılan değerler ───────────────────────────────────────────────────────
function Get-SystemCmdConfigDefaults {
    return [PSCustomObject]@{
        welcome  = [PSCustomObject]@{
            enabled = $true
        }
        spinner  = [PSCustomObject]@{
            enabled = $true
            speed   = 55
        }
        dashboard = [PSCustomObject]@{
            refreshMs = 2000
        }
        run      = [PSCustomObject]@{
            autoDetect = $true
        }
    }
}

# ── Derin birleştirme yardımcısı ──────────────────────────────────────────────
function Merge-SystemCmdConfigObject {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Base,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Override
    )

    $result = [PSCustomObject]@{}

    foreach ($prop in $Base.PSObject.Properties) {
        $result | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
    }

    foreach ($prop in $Override.PSObject.Properties) {
        $baseVal     = $result.PSObject.Properties[$prop.Name]
        $overrideVal = $prop.Value

        if ($baseVal -and $baseVal.Value -is [PSCustomObject] -and $overrideVal -is [PSCustomObject]) {
            $merged = Merge-SystemCmdConfigObject -Base $baseVal.Value -Override $overrideVal
            $result | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $merged -Force
        } else {
            $result | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $overrideVal -Force
        }
    }

    return $result
}

# ── Config yükle ──────────────────────────────────────────────────────────────
function Get-SystemCmdConfig {
    $defaults = Get-SystemCmdConfigDefaults

    if (-not (Test-Path -LiteralPath $script:SystemCmdConfigPath)) {
        return $defaults
    }

    try {
        $raw = Get-Content -LiteralPath $script:SystemCmdConfigPath -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $defaults
        }
        $loaded = $raw | ConvertFrom-Json -ErrorAction Stop
        return Merge-SystemCmdConfigObject -Base $defaults -Override $loaded
    } catch {
        return $defaults
    }
}

# ── Config kaydet ─────────────────────────────────────────────────────────────
function Set-SystemCmdConfig {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Values
    )

    if (-not (Test-Path -LiteralPath $script:SystemCmdConfigDir)) {
        try {
            New-Item -ItemType Directory -Path $script:SystemCmdConfigDir -Force | Out-Null
        } catch {
            Write-Host ("systemcmd config dizini olusturulamadi: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
            return
        }
    }

    $current = Get-SystemCmdConfig

    foreach ($key in $Values.Keys) {
        $parts = $key -split '\.'
        $node  = $current

        for ($i = 0; $i -lt $parts.Count - 1; $i++) {
            $part  = $parts[$i]
            $child = $node.PSObject.Properties[$part]
            if (-not $child) {
                $node | Add-Member -NotePropertyName $part -NotePropertyValue ([PSCustomObject]@{}) -Force
            }
            $node = $node.PSObject.Properties[$part].Value
        }

        $lastKey = $parts[-1]
        $node | Add-Member -NotePropertyName $lastKey -NotePropertyValue $Values[$key] -Force
    }

    try {
        $json = $current | ConvertTo-Json -Depth 10 -ErrorAction Stop
        Set-Content -LiteralPath $script:SystemCmdConfigPath -Value $json -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host ("systemcmd config kaydedilemedi: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    }
}

# ── Config göster ─────────────────────────────────────────────────────────────
function Show-SystemCmdConfig {
    $config = Get-SystemCmdConfig

    Write-Host ''
    Write-Host "`e[38;5;141m⚙ systemcmd config`e[0m"
    Write-Host ''

    function Write-SystemCmdConfigNode {
        param(
            [Parameter(Mandatory = $true)]
            [PSCustomObject]$Node,

            [string]$Prefix = ''
        )

        foreach ($prop in $Node.PSObject.Properties) {
            $fullKey = if ($Prefix) { '{0}.{1}' -f $Prefix, $prop.Name } else { $prop.Name }

            if ($prop.Value -is [PSCustomObject]) {
                Write-SystemCmdConfigNode -Node $prop.Value -Prefix $fullKey
            } else {
                Write-Host "  `e[38;5;117m$fullKey`e[0m" -NoNewline
                Write-Host " = " -NoNewline
                Write-Host "`e[38;5;245m$($prop.Value)`e[0m"
            }
        }
    }

    Write-SystemCmdConfigNode -Node $config
    Write-Host ''
    Write-Host "  `e[38;5;244m$script:SystemCmdConfigPath`e[0m"
    Write-Host ''
}
