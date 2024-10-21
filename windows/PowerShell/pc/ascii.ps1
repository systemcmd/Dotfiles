function ConvertTo-Ascii {
    param([string]$InputText)
    $asciiValues = @()
    foreach ($char in $InputText.ToCharArray()) {
        $asciiValues += [int][char]$char
    }
    return $asciiValues -join ' '
}

function Reverse-Ascii {
    param([string]$InputText)
    $charArray = $InputText.ToCharArray()
    [Array]::Reverse($charArray)
    $reversedText = [string]::Join("", $charArray)
    return ConvertTo-Ascii -InputText $reversedText
}

function Increase-Ascii {
    param([string]$InputText, [int]$Increment = 3)
    $asciiValues = @()
    foreach ($char in $InputText.ToCharArray()) {
        $asciiValues += [int][char]$char + $Increment
    }
    return $asciiValues -join ' '
}

function AsciiTo-Text {
    param([string]$AsciiValues)
    $textChars = $AsciiValues -split ' ' | ForEach-Object { [char][int]$_ }
    return [string]::Join("", $textChars)
}

function Show-AsciiAlphabet {
    $alphabetUpper = 65..90 | ForEach-Object { "$([char]$_) : $_" }
    $alphabetLower = 97..122 | ForEach-Object { "$([char]$_) : $_" }
    return $alphabetUpper + $alphabetLower -join "`n"
}

function Display-AsciiRepresentation {
    param([string]$InputText)
    $asciiPairs = @()
    foreach ($char in $InputText.ToCharArray()) {
        $asciiPairs += "$char : " + [int][char]$char
    }
    return $asciiPairs -join ', '
}

function Show-Menu {
    Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "| ASCII Şifreleme ve Deşifreleme Menüsü:                     |" -ForegroundColor Cyan
    Write-Host "| 1: Doğrudan ASCII'ye Çevir                                 |" -ForegroundColor DarkGray
    Write-Host "| 2: Ters ve ASCII'ye Çevir                                  |" -ForegroundColor DarkGray
    Write-Host "| 3: ASCII Değerlerini Artır                                 |" -ForegroundColor DarkGray
    Write-Host "| 4: ASCII'den Metne Çevir                                   |" -ForegroundColor DarkGray
    Write-Host "| 5: ASCII Alfabe Listesi                                    |" -ForegroundColor DarkGray
    Write-Host "| 6: ASCII Görünümü                                          |" -ForegroundColor DarkGray
    Write-Host "|                                                            |" -ForegroundColor DarkGray
    Write-Host "| Çıkmak için 'exit' yazın.                                  |" -ForegroundColor Yellow
    Write-Host "|                                                            |" -ForegroundColor DarkGray
    Write-Host "| ASCII, bilgisayar bilimlerinde kullanılan bir karakter     |" -ForegroundColor DarkGray
    Write-Host "| kodlama standartıdır. Her bir karakter, sayılardan oluşan  |" -ForegroundColor DarkGray
    Write-Host "| benzersiz bir sayı ile ifade edilir.                       |" -ForegroundColor DarkGray
    Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host "Lütfen bir seçenek seçin:" -ForegroundColor Cyan
}

function Invoke-AsciiMenu {
    while ($true) {
        Show-Menu
        $choice = Read-Host "Seçiminiz"
        if ($choice -eq "exit") {
            break
        }
        switch ($choice) {
            '1' {
                $InputText = Read-Host "Metni girin"
                Write-Host "ASCII Değerleri: $(ConvertTo-Ascii -InputText $InputText)"
            }
            '2' {
                $InputText = Read-Host "Metni girin"
                Write-Host "Ters Çevrilmiş ASCII Değerleri: $(Reverse-Ascii -InputText $InputText)"
            }
            '3' {
                $InputText = Read-Host "Metni girin"
                Write-Host "Artırılmış ASCII Değerleri: $(Increase-Ascii -InputText $InputText)"
            }
            '4' {
                $asciiInput = Read-Host "ASCII değerlerini girin (örnek: 65 66 67)"
                Write-Host "Metin: $(AsciiTo-Text -AsciiValues $asciiInput)"
            }
            '5' {
                Write-Host "ASCII Alfabe Listesi:"
                Write-Host (Show-AsciiAlphabet)
            }
            '6' {
                $InputText = Read-Host "Kelimeyi girin"
                Write-Host "ASCII Görünümü: $(Display-AsciiRepresentation -InputText $InputText)"
            }
            default {
                Write-Host "Geçersiz seçenek seçildi." -ForegroundColor Red
            }
        }
    }
}
Set-Alias ascii Invoke-AsciiMenu
