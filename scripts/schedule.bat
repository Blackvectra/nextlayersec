@echo off
set TASKNAME=NextLayerSec Cleanup Weekly
set TASKPATH=%~dp0cleanup.bat

schtasks /create ^
 /tn "%TASKNAME%" ^
 /tr "\"%TASKPATH%\"" ^
 /sc weekly /d SUN /st 04:00 ^
 /rl highest /f

echo.
echo Task '%TASKNAME%' created to run weekly at 4:00 AM on Sundays.
pause
