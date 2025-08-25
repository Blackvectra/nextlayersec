@echo off
schtasks /create ^
 /tn "NextLayerSec Cleanup Weekly" ^
 /tr "\"%~dp0NextLayerSec_Cleanup_v1.4.bat\"" ^
 /sc weekly /d SUN /st 04:00 ^
 /rl highest /f

echo Task 'NextLayerSec Cleanup Weekly' scheduled successfully.
pause
