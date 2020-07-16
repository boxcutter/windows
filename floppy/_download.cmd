@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

set "url=%~1"
set "filename=%~2"

REM First validate the parameters that we were given.
if not defined url (
    echo ==^> ERROR: _download.cmd called without URL parameter.
    goto exit1
)

if not defined filename set filename=%TEMP%\%~nx1

REM Then check to make sure the file hasn't already been downloaded to where the
REM caller has specified. If it already happened, then we can simply exit here.
:check_fileexists
if exist "%filename%" (
    echo ==^> File "%filename%" already exists, skipping download.
    goto exit0
)

REM Otherwise we first check and see if the file already exists somewhere in
REM our search path. If it does, then we will only need to copy it to where ever
REM the caller specified.
:check_copyfile
set basename=
for %%i in ("%url%") do set basename=%%~nxi
if not defined basename goto download

set found=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined found @if exist "%%~i\%basename%" set found=%%~i\%basename%
if not defined found goto download

REM Use a good ol' reliable file-copy to put the file in its right place.
:copyfile
echo ==^> Copying "%found%" to "%filename%", skipping download.
copy /y "%found%" "%filename%" && goto exit0

echo ==^> Unable to copy file from "%found%" to "%filename%", re-downloading the file.

REM Hm. Our reliable file-copy is apparently not-so-reliable, or the file really
REM does need to be downloaded. So we proceed to use one of the following
REM downloaders to download the file.
:download
echo ==^> Downloading "%url%" to "%filename%"

REM First check to see if we have an instance of Powershell, and give it
REM priority when downloading. This is due to the other methods being flakey
REM and not working on all supported platforms. More importantly, things like
REM wget.exe are hosted remotely, and so we're unable to update it or interact
REM with it in any way. It can also be backdoored out from underneath us which
REM we should be fairly concerned about...
:check_powershell
where powershell 1>NUL 2>NUL
if errorlevel 1 goto check_wget

powershell -Command "(New-Object System.Net.WebClient)" >NUL 2>NUL
if errorlevel 1 goto check_wget

REM Check to see if our instance of Powershell supports at least TLS v1.2 (.NET
REM Framework 4.5). This is because most of the internet is now enforcing that
REM particular version of TLS. So if we can't use it, we're forced to deal and
REM will have to use wget.exe instead.

REM [Net.SecurityProtocolType]::Ssl3 - 48
REM [Net.SecurityProtocolType]::Tls - 192
REM [Net.SecurityProtocolType]::Tls11 - 768
REM [Net.SecurityProtocolType]::Tls12 - 3072
REM [Net.SecurityProtocolType]::Tls13 - 12288

powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 4080" >NUL 2>NUL
if errorlevel 1 goto check_wget

REM Use powershell to actually download the file (best case). If it doesn't
REM work, then try using wget next.
:powershell
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 4080; (New-Object System.Net.WebClient).DownloadFile('%url%', '%filename%')" <NUL

if errorlevel 1 goto check_wget

goto check_file_downloaded

REM So we weren't able to use Powershell, which means we need to figure out the
REM path to wget.exe first. This should have been placed somewhere in our path
REM during the build process. So, we start in the SystemRoot and continue
REM through all of the search paths to try and find it. If that fails, then we
REM continue onto the next downloader tool.
:check_wget
if not defined WGET_OPTS ( set "WGET_OPTS=-nc" ) else if defined WGET_OPTS ( set "WGET_OPTS=%WGET_OPTS% -nc" )
if not defined PACKER_DEBUG ( set "WGET_OPTS=%WGET_OPTS% -nv" ) else if defined PACKER_DEBUG if "%PACKER_DEBUG%" == "0" set "WGET_OPTS=%WGET_OPTS% -nv"

set wget=
for %%i in (wget.exe) do set wget=%%~$PATH:i
if defined wget goto wget

@for %%i in (%SystemRoot% %PACKER_SEARCH_PATHS%) do @if not defined wget @if exist "%%~i\wget.exe" set wget=%%~i\wget.exe

if not defined wget goto check_bitsadmin
if not exist "%wget%" goto check_bitsadmin

"%wget%" --version >NUL 2>NUL
if errorlevel 1 goto check_bitsadmin

REM Use wget to download the file to the path that was specified. If we don't
REM succeed, then we just try again with bitsadmin.
:wget
"%wget%" %WGET_OPTS% -O "%filename%" "%url%"

if errorlevel 1 goto check_bitsadmin

goto check_file_downloaded

REM Check to see if we can legitimately use bitsadmin, and then verify that the
REM command is somewhere in our PATH. We've hit the worst-possible case here,
REM but we need to keep trying anyways as a lot of the tools that we use are
REM hosted remotely.
:check_bitsadmin
if defined DISABLE_BITS (
    if not "%DISABLE_BITS%" == "0" if not exist "%filename%" goto check_curl
)

set bitsadmin=
for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe
if not exist "%bitsadmin%" goto check_curl

REM Use bitsadmin to "transfer" the file by creating a jobname for the specified
REM filename, and then initiating the transfer. Bits doesn't have a good way of
REM detecting whether it failed or not, so the only thing we can do is check to
REM see if the file exists...or not.
:bitsadmin
for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%url%" "%filename%"

if not exist "%filename%" goto check_curl

goto check_file_downloaded

REM Every other method so far has failed entirely, so at this point there's
REM nothing left to try but curl.exe which came for free with the build. We
REM first need to locate it and make sure that it actually works.
:check_curl
if not defined CURL_OPTS ( set "CURL_OPTS=-A '' -L" ) else if defined CURL_OPTS ( set "CURL_OPTS=%CURL_OPTS% -A '' -L" )
if defined PACKER_DEBUG if not "%PACKER_DEBUG%" == "0" set "CURL_OPTS=%CURL_OPTS% --verbose"

set curl=
for %%i in (curl.exe) do set curl=%%~$PATH:i
if defined curl goto curl

@for %%i in (%SystemRoot% %PACKER_SEARCH_PATHS%) do @if not defined curl @if exist "%%~i\curl.exe" set curl=%%~i\curl.exe

if not defined curl goto exit1
if not exist "%curl%" goto exit1

"%curl%" --version >NUL 2>NUL
if errorlevel 1 goto exit1

REM It seems that curl works. We're pretty fortunate since it was pretty much
REM our very last shot. So let's try and download the url that the caller
REM requested we fetch for them.
:curl
"%curl%" %CURL_OPTS% -o "%filename%" "%url%"
goto check_file_downloaded

REM We were able to use a download tool, but now we need to double check if it
REM either failed, or if our file still doesn't exist yet. If either of these
REM cases have happened, then we've failed pretty hard and we need to let our
REM calling script know what's up.
:check_file_downloaded
if not errorlevel 1 if exist "%filename%" goto exit0

echo ==^> ERROR: Failed to download "%url%" to "%filename%"
goto :exit1

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
