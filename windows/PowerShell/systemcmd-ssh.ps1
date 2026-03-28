$script:SystemCmdSshPath = Join-Path $HOME '.systemcmd' 'ssh.json'

function Get-SystemCmdSshConnections {
    try {
        if (-not (Test-Path -LiteralPath $script:SystemCmdSshPath)) {
            return @()
        }
        $raw = Get-Content -LiteralPath $script:SystemCmdSshPath -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($raw)) {
            return @()
        }
        $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
        return @($parsed)
    } catch {
        return @()
    }
}

function Save-SystemCmdSshConnections {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Connections
    )

    try {
        $dir = Split-Path -Parent $script:SystemCmdSshPath
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $Connections | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $script:SystemCmdSshPath -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host ("SSH kayit hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function Add-SystemCmdSshConn {
    try {
        $name = Read-Host 'Baglanti adi'
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-Host 'Ad bos birakilamaz.' -ForegroundColor Red
            return
        }

        $host_ = Read-Host 'Host (IP veya hostname)'
        if ([string]::IsNullOrWhiteSpace($host_)) {
            Write-Host 'Host bos birakilamaz.' -ForegroundColor Red
            return
        }

        $userDefault = $env:USERNAME
        $userInput   = Read-Host ("Kullanici adi [{0}]" -f $userDefault)
        $user        = if ([string]::IsNullOrWhiteSpace($userInput)) { $userDefault } else { $userInput }

        $portInput = Read-Host 'Port [22]'
        $port      = if ([string]::IsNullOrWhiteSpace($portInput)) { 22 } else { [int]$portInput }

        $key = Read-Host 'Anahtar dosyasi (bos birak = yok)'

        $conn = [PSCustomObject]@{
            Name     = $name
            Host     = $host_
            User     = $user
            Port     = $port
            Key      = $key.Trim()
            LastUsed = $null
        }

        $connections = @(Get-SystemCmdSshConnections) + $conn
        Save-SystemCmdSshConnections -Connections $connections
        Write-Host ("`e[38;5;85m✓ '{0}' baglantisi eklendi.`e[0m" -f $name)
    } catch {
        Write-Host ("Ekleme hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function ssh-mgr {
    try {
        $connections = @(Get-SystemCmdSshConnections)

        if ($connections.Count -eq 0) {
            Write-Host 'Kayitli SSH baglantisi yok. Yeni baglanti ekleyelim.' -ForegroundColor DarkGray
            Add-SystemCmdSshConn
            return
        }

        $items = for ($i = 0; $i -lt $connections.Count; $i++) {
            $c        = $connections[$i]
            $lastUsed = if ($c.LastUsed) { $c.LastUsed.ToString().Substring(0, 10) } else { 'hic' }
            $display  = (
                "`e[38;5;117m{0,-20}`e[0m `e[38;5;245m{1}@{2}:{3}`e[0m  `e[38;5;244m(son: {4})`e[0m" -f
                $c.Name, $c.User, $c.Host, $c.Port, $lastUsed
            )
            [string]::Join([char]9, @([string]$i, $display))
        }

        $selection = $items | & fzf `
            --delimiter "`t" `
            --with-nth 2 `
            --nth 2 `
            --prompt 'ssh > ' `
            --layout reverse `
            --border `
            --ansi `
            --expect 'ctrl-n,ctrl-d' `
            --color (Get-SystemCmdFzfColorOption)

        if ([string]::IsNullOrWhiteSpace($selection)) {
            return
        }

        $lines  = @($selection -split "`n" | Where-Object { $_ -ne '' })
        $key    = $lines[0].Trim()
        $chosen = if ($lines.Count -gt 1) { $lines[1] } else { '' }

        if ($key -eq 'ctrl-n') {
            Add-SystemCmdSshConn
            return
        }

        if ([string]::IsNullOrWhiteSpace($chosen)) {
            return
        }

        $idx = [int]($chosen -split "`t", 2)[0].Trim()
        $conn = $connections[$idx]

        if ($key -eq 'ctrl-d') {
            $confirm = Read-Host ("'{0}' baglantiyi sil? (e/H)" -f $conn.Name)
            if ($confirm -eq 'e' -or $confirm -eq 'E') {
                $updated = @($connections | Where-Object { $_.Name -ne $conn.Name })
                Save-SystemCmdSshConnections -Connections $updated
                Write-Host ("'{0}' silindi." -f $conn.Name) -ForegroundColor DarkGray
            }
            return
        }

        $connections[$idx].LastUsed = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Save-SystemCmdSshConnections -Connections $connections

        $sshArgs = @()
        $sshArgs += '-p'
        $sshArgs += [string]$conn.Port
        if (-not [string]::IsNullOrWhiteSpace($conn.Key)) {
            $sshArgs += '-i'
            $sshArgs += $conn.Key
        }
        $sshArgs += ('{0}@{1}' -f $conn.User, $conn.Host)

        Write-Host ("`e[38;5;117mBaglaniyor: {0}@{1}:{2}`e[0m" -f $conn.User, $conn.Host, $conn.Port)
        & ssh @sshArgs
    } catch {
        Write-Host ("SSH yoneticisi hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}
