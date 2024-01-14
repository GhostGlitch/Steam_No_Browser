@echo off 
setlocal EnableDelayedExpansion
tasklist | findstr /i "steam.exe" >nul && taskkill /f /im >nul"steam.exe" 

echo Terminating Steam...

pause