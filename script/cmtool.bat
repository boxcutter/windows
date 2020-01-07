@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined TEMP set TEMP=%LOCALAPPDATA%\Temp

if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1

if "%CM%" == "nocm"   goto nocm

if not defined CM_VERSION echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment & set CM_VERSION=latest

if "%CM%" == "chef" goto omnitruck
if "%CM%" == "chefdk" goto omnitruck
if "%CM%" == "chef-workstation" goto omnitruck
if "%CM%" == "puppet" goto puppet
if "%CM%" == "salt"   goto salt

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
) else if "%CM%" == "chefdk" (
  set "OMNITRUCK_PRODUCT=chefdk"
) else if "%CM%" == "chef-workstation" (
  set "OMNITRUCK_PRODUCT=chef-workstation"
) else (
  echo Unknown Chef Product: %CM%
  goto exit1
)

:: Deterine the other desired parameters here
if not defined OMNITRUCK_PLATFORM set OMNITRUCK_PLATFORM=windows
if not defined CM_LICENSED set CM_LICENSED=false

if "%CM_VERSION%" == "latest" if "%CM_LICENSED%" == "false" (
    echo ==^> Overriding 'CM_VERSION=latest' to the latest supported free version because CM_LICENSED=false
    if "%OMNITRUCK_PRODUCT%" == "chef-workstation" (
        set CM_VERSION=0.3.2
    ) else if "%OMNITRUCK_PRODUCT%" == "chefdk" (
        set CM_VERSION=3.12.10
    ) else if "%OMNITRUCK_PRODUCT%" == "chef" (
        set CM_VERSION=14.14.29
    )
)

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

echo "==^> Using Chef Omnitruck API URL: !url!"
powershell -command "(New-Object System.Net.WebClient).DownloadFile('!url!', '!filename!')"

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
echo "==^> Got %OMNITRUCK_PRODUCT% download URL: !CHEF_URL!"

goto chef

::::::::::::
:chef
::::::::::::

for %%i in ("%CHEF_URL%") do set CHEF_MSI=%%~nxi
set CHEF_DIR=%TEMP%\chef
set CHEF_PATH=%CHEF_DIR%\%CHEF_MSI%

echo ==^> Creating "%CHEF_DIR%"
mkdir "%CHEF_DIR%"
pushd "%CHEF_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEF_URL%" "%CHEF_PATH%"
) else (
  echo ==^> Downloading %CHEF_URL% to %CHEF_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"%CHEF_URL%\", '%CHEF_PATH%')" <NUL
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
