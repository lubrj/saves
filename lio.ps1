if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "iwr https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/lio.ps1 -UseBasicParsing | iex" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("now you are a real hacker")
for ($i = 1; $i -le 3; $i++) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "while ($true) { dir /s; Start-Sleep -Seconds 1 }"
}
