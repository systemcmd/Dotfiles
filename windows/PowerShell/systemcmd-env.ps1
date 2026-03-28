$script:SystemCmdCurrentEnv  = $null
$script:SystemCmdCurrentEnvPath = $null

function Find-SystemCmdEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $fileName = '.env.' + $Name
    $dir      = $PWD.Path

    for ($level = 0; $level -le 3; $level++) {
        if ([string]::IsNullOrWhiteSpace($dir)) { break }
        $candidate = Join-Path $dir $fileName
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
        $parent = Split-Path -Parent $dir
        if ($parent -eq $dir) { break }
        $dir = $parent
    }

    return $null
}

function Read-SystemCmdEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $pairs = [System.Collections.Generic.List[object]]::new()

    try {
        $lines = Get-Content -LiteralPath $FilePath -Encoding UTF8 -ErrorAction Stop
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
            if ($trimmed.StartsWith('#')) { continue }
            $eqIdx = $trimmed.IndexOf('=')
            if ($eqIdx -lt 1) { continue }
            $k = $trimmed.Substring(0, $eqIdx).Trim()
            $v = $trimmed.Substring($eqIdx + 1).Trim()
            if ([string]::IsNullOrWhiteSpace($k)) { continue }
            $pairs.Add([PSCustomObject]@{ Key = $k; Value = $v })
        }
    } catch {
        Write-Host ("Ortam dosyasi okunamadi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    return $pairs.ToArray()
}

function env-switch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        $filePath = Find-SystemCmdEnvFile -Name $Name
        if (-not $filePath) {
            Write-Host ("`e[38;5;167m'.env.{0}' bulunamadi (mevcut dizin ve 3 ust dizin kontrol edildi).`e[0m" -f $Name)
            return
        }

        $pairs = Read-SystemCmdEnvFile -FilePath $filePath

        foreach ($pair in $pairs) {
            [System.Environment]::SetEnvironmentVariable($pair.Key, $pair.Value, 'Process')
        }

        $script:SystemCmdCurrentEnv     = $Name
        $script:SystemCmdCurrentEnvPath = $filePath

        Write-Host ("`e[38;5;85m✓ {0} ortami yuklendi ({1} degisken)`e[0m" -f $Name, $pairs.Count)

        if ($Name -match 'prod|production') {
            Write-Host "`e[38;5;167m⚠  PRODUCTION ORTAMI`e[0m"
            Start-Sleep -Seconds 1
        }
    } catch {
        Write-Host ("env-switch hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function env-show {
    try {
        if ([string]::IsNullOrWhiteSpace($script:SystemCmdCurrentEnv)) {
            Write-Host "`e[38;5;244m(ortam yuklenmedi)`e[0m"
            return
        }

        Write-Host ("`e[38;5;85mYuklenen ortam: {0}`e[0m" -f $script:SystemCmdCurrentEnv)

        if (-not [string]::IsNullOrWhiteSpace($script:SystemCmdCurrentEnvPath) -and
            (Test-Path -LiteralPath $script:SystemCmdCurrentEnvPath)) {
            $pairs = Read-SystemCmdEnvFile -FilePath $script:SystemCmdCurrentEnvPath
            Write-Host ''
            foreach ($pair in $pairs) {
                Write-Host -NoNewline ("`e[38;5;117m{0}`e[0m" -f $pair.Key)
                Write-Host ("`e[38;5;244m=`e[0m`e[38;5;245m{0}`e[0m" -f $pair.Value)
            }
        }
    } catch {
        Write-Host ("env-show hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function env-clear {
    try {
        if ([string]::IsNullOrWhiteSpace($script:SystemCmdCurrentEnv)) {
            Write-Host "`e[38;5;244m(temizlenecek ortam yok)`e[0m"
            return
        }

        if (-not [string]::IsNullOrWhiteSpace($script:SystemCmdCurrentEnvPath) -and
            (Test-Path -LiteralPath $script:SystemCmdCurrentEnvPath)) {
            $pairs = Read-SystemCmdEnvFile -FilePath $script:SystemCmdCurrentEnvPath
            foreach ($pair in $pairs) {
                [System.Environment]::SetEnvironmentVariable($pair.Key, $null, 'Process')
            }
        }

        $script:SystemCmdCurrentEnv     = $null
        $script:SystemCmdCurrentEnvPath = $null
        Write-Host "`e[38;5;85m✓ ortam temizlendi`e[0m"
    } catch {
        Write-Host ("env-clear hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function env-list {
    try {
        $dirs = [System.Collections.Generic.List[string]]::new()
        $dirs.Add($PWD.Path)

        $cur = $PWD.Path
        for ($level = 0; $level -lt 2; $level++) {
            $parent = Split-Path -Parent $cur
            if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $cur) { break }
            $dirs.Add($parent)
            $cur = $parent
        }

        $found = $false
        foreach ($dir in $dirs) {
            $files = @(Get-ChildItem -LiteralPath $dir -Filter '.env.*' -Force -ErrorAction SilentlyContinue)
            foreach ($file in $files) {
                $sizeKb = [Math]::Round($file.Length / 1KB, 1)
                Write-Host -NoNewline ("`e[38;5;117m{0}`e[0m" -f $file.FullName)
                Write-Host ("  `e[38;5;244m{0} KB`e[0m" -f $sizeKb)
                $found = $true
            }
        }

        if (-not $found) {
            Write-Host "`e[38;5;244m.env.* dosyasi bulunamadi.`e[0m"
        }
    } catch {
        Write-Host ("env-list hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}
