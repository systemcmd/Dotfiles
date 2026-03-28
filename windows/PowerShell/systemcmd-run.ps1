# ── Proje koşturucu — oto-algılama ────────────────────────────────────────────

function Get-SystemCmdRunTarget {
    # Döndürür: @{ Label; Command; Args }  ya da $null

    $cwd = $PWD.Path

    # Node — package.json
    $pkgJson = Join-Path $cwd 'package.json'
    if (Test-Path -LiteralPath $pkgJson) {
        try {
            $pkg = Get-Content $pkgJson -Raw | ConvertFrom-Json -ErrorAction Stop
            if ($pkg.scripts.dev) {
                return @{ Label = 'npm run dev'; Command = 'npm'; Args = @('run', 'dev') }
            }
            if ($pkg.scripts.start) {
                return @{ Label = 'npm start'; Command = 'npm'; Args = @('start') }
            }
        } catch {}
        return @{ Label = 'npm install'; Command = 'npm'; Args = @('install') }
    }

    # Rust — Cargo.toml
    if (Test-Path -LiteralPath (Join-Path $cwd 'Cargo.toml')) {
        return @{ Label = 'cargo run'; Command = 'cargo'; Args = @('run') }
    }

    # Go — go.mod
    if (Test-Path -LiteralPath (Join-Path $cwd 'go.mod')) {
        return @{ Label = 'go run .'; Command = 'go'; Args = @('run', '.') }
    }

    # Python — pyproject.toml veya main.py
    if (Test-Path -LiteralPath (Join-Path $cwd 'pyproject.toml')) {
        if (Get-Command -Name uv -ErrorAction SilentlyContinue) {
            return @{ Label = 'uv run'; Command = 'uv'; Args = @('run') }
        }
        if (Get-Command -Name poetry -ErrorAction SilentlyContinue) {
            return @{ Label = 'poetry run python main.py'; Command = 'poetry'; Args = @('run', 'python', 'main.py') }
        }
    }

    $mainPy = Join-Path $cwd 'main.py'
    if (Test-Path -LiteralPath $mainPy) {
        $python = if (Get-Command -Name python3 -ErrorAction SilentlyContinue) { 'python3' } else { 'python' }
        return @{ Label = "$python main.py"; Command = $python; Args = @('main.py') }
    }

    # Makefile
    if (Test-Path -LiteralPath (Join-Path $cwd 'Makefile')) {
        return @{ Label = 'make'; Command = 'make'; Args = @() }
    }

    # Docker Compose
    $composeFile = @('docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml') |
        Where-Object { Test-Path -LiteralPath (Join-Path $cwd $_) } |
        Select-Object -First 1
    if ($composeFile) {
        return @{ Label = 'docker compose up'; Command = 'docker'; Args = @('compose', 'up') }
    }

    # .NET
    $csproj = @(Get-ChildItem -LiteralPath $cwd -Filter '*.csproj' -ErrorAction SilentlyContinue)
    if ($csproj.Count -gt 0) {
        return @{ Label = 'dotnet run'; Command = 'dotnet'; Args = @('run') }
    }

    return $null
}

function Invoke-SystemCmdRun {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$ExtraArgs
    )

    $target = Get-SystemCmdRunTarget

    if (-not $target) {
        Write-Host "`e[38;5;214m⚠ Tanınan proje dosyası bulunamadı.`e[0m"
        Write-Host "`e[38;5;244m  (package.json, Cargo.toml, go.mod, main.py, Makefile, docker-compose, .csproj)`e[0m"
        return
    }

    if (-not (Get-Command -Name $target.Command -ErrorAction SilentlyContinue)) {
        Write-Host ("`e[38;5;167m✗ '{0}' komutu bulunamadi.`e[0m" -f $target.Command)
        return
    }

    Write-Host ("`e[38;5;85m▶ {0}`e[0m" -f $target.Label)

    $allArgs = $target.Args + $ExtraArgs
    if ($allArgs.Count -gt 0) {
        & $target.Command @allArgs
    } else {
        & $target.Command
    }
}

Set-Alias -Name run -Value Invoke-SystemCmdRun -Option AllScope -Scope Global -Force
