@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

:: Get the PlatformVersion from SystemInfo
for /f "delims=:; tokens=1,2" %%a in ('systeminfo') do (
  if "%%a" == "OS Version" set PlatformVersionRow=%%b
)

:: Extract the major/minor version (stripped)
for /f "delims=.; tokens=1,2" %%a in ("%PlatformVersionRow%") do (
  for /f "tokens=*" %%v in ("%%a") do set PlatformVersionMajor=%%v
  for /f "tokens=*" %%v in ("%%b") do set PlatformVersionMinor=%%v
)

echo ==^> Detected Windows Platform Version: %PlatformVersionMajor%.%PlatformVersionMinor%

:: Set some reasonable defaults
if not defined TEMP set TEMP=%LOCALAPPDATA%\Temp

:: Figure out which configuration management tool to use
if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1
if "%CM%" == "nocm" goto nocm

if not defined CM_VERSION (
  echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment
  set CM_VERSION=latest
)

if "%CM%" == "chef" goto omnitruck
if "%CM%" == "chefdk" goto omnitruck
if "%CM%" == "chef-workstation" goto omnitruck
if "%CM%" == "puppet" goto puppet
if "%CM%" == "salt" goto salt

echo ==^> ERROR: Unknown value for environment variable CM: "%CM%"

goto exit1

::::::::::::
:omnitruck
::::::::::::

:: If we already have the CHEF_URL, then we don't need to use Omnitruck and we can move on
if defined CHEF_URL goto chef

:: Determine each component for using the Omnitruck API to get the desired Chef component
if not defined OMNITRUCK_CHANNEL set OMNITRUCK_CHANNEL=stable

:: Figure out the Omnitruck product
if "%CM%" == "chef" (
  set "OMNITRUCK_PRODUCT=chef"
  set "OMNITRUCK_FREE_VERSION=14.14.29"
) else if "%CM%" == "chefdk" (
  set "OMNITRUCK_PRODUCT=chefdk"
  set "OMNITRUCK_FREE_VERSION=3.12.10"
) else if "%CM%" == "chef-workstation" (
  set "OMNITRUCK_PRODUCT=chef-workstation"
  set "OMNITRUCK_FREE_VERSION=0.3.2"
) else (
  echo Unknown Chef Product: %CM%
  goto exit1
)

:: Check the CM_VERSION that the user specified..
if "%CM_VERSION%" == "latest" (
    :: ...and let them know if they chose the most recent free version.
    echo ==^> User has chosen the most recent free version of %OMNITRUCK_PRODUCT%
    set OMNITRUCK_VERSION=%OMNITRUCK_FREE_VERSION%

) else if "%CM_VERSION%" == "licensed" (
    :: ...or the most recent licensed version.
    echo ==^> User has chosen the most recent licensed version of %OMNITRUCK_PRODUCT%
    set OMNITRUCK_VERSION=latest

) else if defined OMNITRUCK_VERSION (
    :: ...or their own version if they explicitly set an environment variable
    echo ==^> User has explicitly chosen the version %OMNITRUCK_VERSION% for %OMNITRUCK_PRODUCT%
)

:: Deterine the other desired parameters here
if not defined OMNITRUCK_PLATFORM set OMNITRUCK_PLATFORM=windows
if not defined OMNITRUCK_VERSION set OMNITRUCK_VERSION=%CM_VERSION%

if not defined OMNITRUCK_MACHINE_ARCH (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    set OMNITRUCK_MACHINE_ARCH=x86
  ) else (
    set OMNITRUCK_MACHINE_ARCH=x64
  )
)

:: We exclude the platform version as the Omnitruck API doesn't seem to use this
:: set OMNITRUCK_PLATFORM_VERSION=

:: strip -1 if %OMNITRUCK_VERSION% ends in -1
set OMNITRUCK_VERSION=%OMNITRUCK_VERSION:-1=%

:: Use the Omnitruck API to determine the CHEF_URL
echo ==^> Getting %OMNITRUCK_PRODUCT% %OMNITRUCK_VERSION% %OMNITRUCK_MACHINE_ARCH% download URL
set url="https://omnitruck.chef.io/%OMNITRUCK_CHANNEL%/%OMNITRUCK_PRODUCT%/metadata?p=%OMNITRUCK_PLATFORM%&m=%OMNITRUCK_MACHINE_ARCH%&v=%OMNITRUCK_VERSION%"
set filename="%TEMP%\omnitruck.txt"

echo ==^> Using Chef Omnitruck API URL: !url!
call "%SystemRoot%\_download.cmd" !url! !filename!

if not exist "%TEMP%\omnitruck.txt" (
  echo Unable to download metadata for %OMNITRUCK_PRODUCT% %OMNITRUCK_VERSION% on the %OMNITRUCK_CHANNEL% channel for %OMNITRUCK_PLATFORM% %OMNITRUCK_MACHINE_ARCH%

) else (
  for /f "tokens=2 usebackq" %%a in (`findstr "url" "%TEMP%\omnitruck.txt"`) do (
      set CHEF_URL=%%a
  )
)

if not defined CHEF_URL (
  echo Could not determine the %OMNITRUCK_PRODUCT% %OMNITRUCK_VERSION% download url...
  goto exit1
)
echo ==^> Got %OMNITRUCK_PRODUCT% download URL: !CHEF_URL!

goto chef

::::::::::::
:chef
::::::::::::
if not defined CHEF_OPTIONS set CHEF_OPTIONS=%CM_OPTIONS%

for %%i in ("%CHEF_URL%") do set CHEF_MSI=%%~nxi
set CHEF_DIR=%TEMP%\chef
set CHEF_PATH=%CHEF_DIR%\%CHEF_MSI%

