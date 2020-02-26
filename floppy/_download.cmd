@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

set "url=%~1"

set "filename=%~2"

if not defined url echo ==^> ERROR: _download.cmd called without URL parameter. & goto exit1

if not defined filename set filename=%TEMP%\%~nx1

if exist "%filename%" echo ==^> File "%filename%" already exists, skipping download. & goto exit0

set basename=

for %%i in ("%url%") do set basename=%%~nxi

if not defined basename goto download

set found=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined found @if exist "%%~i\%basename%" set found=%%~i\%basename%

if not defined found goto download

echo ==^> Copying "%found%" to "%filename%", skipping download.

copy /y "%found%" "%filename%" && goto exit0

:download
REM IT IS JUST CLEANER WITH THIS WGET IS REALLY PICKY.  POWERSHELL - NOT SO MUCH
if defined http_proxy goto powershell

set wget=

for %%i in (wget.exe) do set wget=%%~$PATH:i

if defined wget goto wget

@for %%i in (%SystemRoot% %PACKER_SEARCH_PATHS%) do @if not defined wget @if exist "%%~i\wget.exe" set wget=%%~i\wget.exe

:wget

if not exist "%wget%" goto powershell

echo ==^> Downloading "%url%" to "%filename%" using "%wget%"...

if not defined PACKER_DEBUG set WGET_OPTS=--no-verbose

if defined http_proxy (
  if defined http_proxy_user if defined http_proxy_password (
      set WGET_OPTS=%WGET_OPTS% --proxy-user='%http_proxy_user%' --proxy-passwd='%http_proxy_password%'
  )
)

"%wget%" --no-check-certificate %WGET_OPTS% -O "%filename%" "%url%"

if not errorlevel 1 if exist "%filename%" goto exit0

:powershell
echo ==^> Downloading "%url%" to "%filename%" using "Powershell"...

if defined http_proxy (
    set "ps1_proxy=$wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ;"
    if defined http_proxy_user if defined http_proxy_password (
        set "ps1_proxy_auth=$wc.proxy.Credentials = (New-Object System.Net.NetworkCredential('%http_proxy_user%', '%http_proxy_password%')) ;"
    )

    if defined no_proxy (
        set "ps1_no_proxy=$wc.proxy.BypassList = (('%no_proxy%').split(',')) ;"
    )
)

set ps1_script="$wc = (New-Object System.Net.WebClient) ; %ps1_proxy% %ps1_proxy_auth% %ps1_no_proxy% $wc.DownloadFile('%url%', '%filename%')"

powershell -command %ps1_script% >nul

if not errorlevel 1 if exist "%filename%" goto exit0

:bitsadmin

set bitsadmin=

for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

if not exist "%bitsadmin%" goto exit 1

echo ==^> Downloading "%url%" to "%filename%" using "BITS"...

for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%url%" "%filename%"

if not errorlevel 1 if exist "%filename%" goto exit0

echo ==^> ERROR: Failed to download "%url%" to "%filename%"

goto :exit1

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
