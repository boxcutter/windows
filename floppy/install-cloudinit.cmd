@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Cloud Init.  Please wait...

set CLOUDINIT_SERVICE=cloudbase-init
set CLOUDINIT_USER=cloudbase-init

echo ==^> Determining Cloud Init installer URL
if not defined CLOUDINIT_64_URL set CLOUDINIT_64_URL=https://www.cloudbase.it/downloads/CloudbaseInitSetup_x64.msi
if not defined CLOUDINIT_32_URL set CLOUDINIT_32_URL=https://www.cloudbase.it/downloads/CloudbaseInitSetup_x86.msi
set CLOUDINIT_URL=%CLOUDINIT_32_URL%
if defined ProgramFiles(x86) set CLOUDINIT_URL=%CLOUDINIT_64_URL%

for %%i in (%CLOUDINIT_URL%) do set CLOUDINIT_EXE=%%~nxi
set CLOUDINIT_DIR=%TEMP%\cloudinit
set CLOUDINIT_PATH=%CLOUDINIT_DIR%\%CLOUDINIT_EXE%

echo ==^> Creating "%CLOUDINIT_DIR%"
mkdir "%CLOUDINIT_DIR%"
pushd "%CLOUDINIT_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CLOUDINIT_URL%" "%CLOUDINIT_PATH%"
) else (
  echo ==^> Downloading "%CLOUDINIT_URL%" to "%CLOUDINIT_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%CLOUDINIT_URL%', '%CLOUDINIT_PATH%')" <NUL
)
if not exist "%CLOUDINIT_PATH%" goto exit1

echo ==^> Installing Cloud Init
"%CLOUDINIT_PATH%" /quiet /norestart

echo ==^> Disabling account password expiration for user "%CLOUDINIT_USER%"
wmic USERACCOUNT WHERE "Name='%CLOUDINIT_USER%'" set PasswordExpires=FALSE

sc query %CLOUDINIT_SERVICE% | findstr "RUNNING" >nul
if errorlevel 1 goto cloudinit_not_running

echo ==^> Stopping the Cloud Init Service
sc stop %CLOUDINIT_SERVICE%

:is_cloudinit_running

timeout 1

sc query %CLOUDINIT_SERVICE% | findstr "STOPPED" >nul
if errorlevel 1 goto is_cloudinit_running

:cloudinit_not_running
ver>nul

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
