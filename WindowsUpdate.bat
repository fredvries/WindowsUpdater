@echo off
title Windows Update Automation
color 0A

:: -------------------------------------------------
:: WindowUpdater 1.1
:: Run this file as Administrator
:: -------------------------------------------------

echo ==========================================
echo     WindowsUpdater 1.1
echo ==========================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator.
    pause
    exit /b
)

echo [1/6] Starting Windows Update services...

net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1

echo Done.
echo.

:: Install PSWindowsUpdate module if missing
echo [2/6] Checking PowerShell Windows Update module...

powershell -Command ^
"if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { ^
    Install-PackageProvider -Name NuGet -Force; ^
    Install-Module PSWindowsUpdate -Force -Confirm:$false -Scope CurrentUser ^
}"

echo Done.
echo.

:: Windows Updates
echo [3/6] Searching and installing Windows Updates...
echo This may take a while.
echo.

powershell -Command ^
"Import-Module PSWindowsUpdate; ^
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose"

echo.
echo Windows Updates completed.
echo.

:: Driver Updates
echo [4/6] Searching and installing Driver Updates...
echo This may take a while (drivers from Microsoft Update).
echo.

powershell -Command ^
"Import-Module PSWindowsUpdate; ^
Get-WUDriver -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot -Verbose"

echo.
echo Driver Updates completed.
echo.

:: Post-update cleanup (optional but recommended)
echo [5/6] Performing cleanup...
echo.

powershell -Command "Get-WUHistory | Select-Object -Last 10 | Format-Table" >nul 2>&1

echo Done.
echo.

:: Ask user about reboot
echo [6/6] Update process finished.
echo.
choice /M "Do you want to reboot now (recommended)"

if errorlevel 2 goto END
if errorlevel 1 goto REBOOT

:REBOOT
echo.
echo Rebooting system in 15 seconds...
shutdown /r /t 15
goto EOF

:END
echo.
echo Reboot skipped. Remember to reboot later for changes to take effect.
pause

:EOF
exit