echo ==^> Creating "%CHEF_DIR%"
mkdir "%CHEF_DIR%"
pushd "%CHEF_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEF_URL%" "%CHEF_PATH%"
)
if not exist "%CHEF_PATH%" goto exit1

echo ==^> Installing %CM% %CM_VERSION%
msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%
ver>nul

goto exit0

::::::::::::
:puppet
::::::::::::
if not defined PUPPET_OPTIONS set PUPPET_OPTIONS=%CM_OPTIONS%

if defined PUPPET_URL goto puppetinstall

:: If we're using the latest, then hardcode the 32-bit/64-bit urls and install
if "%CM_VERSION%" == "latest" (
    set PUPPET_32_URL=https://downloads.puppetlabs.com/windows/puppet/puppet-agent-x86-latest.msi
    set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet/puppet-agent-x64-latest.msi
    goto puppetinstall
)

:: Figure out the major version requested by the user
for /f "delims=." %%v in ("%CM_VERSION%") do set PUPPET_MAJOR_VERSION=%%v

:: Now we can use it to figure out the correct url format for that version
if "%PUPPET_MAJOR_VERSION%" == "1" goto puppet1
if "%PUPPET_MAJOR_VERSION%" == "5" goto puppet5
goto puppetlatest

::::::::::::
:puppet1
::::::::::::
if not defined PUPPET_URL set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet-agent-%CM_VERSION%-x64.msi
if not defined PUPPET_URL set PUPPET_32_URL=https://downloads.puppetlabs.com/windows/puppet-agent-%CM_VERSION%-x86.msi
goto puppetinstall

::::::::::::
:puppet5
::::::::::::
if not defined PUPPET_URL set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-%CM_VERSION%-x64.msi
if not defined PUPPET_URL set PUPPET_32_URL=https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-%CM_VERSION%-x86.msi
goto puppetinstall

::::::::::::
:puppetlatest
::::::::::::
if not defined PUPPET_URL set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet/puppet-agent-%CM_VERSION%-x64.msi
if not defined PUPPET_URL set PUPPET_32_URL=https://downloads.puppetlabs.com/windows/puppet/puppet-agent-%CM_VERSION%-x86.msi
goto puppetinstall

::::::::::::
:puppetinstall
::::::::::::
if not defined PUPPET_URL (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    set PUPPET_URL=%PUPPET_32_URL%
  ) else (
    set PUPPET_URL=%PUPPET_64_URL%
  )
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
if not defined SALT_OPTIONS set SALT_OPTIONS=%CM_OPTIONS%
if not defined SALT_REVISION set SALT_REVISION=stable

set SALT_DIR=%TEMP%\salt
echo ==^> Creating "%SALT_DIR%"
mkdir "%SALT_DIR%"
pushd "%SALT_DIR%"

:: If we're on a platform where salt-bootstrap is buggy, then fall back to just
:: using the regular salt-repository method.
if "%PlatformVersionMajor%" == "5" goto saltrepository
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "0" goto saltrepository
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "1" goto saltrepository

::::::::::::
:saltbootstrap
::::::::::::

:: We hardcode the CM_VERSION here to workaround saltstack/salt-bootstrap#1394
if "%CM_VERSION%" == "latest" set CM_VERSION=2019.2.2

set SALT_URL=http://raw.githubusercontent.com/saltstack/salt-bootstrap/%SALT_REVISION%/bootstrap-salt.ps1

set SALT_PATH=%SALT_DIR%\bootstrap-salt.ps1
set SALT_DOWNLOAD=%SALT_DIR%\bootstrap-salt.download.ps1

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SALT_URL%" "%SALT_DOWNLOAD%"
)

if not exist "%SALT_DOWNLOAD%" goto exit1
echo ==^> Patching bootstrap-salt.ps1 at %SALT_DOWNLOAD%
powershell -command "(get-content \"%SALT_DOWNLOAD%\") -replace \"'Tls,Tls11,Tls12'\", \"0xc0,0x300,0xc00\" | set-content \"%SALT_PATH%\""

echo ==^> Installing Salt minion with %SALT_PATH%
if "%CM_VERSION%" == "latest" (
  powershell "%SALT_PATH%" %SALT_OPTIONS%
) else (
  powershell "%SALT_PATH%" -version "%CM_VERSION%" %SALT_OPTIONS%
)

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%SALT_PATH%" -version "%CM_VERSION%" %SALT_OPTIONS%
ver>nul

goto exit0

::::::::::::
:saltrepository
::::::::::::

if not defined SALT_PYTHONVERSION set SALT_PYTHONVERSION=Py3

if not defined SALT_ARCH (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    set SALT_ARCH=x86
  ) else (
    set SALT_ARCH=AMD64
  )
)

if "%CM_VERSION%" == "latest" (
  set SALT_URL=http://repo.saltstack.com/windows/Salt-Minion-Latest-%SALT_PYTHONVERSION%-%SALT_ARCH%-Setup.exe
) else (
  set SALT_URL=http://repo.saltstack.com/windows/Salt-Minion-%CM_VERSION%-%SALT_PYTHONVERSION%-%SALT_ARCH%-Setup.exe
)

set SALT_PATH=%SALT_DIR%\Salt-Minion-Setup.exe

echo ==^> Downloading %SALT_URL% to %SALT_PATH%
call "%SystemRoot%\_download.cmd" %SALT_URL% %SALT_PATH%

echo ==^> Installing Salt minion %CM_VERSION%-%SALT_PYTHONVERSION% with %SALT_PATH%

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
