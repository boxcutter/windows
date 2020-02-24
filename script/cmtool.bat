@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1

if "%CM%" == "nocm"   goto nocm

if not defined CM_VERSION echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment & set CM_VERSION=latest

if "%CM%" == "chef"   goto chef
if "%CM%" == "chefdk" goto chefdk
if "%CM%" == "puppet" goto puppet
if "%CM%" == "salt"   goto salt

echo ==^> ERROR: Unknown value for environment variable CM: "%CM%"

goto exit1

::::::::::::
:chef
::::::::::::

if not defined CHEF_URL if "%CM_VERSION%" == "latest" set CM_VERSION=13.6.4
if not defined CHEF_URL set CHEF_64_URL=https://packages.chef.io/files/stable/chef/%CM_VERSION%/windows/2008r2/chef-client-%CM_VERSION%-1-x64.msi
if not defined CHEF_URL set CHEF_32_URL=https://packages.chef.io/files/stable/chef/%CM_VERSION%/windows/2008r2/chef-client-%CM_VERSION%-1-x86.msi

if defined ProgramFiles(x86) (
  SET CHEF_URL=%CHEF_64_URL%
) else (
  SET CHEF_URL=%CHEF_32_URL%
)

for %%i in ("%CHEF_URL%") do set CHEF_MSI=%%~nxi
set CHEF_DIR=%TEMP%\chef
set CHEF_PATH=%CHEF_DIR%\%CHEF_MSI%

echo ==^> Creating "%CHEF_DIR%"
mkdir "%CHEF_DIR%"
pushd "%CHEF_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEF_URL%" "%CHEF_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%CHEF_URL%" "%CHEF_PATH%"
)
if not exist "%CHEF_PATH%" goto exit1

echo ==^> Installing Chef client %CM_VERSION%
msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%
ver>nul

goto exit0

::::::::::::
:chefdk
::::::::::::

if not defined CHEFDK_URL if "%CM_VERSION%" == "latest" set CM_VERSION=2.3.4
if not defined CHEFDK_URL set CHEFDK_64_URL=https://packages.chef.io/files/stable/chefdk/%CM_VERSION%/windows/2008r2/chefdk-%CM_VERSION%-1-x86.msi
if not defined CHEFDK_URL set CHEFDK_32_URL=https://packages.chef.io/files/stable/chefdk/%CM_VERSION%/windows/2008r2/chefdk-%CM_VERSION%-1-x86.msi

if defined ProgramFiles(x86) (
  SET CHEFDK_URL=%CHEFDK_64_URL%
) else (
  SET CHEFDK_URL=%CHEFDK_32_URL%
)

for %%i in ("%CHEFDK_URL%") do set CHEFDK_MSI=%%~nxi
set CHEFDK_DIR=%TEMP%\chefdk
set CHEFDK_PATH=%CHEFDK_DIR%\%CHEFDK_MSI%

echo ==^> Creating "%CHEFDK_DIR%"
mkdir "%CHEFDK_DIR%"
pushd "%CHEFDK_DIR%"

echo ==^> Downloading Chef DK to %CHEFDK_PATH%
if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEFDK_URL%" "%CHEFDK_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%CHEFDK_URL%" "%CHEFDK_PATH%"
)
if not exist "%CHEFDK_PATH%" goto exit1

echo ==^> Installing Chef Development Kit %CM_VERSION%
msiexec /qb /i "%CHEFDK_PATH%" /l*v "%CHEFDK_DIR%\chef.log" %CHEFDK_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEFDK_PATH%" /l*v "%CHEFDK_DIR%\chef.log" %CHEFDK_OPTIONS%
ver>nul

goto exit0

::::::::::::
:puppet
::::::::::::

:: if "%CM_VERSION%" == "latest" set CM_VERSION=3.8.7

if not defined PUPPET_URL set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet-x64-%CM_VERSION%.msi
if not defined PUPPET_URL set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet-%CM_VERSION%.msi

if defined ProgramFiles(x86) (
  set PUPPET_URL=%PUPPET_64_URL%
) else (
  set PUPPET_URL=%PUPPET_32_URL%
)

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
  call %SystemRoot%\_download_ps1.cmd "%PUPPET_URL%" "%PUPPET_PATH%"
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

if "%CM_VERSION%" == "latest" set CM_VERSION=2015.8.8-2

if not defined SALT_64_URL set SALT_64_URL=https://repo.saltstack.com/windows/Salt-Minion-%CM_VERSION%-AMD64-Setup.exe
if not defined SALT_32_URL set SALT_32_URL=https://repo.saltstack.com/windows/Salt-Minion-%CM_VERSION%-x86-Setup.exe

if defined ProgramFiles(x86) (
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

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SALT_URL%" "%SALT_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%SALT_URL%" "%SALT_PATH%"
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
