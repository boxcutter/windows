@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1
if not defined CM_VERSION echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment
if not defined CM_VERSION set CM_VERSION=latest

if "%CM%" == "chef"   goto chef
if "%CM%" == "puppet" goto puppet
if "%CM%" == "salt"   goto salt
if "%CM%" == "nocm"   goto nocm

echo ==^> ERROR: Unknown value for environment variable CM: "%CM%"

goto exit1

::::::::::::
:chef
::::::::::::

if not defined CHEF_URL if "%CM_VERSION%" == "latest" set CHEF_URL=https://www.getchef.com/chef/install.msi
if not defined CHEF_URL set CHEF_URL=https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-client-%CM_VERSION%.windows.msi

set CHEF_MSI=chef-client-latest.msi
set CHEF_DIR=%TEMP%\chef
set CHEF_PATH=%CHEF_DIR%\%CHEF_MSI%

echo ==^> Creating "%CHEF_DIR%"
mkdir "%CHEF_DIR%"
pushd "%CHEF_DIR%"

:: todo support CM_VERSION variable
if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEF_URL%" "%CHEF_PATH%"
) else (
  echo ==^> Downloading %CHEF_URL% to %CHEF_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%CHEF_URL%', '%CHEF_PATH%')" <NUL
)
if not exist "%CHEF_PATH%" goto exit1

echo ==^> Installing Chef client %CM_VERSION%
msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log"  %CHEF_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log"  %CHEF_OPTIONS%
ver>nul

goto exit0

::::::::::::
:puppet
::::::::::::

if "%CM_VERSION%" == "latest" set CM_VERSION=3.6.1

if not defined PUPPET_URL set PUPPET_URL=http://downloads.puppetlabs.com/windows/puppet-%CM_VERSION%.msi

for %%i in ("%PUPPET_URL%") do set PUPPET_MSI=%%~nxi
set PUPPET_DIR=%TEMP%\puppet
set PUPPET_PATH=%PUPPET_DIR%\%PUPPET_MSI%

echo ==^> Creating "%PUPPET_DIR%"
mkdir "%PUPPET_DIR%"
pushd "%PUPPET_DIR%"

:: todo support CM_VERSION variable
if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%PUPPET_URL%" "%PUPPET_PATH%"
) else (
  echo ==^> Downloading %PUPPET_URL% to %PUPPET_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PUPPET_URL%', '%PUPPET_PATH%')" <NUL
)
if not exist "%PUPPET_PATH%" goto exit1

echo ==^> Installing Puppet client %CM_VERSION%
:: see http://docs.puppetlabs.com/pe/latest/install_windows.html
msiexec /qb /i "%PUPPET_PATH%" /l*v "%PUPPET_DIR%\puppet.log" %PUPPET_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%PUPPET_PATH%" /l*v "%PUPPET_DIR%\puppet.log" %PUPPET_OPTIONS%
ver>nul

goto exit0

::::::::::::
:salt
::::::::::::

if "%CM_VERSION%" == "latest" set CM_VERSION=2014.1.4

if not defined SALT_32_URL set SALT_32_URL=https://docs.saltstack.com/downloads/Salt-Minion-%CM_VERSION%-win32-Setup.exe
if not defined SALT_64_URL set SALT_64_URL=https://docs.saltstack.com/downloads/Salt-Minion-%CM_VERSION%-AMD64-Setup.exe

if exist "%SystemDrive%\Program Files (x86)" (
  set SALT_URL=%SALT_64_URL%
) else (
  set SALT_URL=%SALT_32_URL%
)

for %%i in ("%SALT_URL%") do set SALT_EXE=%%~nxi
set SALT_DIR=%TEMP%\salt
set SALT_PATH=%SALT_DIR%\%SALT_EXE%

echo ==^> Creating "%SALT_DIR%"
mkdir "%SALT_DIR%"
pushd "%SALT_DIR%"

:: todo support CM_VERSION variable
if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SALT_URL%" "%SALT_PATH%"
) else (
  echo ==^> Downloading %SALT_URL% to %SALT_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SALT_URL%', '%SALT_PATH%')" <NUL
)
if not exist "%SALT_PATH%" goto exit1

echo ==^> Installing Salt minion
:: see http://docs.saltstack.com/en/latest/topics/installation/windows.html
"%SALT_PATH%" /S %SALT_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%SALT_PATH%" /S %SALT_OPTIONS%
ver>nul

goto exit0

::::::::::::
:nocm
::::::::::::

echo ==^> Building box without a configuration management tool

goto exit0

:exit1

verify other 2>nul

goto :exit

:exit0

ver>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
