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

REM Now that we have setup our download tool script, try and use
REM it to download wget.exe into our SystemRoot. If this fails,
REM then we fall back to using the wget.exe from the floppy.
call "%~dp0\_download.cmd" "%WGET_URL%" "%filename%"

if errorlevel 1 (
  echo ==^> ERROR: Unable to bootstrap wget from %WGET_URL%
  goto floppy_wget
)
goto check_wget_bootsrapped

REM We don't have a script to use for downloading, so we need to try
REM all of the things it would do to try and bootstrap wget.exe.
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
REM wget.exe that was included in the floppy during boot.
:check_bitsadmin
if defined DISABLE_BITS (
    if "%DISABLE_BITS%" == "1" if not exist "%filename%" goto floppy_wget
)

set bitsadmin=
for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe
if not exist "%bitsadmin%" goto floppy_wget

REM Use the filename to create a job for bitsadmin to begin its transfer.
:bitsadmin
for %%i in ("%filename%") do set jobname=%%~nxi
"%bitsadmin%" /transfer "%jobname%" "%WGET_URL%" "%filename%"

if errorlevel 1 (
  echo ==^> ERROR: Unable to download file using bitsadmin from %WGET_URL%
  goto floppy_wget
)

if not exist "%filename%" goto floppy_wget

goto check_wget_bootstrapped

REM Check to see if we can actually run it on this platform.. If
REM so, then we're done and can exit. If we're unable to, then
REM we'll have to use the 3rdparty wget.exe that was included on
REM our floppy disk.
:check_wget_bootstrapped

"%filename%" --version >NUL 2>NUL
if errorlevel 1 goto floppy_wget

goto exit0

REM We absolutely could not bootstrap wget.exe from the internet,
REM so we have no choice but to fall back to deploying the one
REM that came on the floppy that was mounted by packer. Copy it
REM to %filename% and then check it.
:floppy_wget
set wget=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined wget @if exist "%%~i\wget.exe" set wget=%%~i\wget.exe

if not defined wget (
  echo ==^> FATAL: Unable to find wget.exe anywhere. Giving up.
  goto exit1
)

copy /y "%wget%" "%filename%"
if errorlevel 1 (
  echo ==^> FATAL: Unable to copy file from "%wget%" to "%filename%". Giving up.
  goto exit1
)

goto exit0

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
