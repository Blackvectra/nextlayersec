@echo off
setlocal EnableDelayedExpansion
title NEXTLAYERSEC - CLEANUP TOOL v1.3 (Aggressive Mode)

:: ----------------------------
:: CONFIGURATION
:: ----------------------------
set "SYS=C:"
set "ERRORS=0"
set "LOGDIR=%SystemDrive%\MaintenanceLogs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "TIMESTAMP=%DATE:/=-%_%TIME::=-%"
set "REPORT=%LOGDIR%\cleanup_report_%TIMESTAMP%.txt"

:: ----------------------------
:: INTRO BANNER
:: ----------------------------
cls
echo ##############################################################
echo #                                                            #
echo #   NEXTLAYERSEC - CLIENT DISK CLEANUP + REPAIR v1.3         #
echo #                                                            #
echo #   https://github.com/NextLayerSec                          #
echo ##############################################################
echo.
echo Run this file as Administrator (Right-click > Run as administrator).
echo.
echo Press any key to begin...
pause >nul

:: ----------------------------
:: ADMIN CHECK
:: ----------------------------
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
echo.
echo [1/12] Cleaning TEMP files...
del /q /f "%TEMP%\*.*" >nul 2>&1
del /q /f "%SystemRoot%\Temp\*.*" >nul 2>&1

echo [2/12] Emptying Recycle Bin...
rd /s /q %SYS%\$Recycle.Bin >nul 2>&1

echo [3/12] Cleaning Windows Update Cache...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\Download >nul 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\DeliveryOptimization >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [4/12] Cleaning Prefetch...
del /q /f %SystemRoot%\Prefetch\*.* >nul 2>&1

echo [5/12] Cleaning Logs...
del /q /s /f %SystemRoot%\Logs\*.* >nul 2>&1
del /q /s /f %SystemRoot%\Logs\CBS\*.* >nul 2>&1

echo [6/12] Cleaning Crash Dumps...
del /q /s /f C:\ProgramData\Microsoft\Windows\WER\*.* >nul 2>&1
del /q /s /f %SystemRoot%\Minidump\*.* >nul 2>&1
del /q /f %SystemRoot%\MEMORY.DMP >nul 2>&1

echo [7/12] Cleaning Defender History...
del /q /s /f "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*.*" >nul 2>&1

echo [8/12] Cleaning Browser Caches (Chrome, Edge, Firefox)...
del /f /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
for /d %%P in ("%AppData%\Mozilla\Firefox\Profiles\*.default-release") do (
    del /f /s /q "%%P\cache2\entries\*" >nul 2>&1
)

echo [9/12] Running SFC...
sfc /scannow

echo [10/12] Running DISM Health Restore...
DISM /Online /Cleanup-Image /RestoreHealth

echo [11/12] DISM Component Cleanup...
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

echo [12/12] Pagefile will be wiped on next shutdown...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f >nul 2>&1

:: ----------------------------
:: GET FREE SPACE AFTER
:: ----------------------------
for /f "tokens=3" %%a in ('fsutil volume diskfree %SYS% ^| find "of free bytes"') do set "FREE_AFTER=%%a"
set /a FREED=%FREE_AFTER% - %FREE_BEFORE%

:: ----------------------------
:: REPORT (TO FILE)
:: ----------------------------
echo NEXTLAYERSEC - CLEANUP REPORT > "%REPORT%"
echo ============================ >> "%REPORT%"
echo DATE: %DATE%   TIME: %TIME% >> "%REPORT%"
echo USER: %USERNAME%             >> "%REPORT%"
echo MACHINE: %COMPUTERNAME%      >> "%REPORT%"
echo.                             >> "%REPORT%"
echo Free Before: %FREE_BEFORE% bytes >> "%REPORT%"
echo Free After : %FREE_AFTER% bytes >> "%REPORT%"
echo Freed      : %FREED% bytes      >> "%REPORT%"
echo.                             >> "%REPORT%"
echo Pagefile clearing scheduled at shutdown. >> "%REPORT%"
echo Reboot scheduled in 30 minutes (forced). >> "%REPORT%"

:: ----------------------------
:: DISPLAY SUMMARY
:: ----------------------------
echo.
echo ==========================================
echo             CLEANUP SUMMARY
echo ==========================================
echo Free Before : %FREE_BEFORE% bytes
echo Free After  : %FREE_AFTER% bytes
echo Space Freed : %FREED% bytes
echo.
echo Pagefile will be cleared on next shutdown.
echo Report saved to: %REPORT%

:: ----------------------------
:: SCHEDULE FORCED REBOOT (30 MIN)
:: ----------------------------
echo.
echo System will force restart in 30 minutes.
shutdown /r /f /t 1800 /c "NEXTLAYERSEC: Rebooting after cleanup in 30 minutes (forced)."

:: ----------------------------
:: OPEN SYSTEM RESTORE (Optional)
:: ----------------------------
start "" control sysdm.cpl,,3

:: ----------------------------
:: KEEP CMD WINDOW OPEN
:: ----------------------------
echo.
echo Cleanup complete. Type 'exit' to close or run commands below.
echo.
cmd /k
endlocal
