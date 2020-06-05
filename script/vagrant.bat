@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Downloading and deploying vagrant public key.  Please wait...

if not exist "%SystemRoot%\_download.cmd" (
  echo ==^> ERROR: Unable to download and deploy vagrant public key due to missing download tool
  goto :exit1
)

if not defined VAGRANT_PUB_URL set VAGRANT_PUB_URL=https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub

for %%i in ("%VAGRANT_PUB_URL%") do set VAGRANT_PUB=%%~nxi
set VAGRANT_DIR=%TEMP%\vagrant
set VAGRANT_PATH=%VAGRANT_DIR%\%VAGRANT_PUB%
set AUTHORIZED_KEYS=%USERPROFILE%\.ssh\authorized_keys

echo ==^> Creating "%VAGRANT_DIR%"
mkdir "%VAGRANT_DIR%"
pushd "%VAGRANT_DIR%"

call "%SystemRoot%\_download.cmd" "%VAGRANT_PUB_URL%" "%VAGRANT_PATH%"
if errorlevel 1 (
  echo ==^> ERROR: Unable to download file %VAGRANT_PUB_URL%
  goto exit1
)

if not exist "%VAGRANT_PATH%" goto exit1

echo ==^> Creating "%USERPROFILE%\.ssh"
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

echo ==^> Adding "%VAGRANT_PATH%" to "%AUTHORIZED_KEYS%"
type "%VAGRANT_PATH%" >>"%AUTHORIZED_KEYS%"

if "%USERNAME%" == "sshd_server" for %%i in (%USERPROFILE%) do set USERNAME=%%~ni

echo ==^> Disabling account password expiration for user "%USERNAME%"
wmic USERACCOUNT WHERE "Name='%USERNAME%'" set PasswordExpires=FALSE

:exit0

@ping 127.0.0.1
@ver>nul

@goto :exit

:exit1

@ping 127.0.0.1
@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%


