param(
    [Parameter(Mandatory = $true)]
    [string]$RootPath,

    [switch]$Shallow
)

if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
    exit 0
}

$resolvedRoot = (Resolve-Path -LiteralPath $RootPath).ProviderPath

if ($Shallow) {
    try {
        [System.IO.Directory]::EnumerateDirectories($resolvedRoot)
        [System.IO.Directory]::EnumerateFiles($resolvedRoot)
    } catch {
        Get-ChildItem -LiteralPath $resolvedRoot -Force -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName
    }
    exit 0
}

if (Get-Command -Name fd -ErrorAction SilentlyContinue) {
    & fd --hidden --follow --absolute-path . $resolvedRoot 2>$null
    exit $LASTEXITCODE
}

if (Get-Command -Name rg -ErrorAction SilentlyContinue) {
    Push-Location $resolvedRoot
    try {
        rg --files --hidden --follow --glob '!**/.git/**' 2>$null | ForEach-Object {
            Join-Path $resolvedRoot $_
        }
    } finally {
        Pop-Location
    }

    exit 0
}

Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Force -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName
