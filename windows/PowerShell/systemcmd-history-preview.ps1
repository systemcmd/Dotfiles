$favoritesPath = if (-not [string]::IsNullOrWhiteSpace($env:SYSTEMCMD_HISTORY_FAVORITES_PATH)) {
    $env:SYSTEMCMD_HISTORY_FAVORITES_PATH
} else {
    Join-Path $HOME '.systemcmd-history-favorites.json'
}

$favorites = @()

if (Test-Path -LiteralPath $favoritesPath) {
    try {
        $rawContent = Get-Content -LiteralPath $favoritesPath -Raw -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace($rawContent)) {
            $parsed = $rawContent | ConvertFrom-Json -ErrorAction Stop
            if ($parsed -is [string]) {
                $favorites = @($parsed)
            } else {
                $favorites = @($parsed | Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) })
            }
        }
    } catch {
        $favorites = @()
    }
}

Write-Host 'Favoriler' -ForegroundColor Yellow
Write-Host ('Toplam : {0}' -f $favorites.Count) -ForegroundColor DarkYellow
Write-Host ''

if ($favorites.Count -eq 0) {
    Write-Host 'Henuz favori yok.' -ForegroundColor DarkGray
    exit 0
}

$index = 1
foreach ($favorite in $favorites) {
    $singleLine = ($favorite -replace "\r?\n", ' <nl> ' -replace "`t", ' ').Trim()
    if ($singleLine.Length -gt 140) {
        $singleLine = $singleLine.Substring(0, 140) + '...'
    }

    Write-Host ('[{0:D2}] {1}' -f $index, $singleLine) -ForegroundColor Yellow
    $index++
}
