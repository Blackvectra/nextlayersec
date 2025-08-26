@echo off
setlocal EnableDelayedExpansion
title NEXTLAYERSEC - CLIENT CLEANUP TOOL v1.6 (Admin Safe Edition)

:: ---------------------------------
:: CONFIGURATION / TOGGLES
:: ---------------------------------
set "CLEAR_PAGEFILE=true"
set "DELETE_WINDOWS_OLD=true"
set "SCHEDULE_REBOOT_MINUTES=30"
set "PROMPT_REBOOT=true"

:: ---------------------------------
:: LOGGING (unique per run)
:: ---------------------------------
set "SYS=C:"
set "LOGDIR=C:\CleanupLogs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
set "LOG=%LOGDIR%\cleanup_%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%.txt"
set "LOG=%LOG:"=%"   :: strip quotes from log path
set "TEE=powershell -NoProfile -ExecutionPolicy Bypass -Command"

:: ---------------------------------
:: BANNER
:: ---------------------------------
cls
echo ##############################################################
echo #      NEXTLAYERSEC - CLIENT CLEANUP TOOL v1.6               #
echo #      https://github.com/blackvectra/nextlayersec           #
echo ##############################################################
echo.
echo Run as administrator.
echo Press any key to begin...
pause >nul

:: ---------------------------------
:: CHECK ADMIN
:: ---------------------------------
net session >nul 2>&1
if errorlevel 1 (
    echo [!] WARNING: Not running as administrator. Some actions may fail.
    echo Continue anyway? Press any key...
    pause >nul
)

:: ---------------------------------
:: INITIAL FREE SPACE
:: ---------------------------------
for /f "tokens=3" %%a in ('fsutil volume diskfree %SYS% ^| find "of free bytes"') do set "FREE_BEFORE=%%a"

(
  echo CLEANUP REPORT - %DATE% %TIME%
  echo =======================================
) > "%LOG%"

:: ---------------------------------
:: CLEANUP STEPS
:: ---------------------------------
echo [1/15] Temp files...
del /q /s /f "%TEMP%\*.*" >> "%LOG%" 2>&1
del /q /s /f "%SystemRoot%\Temp\*.*" >> "%LOG%" 2>&1
del /q /s /f "%LocalAppData%\Temp\*.*" >> "%LOG%" 2>&1

echo [2/15] Recycle Bin...
rd /s /q %SYS%\$Recycle.Bin >> "%LOG%" 2>&1

echo [3/15] Windows Update cache...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\Download >> "%LOG%" 2>&1
rd /s /q %SystemRoot%\SoftwareDistribution\DeliveryOptimization >> "%LOG%" 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [4/15] Prefetch...
del /q /f %SystemRoot%\Prefetch\*.* >> "%LOG%" 2>&1

echo [5/15] Logs...
del /q /s /f %SystemRoot%\Logs\*.* >> "%LOG%" 2>&1
del /q /s /f %SystemRoot%\Logs\CBS\*.* >> "%LOG%" 2>&1

echo [6/15] Crash dumps & WER...
del /q /s /f "C:\ProgramData\Microsoft\Windows\WER\*.*" >> "%LOG%" 2>&1
del /q /s /f "%SystemRoot%\Minidump\*.*" >> "%LOG%" 2>&1
del /q /f "%SystemRoot%\MEMORY.DMP" >> "%LOG%" 2>&1
del /q /s /f "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*.*" >> "%LOG%" 2>&1
del /q /s /f "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*.*" >> "%LOG%" 2>&1

echo [7/15] Defender scan history...
del /q /s /f "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*.*" >> "%LOG%" 2>&1

echo [8/15] SFC (live + logged)...
%TEE% "cmd /c 'sfc /scannow' 2>&1 | Tee-Object -FilePath '%LOG%' -Append"

echo [9/15] DISM /RestoreHealth (live + logged)...
%TEE% "cmd /c 'DISM /Online /Cleanup-Image /RestoreHealth' 2>&1 | Tee-Object -FilePath '%LOG%' -Append"

echo [10/15] DISM Component Cleanup (live + logged)...
%TEE% "cmd /c 'DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase' 2>&1 | Tee-Object -FilePath '%LOG%' -Append"

echo [11/15] Browser caches...
del /q /f /s "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*.*" >> "%LOG%" 2>&1
del /q /f /s "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*.*" >> "%LOG%" 2>&1
for /d %%P in ("%AppData%\Mozilla\Firefox\Profiles\*.default-release") do (
  del /q /f /s "%%P\cache2\entries\*.*" >> "%LOG%" 2>&1
)

echo [12/15] App caches...
del /q /s /f "%LocalAppData%\Packages\*\LocalCache\*.*" >> "%LOG%" 2>&1
del /q /s /f "%LocalAppData%\Packages\*\TempState\*.*" >> "%LOG%" 2>&1

echo [13/15] Windows.old (optional)...
if /i "%DELETE_WINDOWS_OLD%"=="true" (
  if exist "%SYS%\Windows.old" (
    echo   Deleting Windows.old...
    rd /s /q "%SYS%\Windows.old" >> "%LOG%" 2>&1
  )
)

echo [14/15] Pagefile clear at reboot (optional)...
if /i "%CLEAR_PAGEFILE%"=="true" (
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" ^
    /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f >nul
)

echo [15/15] Checking for Windows Updates (scan only)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "UsoClient StartScan" >> "%LOG%" 2>&1

:: ---------------------------------
:: FINAL STORAGE STATS
:: ---------------------------------
for /f "tokens=3" %%a in ('fsutil volume diskfree %SYS% ^| find "of free bytes"') do set "FREE_AFTER=%%a"
set /a FREED=%FREE_AFTER% - %FREE_BEFORE%
echo.
echo [✓] Cleanup complete.
echo Space before : %FREE_BEFORE%
echo Space after  : %FREE_AFTER%
echo Freed        : %FREED% bytes
echo Log saved to : %LOG%

:: ---------------------------------
:: PROMPT REBOOT
:: ---------------------------------
set /a REBOOT_SECONDS=%SCHEDULE_REBOOT_MINUTES%*60
if /i "%PROMPT_REBOOT%"=="true" (
  echo.
  choice /C YN /D N /T 15 /M "Reboot now to finalize cleanup? (Y/N)"
  if errorlevel 2 (
    echo [i] Reboot skipped.
  ) else (
    echo [!] Rebooting in %SCHEDULE_REBOOT_MINUTES% minutes...
    shutdown /r /f /t %REBOOT_SECONDS% /c "NEXTLAYERSEC: Reboot scheduled after cleanup"
  )
)

:: ---------------------------------
:: KEEP SHELL OPEN
:: ---------------------------------
echo.
echo Type ^"exit^" to close, or use the shell below.
cmd /k
endlocal
exit /b 0
