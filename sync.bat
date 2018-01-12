:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   ____ _                 _  ____            __ _   
::  / ___| | ___  _   _  __| |/ ___|_ __ __ _ / _| |_ 
:: | |   | |/ _ \| | | |/ _` | |   | '__/ _` | |_| __|
:: | |___| | (_) | |_| | (_| | |___| | | (_| |  _| |_ 
::  \____|_|\___/ \__,_|\__,_|\____|_|  \__,_|_|  \__|
::
:: Website: https://cloudcraft.info
:: Facebook: https://www.facebook.com/CloudCraftTeam
:: Youtube: https://www.youtube.com/channel/UCe6hnAk19MgZIdhm4i11Mlg
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off

set "source=%1"
set "dest=%2"
set "timeout=%3"

::::::::::::::REPLACE INCORRECT SEPERATOR FROM / TO \::::::::::::::::
set replace=\
call set source=%%source:/=%replace%%%
call set dest=%%dest:/=%replace%%%

::::::::::::::::::::REMOVE ENDING SEPERATOR::::::::::::::::::::::::::
:while1
if "%source:~-1%"=="\" (
	set "source=%source:~0,-1%"
	goto while1
)

:while2
if "%dest:~-1%"=="\" (
	set "dest=%dest:~0,-1%"
	goto while2
)

::::::::::::::::CHECK IF INPUT TIMEOUT VALID OF NOT::::::::::::::::::
if "%timeout%" == "" (
	set "timeout=-1"
	echo [%date% %time%] SYNC START >> sync-log.txt
	goto loop
)
echo %timeout%| findstr /r "^[1-9][0-9]*$" > nul
if %errorlevel% neq 0 (
	echo INVALID TIMEOUT...
	echo "Usage: .\sync.bat <source> <dest> <timeout>"
	pause
	exit
) else (
	echo [%date% %time%] SYNC START >> sync-log.txt
)

::::::::::::::::::::::::::BEGIN SYNC:::::::::::::::::::::::::::::::::
:loop

xcopy /r /e /d /c /y %source% %dest% | find /v "File(s) copied" >> sync-log.txt

dir /b /s %dest%  > dest.txt

set "find=%dest%\"
set "replace="
set "textfile=dest.txt"
set "newfile=output.txt"
(for /f "delims=" %%i in (%textfile%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%find%=%replace%!"
    echo(!line!
    endlocal
	)
) > %newfile%
del %textfile%
rename %newfile%  %textfile%

for /f "tokens=*" %%F in (dest.txt) do (
	if not exist "%source%\%%F" (
		if exist "%dest%\%%F" (
			echo delete %dest%\%%F >> sync-log.txt
			if exist "%dest%\%%F\*" (
				rmdir /s /q "%dest%\%%F"
			) else (
				del /q "%dest%\%%F"
			)
			if exist "%dest%\%%F" echo delete %dest%\%%F fail >> sync-log.txt
		)
	)
)

if exist "dest.txt" del /q dest.txt

if "%timeout%" neq "-1" (
	timeout %timeout% > nul
	goto loop
) else (
	echo COMPLETE...
	echo COMPLETE... >> sync-log.txt
) 
