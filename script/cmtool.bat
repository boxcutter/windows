@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined TEMP set TEMP=%LOCALAPPDATA%\Temp

if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1

if "%CM%" == "nocm"   goto nocm

if not defined CM_VERSION echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment & set CM_VERSION=latest

if "%CM%" == "chef" goto chef
if "%CM%" == "chefdk" goto chef
if "%CM%" == "chef-workstation" goto chef
if "%CM%" == "puppet" goto puppet
if "%CM%" == "salt"   goto salt

echo ==^> ERROR: Unknown value for environment variable CM: "%CM%"

goto exit1

::::::::::::
:chef
::::::::::::
if "%CM%" == "chef" (
  set "CHEF_PRODUCT_NAME=Chef Client"
) else if "%CM%" == "chefdk" (
  set "CHEF_PRODUCT_NAME=Chef DK"
) else if "%CM%" == "chef-workstation" (
  set "CHEF_PRODUCT_NAME=Chef Workstation"
)

set CHEF_PRODUCT_VER=%CM_VERSION%

if not defined CHEF_URL if "%CHEF_PRODUCT_VER%" == "latest" (
    if "%CM%" == "chef-workstation" (
        set CHEF_PRODUCT_VER=0.2.48
    ) else if "%CM%" == "chefdk" (
        set CHEF_PRODUCT_VER=2.3.4
    ) else if "%CM%" == "chef" (
        set CHEF_PRODUCT_VER=13.6.4
    )
)

:: strip -1 if %CHEF_PRODUCT_VER% ends in -1
set CHEF_PRODUCT_VER=%CHEF_PRODUCT_VER:-1=%

if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set CHEF_ARCH=x86
) else (
  set CHEF_ARCH=x64
)

if not defined CHEF_URL (
    echo ==^> Getting %CHEF_PRODUCT_NAME% %CHEF_PRODUCT_VER% %CHEF_ARCH% download URL
    set url="https://omnitruck.chef.io/stable/%CM%/metadata?p=windows&pv=2012r2&m=%CHEF_ARCH%&v=%CHEF_PRODUCT_VER%"
    set filename="%TEMP%\omnitruck.txt"

    echo "==^> Using Chef Omitruck API URL: !url!"
    if defined http_proxy (
        if defined no_proxy (
            powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('!url!', '!filename!')"
        ) else (
            powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.DownloadFile('!url!', '!filename!')"
        )
    ) else (
        powershell -command "(New-Object System.Net.WebClient).DownloadFile('!url!', '!filename!')"
    )

    if not exist "%TEMP%\omnitruck.txt" (
        echo Could not get %CHEF_PRODUCT_NAME% %CHEF_PRODUCT_VER% %CHEF_ARCH% download url...
    ) else (
      for /f "tokens=2 usebackq" %%a in (`findstr "url" "%TEMP%\omnitruck.txt"`) do (
          set CHEF_URL=%%a
      )
    )

    if not defined CHEF_URL (
      echo Could not get %CHEF_PRODUCT_NAME% %CHEF_PRODUCT_VER% %CHEF_ARCH% download url...
      goto exit1
    )
    echo "==^> Got %CHEF_PRODUCT_NAME% download URL: !CHEF_URL!"
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
  echo ==^> Downloading %CHEF_PRODUCT_NAME% to %CHEF_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"%CHEF_URL%\", '%CHEF_PATH%')" <NUL
)
if not exist "%CHEF_PATH%" goto exit1

echo ==^> Installing %CHEF_PRODUCT_NAME% %CHEF_PRODUCT_VER% %CHEF_ARCH%
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
