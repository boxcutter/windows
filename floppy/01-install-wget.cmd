setlocal EnableDelayedExpansion EnableExtensions
title Installing wget. Please wait...

:: bitsadmin can't download http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
if not defined WGET_URL set WGET_URL=http://users.ugent.be/~bpuype/wget/wget.exe

for %%i in ("%WGET_URL%") do set filename=%SystemRoot%\%%~nxi

if not exist "%~dp0\_download.cmd" goto _download_cmd_not_found

copy /y "%~dp0\_download.cmd" "%SystemRoot%\"

call "%~dp0\_download.cmd" "%WGET_URL%" "%filename%"

if exist "%filename%" goto exit0

:_download_cmd_not_found

echo ==^> Downloading "%WGET_URL%" to "%filename%"

set bitsadmin=

for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

if not exist "%bitsadmin%" goto powershell

for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%WGET_URL%" "%filename%"

if exist "%filename%" goto exit0

:powershell

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%WGET_URL%', '%filename%')" <NUL

if exist "%filename%" goto exit0

goto exit1

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
