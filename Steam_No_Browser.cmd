@echo off
setlocal EnableDelayedExpansion

:: Configuration Section
:: Steam directory
set "steam_path=%SystemDrive%\Program Files (x86)\Steam"
:: Game to launch
set "app_id=368260"
:: Time in seconds to wait for Steam to start
set "init_time=20"
:: Time in seconds before giving up on webhelper starting
set /a "max_wait_for_update=90"

:: Check if Steam.exe exists in path, if not print error.
if not exist "!steam_path!\steam.exe" (
    call :PrntBox PathError
    pause
    exit /b 1
)

echo Force closing Steam if running, and ensuring steamwebhelper is available for launch.
:: Kill Steam if it's running
taskkill /f /im "steam.exe" 2>nul

:: Restore binary as steam requires it to initialize.
call :BinaryDance "hiddenwebhelper" "steamwebhelper.exe"

echo.
echo Launching Steam and App #!app_id!.
:: Open steam and specified app
start "" "!steam_path!\steam.exe" steam://rungameid/!app_id! --disable-background-networking --enable-low-end-device-mode --single-process -cef-single-process -skipinitialbootstrap -quicklogin -oldtraymenu -silent

echo.
echo Waiting to make sure Steam has launched before killing steamwebhelper
echo (Note, if this timing doesn't work for you, just modify init_time in the script.)
:: Only continue if steamwebhelper is running in case steam is updating
set /a "count=0"
:wait_for_steamwebhelper
tasklist | findstr /i "steamwebhelper.exe" >nul 2>&1 && goto :steamwebhelper_started
set /a "count+=1"
if !count! lss !max_wait_for_update! (
    :: Using ping as a sleep because it has more accurate timing, and a countdown is not needed.
    ping -n 2 localhost >nul
    goto :wait_for_steamwebhelper
)
call :PrntBox TimeoutError
pause
exit /b 1


:steamwebhelper_started
:: Allow a few seconds for steam to initialize/login
timeout /t !init_time! /nobreak

echo.
echo Killing webhelper and renaming the exe.
:: Hide binary and kill the process
call :BinaryDance "steamwebhelper.exe" "hiddenwebhelper" "kill"

:: Prints a message instructing the user to keep the window open and close Steam when done.
call :PrntBox WaitInstruction

:: Wait for steam to be closed and then rename webhelper back.
:wait_to_fix
:: Using ping as a sleep because it has more accurate timing, and a countdown is not needed.
ping -n 11 localhost >nul
tasklist /fi "imagename eq steam.exe" 2>nul | find /i "steam.exe">nul 2>&1
IF ERRORLEVEL 1 (
    call :BinaryDance "hiddenwebhelper" "steamwebhelper.exe"
    echo Program complete. You may close the window.
) ELSE (
    goto wait_to_fix
)
pause
exit/b 0

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
            if errorlevel 1 (
                pause
                exit /b 1
                )
        )
        if exist "!dest!" (
            del "!src!" >nul 2>&1 && echo %~1 deleted as %~2 already exists
        ) else (
            move "!src!" "!dest!" >nul && echo %~1 renamed to %~2
        )
    )
)
exit/b

:: psuedo switch to print formatted message boxes for errors and instructions.
:PrntBox
echo.
goto :%1 
echo Error: Bad paramater passed to PrntBox. I should make a better error message for this...
pause
exit /b
    :PathError
    echo.
    echo    ษอออออออออออออออออออออออออออออออออออออออออป
    echo    บ  "Steam.exe" not found. Please ensure   บ
    echo    บ the 'steam_path' variable in the script บ
    echo    บ matches your steam installation folder. บ
    echo    ศอออออออออออออออออออออออออออออออออออออออออผ
    echo.
    exit /b   
    :TimeoutError
    echo.
    echo    ษออออออออออออออออออออออออออออออออออออออออออออออออออป
    echo    บ Steamwebhelper has not started for !max_wait_for_update! seconds.   บ
    echo    บ either Steam has not launched or it is updating. บ
    echo    บ If !max_wait_for_update! seconds is not long enough, you can modify บ
    echo    บ the 'max_wait_for_update' variable in the script บ
    echo    ศออออออออออออออออออออออออออออออออออออออออออออออออออผ
    echo.
    exit /b
    :WaitInstruction
    echo.
    echo.
    echo       ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    echo       บ   Leave this window open and when done close Steam either   บ
    echo       บ by right clicking it on the taskbar, or in the task manager บ
    echo       บ    This ensures things are put back how they should be.     บ
    echo       ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
    echo.
    echo.
    exit /b  