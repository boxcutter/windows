@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

echo on

title Bootstrapping download tools. Please wait...

REM We'll first try and download wget from the following URL using
REM our regular download tools supported by the platform. So start
REM by calculating the filename to save wget.exe to.
if not defined WGET_URL set WGET_URL=https://eternallybored.org/misc/wget/current/wget.exe

for %%i in ("%WGET_URL%") do set filename=%SystemRoot%\%%~nxi

REM First check if we have access to our download tool script. If we
REM do have it, then we need to deploy it to our SystemRoot if it
REM hasn't been deployed yet. If not, then we need to do everything
REM we can to snag it.
if not exist "%~dp0\_download.cmd" goto _download_cmd_not_found
copy /y "%~dp0\_download.cmd" "%SystemRoot%\_download.cmd"

REM Now that we have setup our download script, try and use it to
REM download wget.exe into our SystemRoot. If this fails, then we've
REM already tried every available download method in an attempt to
REM bootstrap wget.exe. In this case (since there's no point in
REM repeating ourselves) we fall back to using the curl binary that
REM came on the floppy disk mounted by packer.
call "%~dp0\_download.cmd" "%WGET_URL%" "%filename%"

if errorlevel 1 (
  echo ==^> ERROR: Unable to bootstrap wget from %WGET_URL%
  goto floppy_curl
)
goto check_wget_bootstrapped

REM It was determined that our download script doesn't exist, so we
REM need to try all of things things the download script would
REM normally do in order to try and bootstrap wget.exe.
:_download_cmd_not_found
echo ==^> Downloading "%WGET_URL%" to "%filename%"

REM First try downloading it with Powershell. If that fails, then
REM try bitsadmin next.
:powershell
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%WGET_URL%', '%filename%')" <NUL

if errorlevel 1 (
  echo ==^> ERROR: Unable to bootstrap wget using powershell from %WGET_URL%
  goto check_bitsadmin
)

if not exist "%filename%" goto check_bitsadmin

goto check_wget_bootstrapped

REM Next we'll try using bitsadmin.exe if the user hasn't disabled
REM it. To do this, we first have to search through our path for it.
REM If anything fails, then we fall back to using the instance of
REM curl.exe that was included in the floppy during boot.
:check_bitsadmin
if defined DISABLE_BITS (
    if "%DISABLE_BITS%" == "1" if not exist "%filename%" goto floppy_curl
)

set bitsadmin=
for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe
if not exist "%bitsadmin%" goto floppy_curl

REM Use the filename to create a job for bitsadmin to begin its transfer. There
REM is unfortunately no good way to check if bitsadmin has failed other than
REM checking if the file exists or not. So we do this to verify if we were
REM actually successful.
:bitsadmin
for %%i in ("%filename%") do set jobname=%%~nxi
"%bitsadmin%" /transfer "%jobname%" "%WGET_URL%" "%filename%"

if not exist "%filename%" (
  echo ==^> ERROR: Unable to download file using bitsadmin from %WGET_URL%
  goto floppy_curl
)

goto check_wget_bootstrapped

REM Check to see if we can actually run wget on this platform.. If
REM so, then we're done and can exit. If we're unable to, then
REM we'll have to use the 3rdparty curl.exe that was included on
REM our floppy disk.
:check_wget_bootstrapped

"%filename%" --version >NUL 2>NUL
if errorlevel 1 goto floppy_curl

goto exit0

REM We absolutely could not bootstrap wget.exe from the internet,
REM using all of our available methods. This means that we have
REM no choice but to fall back to using the curl.exe that came
REM on the floppy disk that packer has mounted. First we search
REM the path or it, and then copy it into SystemRoot. This way
REM the _download.cmd script will be able to find it as a sort
REM of last resort.
:floppy_curl
set curl=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined curl @if exist "%%~i\curl.exe" set curl=%%~i\curl.exe

for %%i in ("%curl%") do set curl_path=%SystemRoot%\%%~nxi

if not defined curl (
  echo ==^> FATAL: Unable to find curl.exe anywhere. Giving up.
  goto exit1
)

copy /y "%curl%" "%curl_path%"
if errorlevel 1 (
  echo ==^> FATAL: Unable to copy file from "%curl%" to "%curl_path%". Giving up.
  goto exit1
)

goto exit0

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
