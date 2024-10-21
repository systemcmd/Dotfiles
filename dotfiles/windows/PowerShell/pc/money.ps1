function Para {
    param(
        [Parameter(Mandatory=$true)]
        [float]$Miktar
    )

    $urlUSD = "https://api.exchangerate-api.com/v4/latest/USD"
    $urlEUR = "https://api.exchangerate-api.com/v4/latest/EUR"

    try {
        $responseUSD = Invoke-RestMethod -Uri $urlUSD
        $kurUSD = $responseUSD.rates.TRY
        $donusturulmusMiktarUSD = $Miktar * $kurUSD

        $responseEUR = Invoke-RestMethod -Uri $urlEUR
        $kurEUR = $responseEUR.rates.TRY
        $donusturulmusMiktarEUR = $Miktar * $kurEUR

        # Dolar ve Euro için düzeltilmiş çerçeveli çıktı
        Write-Host "┌─[ Dolar: $Miktar ]──────[ Euro: $Miktar ]───────────────────────┐" -ForegroundColor Red
        Write-Host "│ $Miktar$ Dolar, $donusturulmusMiktarUSD₺│" -ForegroundColor Cyan
        Write-Host "│ $Miktar£ Euro,  $donusturulmusMiktarEUR₺│" -ForegroundColor Cyan
    } catch {
        Write-Host "Döviz kuru bilgisi alınırken bir hata oluştu: $_" -ForegroundColor Red
    }
}
