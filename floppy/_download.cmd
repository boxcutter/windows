setlocal EnableDelayedExpansion EnableExtensions

set url=%~1
set filename=%~2

if not defined url goto :eof

if not defined filename set filename=%TEMP%\%~nx1

if exist "%filename%" del /f "%filename%"

for %%i in ("%filename%") do set basename=%%~nxi

if not exist "%~dp0\%basename%" goto download

echo ==^> Copying "%~dp0\%basename%" to "%filename%"

copy /y "%~dp0\%basename%" "%filename%"

goto :eof

:download

echo ==^> Downloading "%url%" to "%filename%"

set wget=

PATH=%SystemRoot%;%PATH%;%~dp0

for %%i in (wget.exe) do set wget=%%~$PATH:i

:: for some reason the above commands do not work sometimes
if not defined wget if exist %SystemRoot%\wget.exe set wget=%SystemRoot%\wget.exe
if not defined wget if exist d:\wget.exe set wget=d:\wget.exe
if not defined wget if exist e:\wget.exe set wget=e:\wget.exe
if not defined wget if exist %~dp0\wget.exe set wget=%~dp0\wget.exe

if defined wget goto wget

set bitsadmin=

for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

if defined bitsadmin goto bitsadmin

:wget

"%wget%" --no-check-certificate --quiet -O "%filename%" "%url%"

if exist "%filename%" goto :eof

if not defined bitsadmin goto powershell

:bitsadmin

for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%url%" "%filename%"

if exist "%filename%" goto :eof

:powershell

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%filename%')" <NUL

goto :eof
