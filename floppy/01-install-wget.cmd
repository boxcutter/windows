@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

echo on

title Installing wget. Please wait...

if not defined WGET_URL set WGET_URL=https://eternallybored.org/misc/wget/current/wget.exe

for %%i in ("%WGET_URL%") do set filename=%SystemRoot%\%%~nxi

if not exist "%~dp0\_download.cmd" goto _download_cmd_not_found

copy /y "%~dp0\_download.cmd" "%SystemRoot%\"

call "%~dp0\_download.cmd" "%WGET_URL%" "%filename%"

if exist "%filename%" goto exit0

:_download_cmd_not_found

echo ==^> Downloading "%WGET_URL%" to "%filename%"

:powershell
if defined http_proxy (
    powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('%WGET_URL%', '%filename%')" >nul
) else (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%WGET_URL%', '%filename%')" >nul
)

if not errorlevel 1 if exist "%filename%" goto exit0

if defined USE_BITS (
    if "%USE_BITS%" == "false" if not exist "%filename%" goto exit1
)

set bitsadmin=

for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

if not exist "%bitsadmin%" goto exit1

for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%WGET_URL%" "%filename%"

if exist "%filename%" goto exit0

goto exit1

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
