if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("now you are a real hacker")
for ($i = 1; $i -le 3; $i++) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "while ($true) { dir /s; Start-Sleep -Seconds 1 }"
}
