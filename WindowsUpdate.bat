@echo off
title Windows Updater 1.1
color 0A

:: ================================================
:: WindowsUpdater 1.1
:: Windows Updates + Drivers (Safe Built-in)
:: ================================================

echo ==========================================
echo     Windows Updater 1.1
echo ==========================================
echo.

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

echo [2/6] Enabling Microsoft Update (for drivers)...
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "BranchReadinessLevel" /t REG_DWORD /d 20 /f >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WUSetting -MicrosoftUpdate 1" >nul 2>&1

echo [3/6] Scanning for all updates...
wuauclt /resetauthorization /detectnow
timeout /t 10 >nul
usoclient ScanInstallWait
timeout /t 15 >nul

echo [4/6] Installing Windows Updates + Drivers...
usoclient StartInstall
echo.

echo [5/6] Waiting for installation to start...
timeout /t 20 >nul

echo [6/6] Checking if reboot is required...
timeout /t 8 >nul

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo [IMPORTANT] Reboot is required to complete updates and drivers.
    echo.
    choice /M "Reboot now"
    if errorlevel 1 shutdown /r /t 15
) else (
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations >nul 2>&1
    if %errorlevel% equ 0 (
        echo.
        echo [IMPORTANT] Reboot is required.
        echo.
        choice /M "Reboot now"
        if errorlevel 1 shutdown /r /t 15
    ) else (
        echo.
        echo No reboot required at this time.
        echo Updates and drivers will finish in the background.
    )
)

echo.
echo Process completed successfully.
echo You can check status in Settings - Windows Update.
pause
exit