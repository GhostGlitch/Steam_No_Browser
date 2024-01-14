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

:: Kill steam if it's running
tasklist | findstr /i "steam.exe" && taskkill /f /im "steam.exe"

:: Restore binary back as steam requires it to initialize.
call :BinaryDance "webhelper" "steamwebhelper.exe"

:: Open steam and specified app
start "" "!steam_path!\steam.exe" steam://rungameid/!app_id! --disable-background-networking --enable-low-end-device-mode --single-process -cef-single-process -skipinitialbootstrap -quicklogin -oldtraymenu -silent

:: Only continue if steamwebhelper is running in case steam is updating
:wait_for_steamwebhelper
tasklist | findstr /i "steamwebhelper.exe" || goto :wait_for_steamwebhelper

:: Allow a few seconds for steam to initialize/login
timeout /t !init_time! /nobreak

:: Hide binary and kill the process
call :BinaryDance "steamwebhelper.exe" "webhelper" "kill"

:: Wait for steam to be closed and then rename webhelper back.
:wait_to_fix
timeout /t 10 /nobreak  
tasklist | find /i "steam.exe" >nul 2>&1
IF ERRORLEVEL 1 (
    call :BinaryDance "webhelper" "steamwebhelper.exe"
) ELSE (
    goto wait_to_fix
)
exit/b

:: Used for renaming steamwebhelper back and forth. 
:: Delete the source if the destination already exists. 
:: Also optionally kill the process.
:: Parameters:
::   %1 - Source filename 
::   %2 - Destination filename
::   %3 - "kill" to kill the process with the name %1 (OPTIONAL)
:BinaryDance
for %%a in ("cef.win7", "cef.win7x64") do (
    set "src=!steam_path!\bin\cef\%%~a\%~1"
    set "dest=!steam_path!\bin\cef\%%~a\%~2"
    if exist "!src!" (
        if "%~3"=="kill" (
            taskkill /f /im "%~1"
            echo %~1 killed
        )
        if exist "!dest!" (
            del "!src!"
            echo %~1 deleted as %~2 already exists
            echo.
        ) else (
            move "!src!" "!dest!"
            echo %~1 moved to %~2
            echo.
        )
    )
)
exit/b