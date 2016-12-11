@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)


if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

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

if not defined CHEF_URL if "%CM_VERSION%" == "latest" set CM_VERSION=12.16.42

:: srtrip -1 if %CM_VERSION% ends in -1
set CM_VERSION=%CM_VERSION:-1=%

set "omnitruck_x86_url=https://omnitruck.chef.io/stable/chef/metadata?p=windows&pv=2008r2&m=x86&v=%CM_VERSION%"
if defined http_proxy (
    powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('%omnitruck_x86_url%', '%temp%\omnitruck_x86.txt')" >nul
) else (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%omnitruck_x86_url%', '%temp%\omnitruck_x86.txt')" >nul
)

if not exist "%temp%\omnitruck_x86.txt" (
  echo Could not get chef-client %CM_VERSION% x86 download url...
) else (
  for /f "tokens=2 usebackq" %%a in (`findstr "url" "%temp%\omnitruck_x86.txt"`) do (
    if not defined CHEF_URL set CHEF_32_URL=%%a
  )
)

if not defined CHEF_URL if defined ProgramFiles(x86) (
    set "omnitruck_x64_url=https://omnitruck.chef.io/stable/chef/metadata?p=windows&pv=2008r2&m=x64&v=%CM_VERSION%"
    if defined http_proxy (
        powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('!omnitruck_x64_url!', '%temp%\omnitruck_x64.txt')" >nul
    ) else (
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('!omnitruck_x64_url!', '%temp%\omnitruck_x64.txt')" >nul
    )

    if not exist "%temp%\omnitruck_x64.txt" (
        echo Could not get chef-client %CM_VERSION% x64 download url...
    ) else (
        for /f "tokens=2 usebackq" %%a in (`findstr "url" "%temp%\omnitruck_x64.txt"`) do (
            if not defined CHEF_URL set CHEF_64_URL=%%a
        )
    )
)

if defined CHEF_64_URL (
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
  echo ==^> Downloading %CHEF_URL% to %CHEF_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"%CHEF_URL%\", '%CHEF_PATH%')" <NUL
)
if not exist "%CHEF_PATH%" goto exit1

exit

echo ==^> Installing Chef client %CM_VERSION%
msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%
ver>nul

goto exit0

::::::::::::
:chefdk
::::::::::::

if not defined CHEFDK_URL if "%CM_VERSION%" == "latest" set CM_VERSION=1.0.3

:: srtrip -1 if %CM_VERSION% ends in -1
set CM_VERSION=%CM_VERSION:-1=%

set "omnitruck_x86_url=https://omnitruck.chef.io/stable/chefdk/metadata?p=windows&pv=2008r2&m=x86&v=%CM_VERSION%"
if defined http_proxy (
    powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('%omnitruck_x86_url%', '%temp%\omnitruck_x86.txt')" >nul
) else (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%omnitruck_x86_url%', '%temp%\omnitruck_x86.txt')" >nul
)

if not exist "%temp%\omnitruck_x86.txt" (
  echo Could not get chefdk %CM_VERSION% x86 download url...
) else (
  for /f "tokens=2 usebackq" %%a in (`findstr "url" "%temp%\omnitruck_x86.txt"`) do (
    if not defined CHEFDK_URL set CHEFDK_32_URL=%%a
  )
)

if not defined CHEFDK_URL if defined ProgramFiles(x86) (
    set "omnitruck_x64_url=https://omnitruck.chef.io/stable/chefdk/metadata?p=windows&pv=2008r2&m=x64&v=%CM_VERSION%"
    if defined http_proxy (
        powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('!omnitruck_x64_url!', '%temp%\omnitruck_x64.txt')" >nul
    ) else (
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('!omnitruck_x64_url!', '%temp%\omnitruck_x64.txt')" >nul
    )

    if not exist "%temp%\omnitruck_x64.txt" (
        echo Could not get chefdk %CM_VERSION% x64 download url...
    ) else (
        for /f "tokens=2 usebackq" %%a in (`findstr "url" "%temp%\omnitruck_x64.txt"`) do (
            if not defined CHEFDK_URL set CHEFDK_64_URL=%%a
        )
    )
)
if defined CHEFDK_64_URL (
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
  echo ==^> Downloading %CHEFDK_URL% to %CHEFDK_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"%CHEFDK_URL%\", '%CHEFDK_PATH%')" <NUL
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

if not defined PUPPET_64_URL set PUPPET_URL=https://downloads.puppetlabs.com/windows/puppet-x64-%CM_VERSION%.msi
if not defined PUPPET_32_URL set PUPPET_URL=https://downloads.puppetlabs.com/windows/puppet-%CM_VERSION%.msi

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
