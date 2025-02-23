chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# fzf kontrolü
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Write-Host "fzf bulunamadı. Lütfen fzf'yi yükleyin." -ForegroundColor Red
    exit
}

# Reg dosyasını oluşturup import eden fonksiyon (obfuscation)
function qX {
    param(
        [string]$α,
        [string]$β
    )
    $γ = Join-Path $env:TEMP $β
    $α | Out-File -Encoding Unicode -FilePath $γ
    Start-Process reg.exe -ArgumentList "import `"$γ`"" -Verb RunAs -Wait
    Remove-Item $γ -Force
}

# fA: "Sahipliği Al" eklemesi – CLSID hack de ekleniyor
function fA {
    $a1 = "Windows Registry Editor Version 5.00`r`n`r`n"
    $h = "[HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}]`r`n" + '@=""' + "`r`n" + "[HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]`r`n" + '@=""' + "`r`n`r`n"
    $s2 = "[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]`r`n"
    $s3 = '@="Sahipliği al..."' + "`r`n"
    $s4 = '"HasLUAShield"=""' + "`r`n"
    $s5 = '"NoWorkingDirectory"=""' + "`r`n"
    $s6 = '"Position"="middle"' + "`r`n`r`n"
    $s7 = "[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]`r`n"
    $s8 = '@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList ''/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /c /l & pause'' -Verb runAs\""' + "`r`n"
    $s9 = '"IsolatedCommand"= "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList ''/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /c /l & pause'' -Verb runAs\""' + "`r`n`r`n"
    $s10 = "[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]`r`n"
    $s11 = '@="Sahipliği al..."' + "`r`n"
    $s12 = '"AppliesTo"="NOT (System.ItemPathDisplay:=\"C:\\Users\" OR System.ItemPathDisplay:=\"C:\\ProgramData\" OR System.ItemPathDisplay:=\"C:\\Windows\" OR System.ItemPathDisplay:=\"C:\\Windows\\System32\" OR System.ItemPathDisplay:=\"C:\\Program Files\" OR System.ItemPathDisplay:=\"C:\\Program Files (x86)\")"' + "`r`n"
    $s13 = '"HasLUAShield"=""' + "`r`n"
    $s14 = '"NoWorkingDirectory"=""' + "`r`n"
    $s15 = '"Position"="middle"' + "`r`n`r`n"
    $s16 = "[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership\command]`r`n"
    $s17 = '@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList ''/c takeown /f \\\"%1\\\" /r /d y && icacls \\\"%1\\\" /grant *S-1-3-4:F /c /l /q & pause'' -Verb runAs\""' + "`r`n"
    $s18 = '"IsolatedCommand"="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList ''/c takeown /f \\\"%1\\\" /r /d y && icacls \\\"%1\\\" /grant *S-1-3-4:F /c /l /q & pause'' -Verb runAs\""'
    return ($a1 + $h + $s2 + $s3 + $s4 + $s5 + $s6 + $s7 + $s8 + $s9 + $s10 + $s11 + $s12 + $s13 + $s14 + $s15 + $s16 + $s17 + $s18)
}

# fB: "Sahipliği Al Kaldır" için reg içeriğini döndürür
function fB {
    $b1 = "Windows Registry Editor Version 5.00`r`n`r`n"
    $b2 = "; Eski kodu silmek için`r`n"
    $b3 = "[-HKEY_CLASSES_ROOT\*\shell\runas]`r`n`r`n"
    $b4 = "[-HKEY_CLASSES_ROOT\Directory\shell\runas]`r`n`r`n"
    $b5 = "[-HKEY_CLASSES_ROOT\dllfile\shell\runas]`r`n`r`n"
    $b6 = "; Yeni kodu silmek için`r`n"
    $b7 = "[-HKEY_CLASSES_ROOT\*\shell\TakeOwnership]`r`n"
    $b8 = "[-HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]"
    return ($b1 + $b2 + $b3 + $b4 + $b5 + $b6 + $b7 + $b8)
}

# adminhck: fzf menüsüyle yukarıdaki seçenekleri uygular. CLI’de "adminhck" yazıldığında çalışır.
function adminhck {
    chcp 65001 | Out-Null
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $opts = @("Sahipliği Al", "Sahipliği Al Kaldır")
    $sel = ($opts | fzf --prompt "Lütfen bir seçenek seçin: " | Out-String).Trim()
    Write-Host "Seçilen: $sel"
    if ($sel -like "*Al Kaldır*") {
         $ψ = fB
         qX $ψ "AdminHckTakeOwnershipKaldir.reg"
         Write-Host "Sağ tuş sahipliği kaldırma işlemi uygulandı." -ForegroundColor Green
    } elseif ($sel -like "*Al*") {
         $ψ = fA
         qX $ψ "AdminHckTakeOwnership.reg"
         Write-Host "Sağ tuş sahipliği alma işlemi uygulandı." -ForegroundColor Green
    } else {
         Write-Host "Bilinmeyen seçim: $sel"
    }
}
