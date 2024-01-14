REM THIS IS A TEST FILE. NOTHING IN HERE IS IMPORTANT (yet).
REM I was just too lazy to set up .gitignore or branches.

REM The file is currently being used to find a 
REM way to generate PrintBoxes on the fly.

@echo off
setlocal EnableDelayedExpansion

SET "mystr=Leave this window open. When done close Steam either by right clicking it on the taskbar, or in the task manager. This ensures things are put back how they should be."
REM SET mynumber=120
REM FOR /l %%i IN (2,1,%mynumber%) DO set "mystr=!mystr!%mystr%"

REM ECHO +%mystr%+
call :strlen length mystr
call :funk result length 50
echo !result!
pause

REM ********* function *****************************
:strlen <resultVar> <stringVar>
(   
   set "tmp=!%~2!"
   if defined tmp (
      set "len=1"
      for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
         if "!tmp:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "tmp=!tmp:~%%P!"
         )
      )
   ) ELSE (
      set "len=0"
   )
)
endlocal
set "%~1=%len%"
exit /b

:funk <resultVar> <lengthVar> <Max>
set "len=!%~2!" 
REM add zeroes
echo len=%len%
for /L %%d in (1,1,100) do (
   echo %len%/%%~d=!tempres!
   set /a "tmpres=%len%/%%~d"
   echo tmpres=!tmpres!
   if !tmpres! LEQ %~3 (
      REM set /a integerPart=!tmp! /100
      REM set /a decimalPart=!tmp! %% 100
      REM set "%~1=!integerPart!.!decimalPart!"
      set /a "%~1=!tmpres!"
      exit /b
   )
)

:Horrizontal
SET "mychar=Í"
FOR /l %%i IN (2,1,%~1) DO set "mychar=!mychar!%mychar%"
IF %~3==t echo. && echo %~2É%mychar%»
IF %~3==b echo %~2È%mychar%¼ && echo.
exit /b

:PrntBox
goto :WaitInstruction
exit /b
    :WaitInstruction
    echo.
    call :Horrizontal 61 "      " t
    echo       º   Leave this window open and when done close Steam either   º
    echo       º by right clicking it on the taskbar, or in the task manager º
    echo       º    This ensures things are put back how they should be.     º
    call :Horrizontal 61 "      " b
    echo.