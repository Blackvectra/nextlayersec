@echo off
setlocal EnableDelayedExpansion
title NEXTLAYERSEC - CLEANUP TOOL v1.4

:: ----------------------------
:: USER CONFIGURATION
:: ----------------------------
set "SYS=C:"
set "ENABLE_PAGEFILE_CLEAR=1"
set "ENABLE_FORCED_REBOOT=1"
set "REBOOT_DELAY_SECONDS=1800"
set "LOGDIR=%SystemDrive%\MaintenanceLogs"

:: ----------------------------
:: INITIALIZE
:: ----------------------------
set "ERRORS=0"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set "d=%%c-%%a-%%b"
for /f "tokens=1-2 delims=:." %%a in ("%time%") do set "t=%%a-%%b"
set "REPORT=%LOGDIR%\cleanup_report_%d%_%t%.txt"

cls
echo ##############################################################
echo #   NEXTLAYERSEC - CLIENT DISK CLEANUP + REPAIR v1.4         #
echo ##############################################################
echo.
echo Run as Administrator. Press any key to begin...
pause >nul

net session >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Not running as Administrator!
    echo Press any key to continue anyway...
    pause >nul
)

:: ----------------------------
:: GET INITIAL FREE SPACE
:: ----------------------------
for /f "tokens=3" %%a in ('fsutil volume diskfree %SYS% ^| find "of free bytes"') do set "FREE_BEFORE=%%a"

:: ----------------------------
:: CLEANUP STEPS
:: ----------------------------
echo [1] Cleaning TEMP folders...
del /q /f "%TEMP%\*.*" >nul 2>&1
del /q /f "%SystemRoot%\Temp\*.*" >nul 2>&1

echo [2] Emptying Recycle Bin...
rd /s /q %SYS%\$Recycle.Bin >nul 2>&1

echo [3] Cleaning Windows Update Cache...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\Download >nul 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\DeliveryOptimization >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [4] Cleaning Prefetch...
del /q /f %SystemRoot%\Prefetch\*.* >nul 2>&1

echo [5] Cleaning Logs...
del /q /s /f %SystemRoot%\Logs\*.* >nul 2>&1
del /q /s /f %SystemRoot%\Logs\CBS\*.* >nul 2>&1

echo [6] Cleaning Crash Dumps...
del /q /s /f C:\ProgramData\Microsoft\Windows\WER\*.* >nul 2>&1
del /q /s /f %SystemRoot%\Minidump\*.* >nul 2>&1
del /q /f %SystemRoot%\MEMORY.DMP >nul 2>&1

echo [7] Cleaning Defender History...
del /q /s /f "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*.*" >nul 2>&1

echo [8] Cleaning Browser Caches...
del /f /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
for /d %%P in ("%AppData%\Mozilla\Firefox\Profiles\*.default-release") do (
    del /f /s /q "%%P\cache2\entries\*" >nul 2>&1
)

echo [9] Running SFC...
sfc /scannow

echo [10] Running DISM RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth

echo [11] DISM Component Cleanup...
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

if "%ENABLE_PAGEFILE_CLEAR%"=="1" (
    echo [12] Enabling pagefile clear on shutdown...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f >nul 2>&1
)

:: ----------------------------
:: GET FINAL FREE SPACE
:: ----------------------------
for /f "tokens=3" %%a in ('fsutil volume diskfree %SYS% ^| find "of free bytes"') do set "FREE_AFTER=%%a"
set /a FREED=%FREE_AFTER% - %FREE_BEFORE%

:: ----------------------------
:: REPORT TO FILE
:: ----------------------------
(
  echo NEXTLAYERSEC - CLEANUP REPORT
  echo =============================
  echo DATE: %DATE%   TIME: %TIME%
  echo USER: %USERNAME%
  echo MACHINE: %COMPUTERNAME%
  echo.
  echo Free Before: %FREE_BEFORE% bytes
  echo Free After : %FREE_AFTER% bytes
  echo Freed      : %FREED% bytes
  if "%ENABLE_PAGEFILE_CLEAR%"=="1" (
    echo Pagefile clear enabled at shutdown.
  )
  if "%ENABLE_FORCED_REBOOT%"=="1" (
    echo Forced reboot scheduled in %REBOOT_DELAY_SECONDS% seconds.
  )
) > "%REPORT%"

echo.
echo Cleanup Complete. Report saved to:
echo %REPORT%

:: ----------------------------
:: SCHEDULE FORCED REBOOT
:: ----------------------------
if "%ENABLE_FORCED_REBOOT%"=="1" (
    echo.
    echo Restarting in %REBOOT_DELAY_SECONDS% seconds (cannot cancel)...
    shutdown /r /f /t %REBOOT_DELAY_SECONDS% /c "NEXTLAYERSEC: Rebooting after cleanup"
)

:: ----------------------------
:: OPEN SYSTEM RESTORE UI
:: ----------------------------
start "" control sysdm.cpl,,3

:: ----------------------------
:: KEEP SHELL OPEN
:: ----------------------------
echo.
echo You may type 'exit' or run additional commands.
cmd /k
endlocal
