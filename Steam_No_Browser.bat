@echo off
setlocal EnableDelayedExpansion

:: Configuration Section
:: Steam directory
set "steam_path=%SystemDrive%\Program Files (x86)\Steam"
:: Game to launch
set app_id=368260
:: Time in seconds to wait for steam to start
set init_time=20

:: Check if steam.exe exists in path, if not print error.
if not exist "!steam_path!\steam.exe" (
    echo =======ERROR=============================
    echo "Steam.exe" not found. Please ensure
    echo the 'steam_path' variable in the script
    echo matches your steam installation folder.
    echo =========================================
    echo.
    pause
    exit
)

:StartScript
:: kill steam if is running
tasklist | findstr /i "steam.exe" && taskkill /f /im "steam.exe"

:: rename binary back to .exe as steam requires it to initialize, and ensure the script isn't blocked by both files existing.
for %%a in ("cef.win7", "cef.win7x64") do (
    set "bin=!steam_path!\bin\cef\%%~a\steamwebhelper.exe"
    set "bin2=!steam_path!\bin\cef\%%~a\webhelper"
    if exist "!bin2!" (
        if exist "!bin!" (
            del "!bin2!"
        ) else (
            ren "!bin2!" "steamwebhelper.exe"
        )
    )
)

:: open steam
start "" "!steam_path!\steam.exe"  steam://rungameid/!app_id! --disable-background-networking --enable-low-end-device-mode --single-process -cef-single-process -skipinitialbootstrap -quicklogin -oldtraymenu -silent

:: only continue if steamwebhelper is running in case steam is updating
:query_steamwebhelper
tasklist | findstr /i "steamwebhelper.exe" || goto :query_steamwebhelper

:: allow a few seconds for steam to initialize/login
timeout /t !init_time! /nobreak

:: rename binary and kill the process
for %%a in ("cef.win7", "cef.win7x64") do (
    set "bin=!steam_path!\bin\cef\%%~a\steamwebhelper.exe"
    if exist "!bin!" (
	    taskkill /f /im "steamwebhelper.exe"
        ren "!bin!" "webhelper"
    )
)

:check_process
taskkill /f /im "steamwebhelper.exe"
timeout /t 10 /nobreak
tasklist | find /i "steam.exe" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO fix
) ELSE (
  cls
  GOTO check_process
)

:fix
:: rename binary
for %%a in ("cef.win7", "cef.win7x64") do (
    set "bin2=!steam_path!\bin\cef\%%~a\webhelper"
    if exist "!bin2!" (
        ren "!bin2!" "steamwebhelper.exe"
    )
)
