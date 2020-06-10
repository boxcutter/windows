@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

:: https://support.microsoft.com/en-us/help/2999226/update-for-universal-c-runtime-in-windows
title Downloading and installing required Windows Update (KB2999226).  Please wait...

:: Check for all of our prerequisites needed to install KB2999226
if not exist "%SystemRoot%\_download.cmd" (
  echo ==^> ERROR: Unable to download required Windows Update ^(KB2999226^) due to missing download tool
  goto :exit1
)

where wusa.exe >NUL
if errorlevel 1 (
  echo ==^> ERROR: Unable to locate Windows Update Standalone Installer
  goto exit1
)

where dism.exe >NUL
if errorlevel 1 (
  echo ==^> ERROR: Unable to locate Deployment Image Servicing and Management tool
  goto exit1
)

:: Set the default urls that are used by this script to download the update
set "KB2999226_WIN7X86_URL=https://download.microsoft.com/download/4/F/E/4FE73868-5EDD-4B47-8B33-CE1BB7B2B16A/Windows6.1-KB2999226-x86.msu"
set "KB2999226_WIN7X64_URL=https://download.microsoft.com/download/1/1/5/11565A9A-EA09-4F0A-A57E-520D5D138140/Windows6.1-KB2999226-x64.msu"
set "KB2999226_WIN80X86_URL=https://download.microsoft.com/download/1/E/8/1E8AFE90-5217-464D-9292-7D0B95A56CE4/Windows8-RT-KB2999226-x86.msu"
set "KB2999226_WIN80X64_URL=https://download.microsoft.com/download/A/C/1/AC15393F-A6E6-469B-B222-C44B3BB6ECCC/Windows8-RT-KB2999226-x64.msu"
set "KB2999226_WIN81X86_URL=https://download.microsoft.com/download/E/4/6/E4694323-8290-4A08-82DB-81F2EB9452C2/Windows8.1-KB2999226-x86.msu"
set "KB2999226_WIN81X64_URL=https://download.microsoft.com/download/9/6/F/96FD0525-3DDF-423D-8845-5F92F4A6883E/Windows8.1-KB2999226-x64.msu"
set "KB2999226_WIN2008X86_URL=https://download.microsoft.com/download/B/5/7/B5757251-DAB0-4E23-AA46-ABC233FDB90E/Windows6.0-KB2999226-x86.msu"
set "KB2999226_WIN2008X64_URL=https://download.microsoft.com/download/A/7/A/A7A70B17-ADF9-4FC3-A722-69FA89B79756/Windows6.0-KB2999226-x64.msu"
set "KB2999226_WIN2008R2_URL=https://download.microsoft.com/download/F/1/3/F13BEC9A-8FC6-4489-9D6A-F84BDC9496FE/Windows6.1-KB2999226-x64.msu"
set "KB2999226_WIN2012_URL=https://download.microsoft.com/download/9/3/E/93E0745A-EAE9-4B5A-B50C-012F2D3B6659/Windows8-RT-KB2999226-x64.msu"
set "KB2999226_WIN2012R2_URL=https://download.microsoft.com/download/D/1/3/D13E3150-3BB2-4B22-9D8A-47EE2D609FFF/Windows8.1-KB2999226-x64.msu"

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

:: Set some reasonable defaults for where to put the downloaded update.
if not defined TEMP set TEMP=%LOCALAPPDATA%\Temp

:: Figure out the platform version in order to determine the correct url
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "0" goto Windows2008
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "1" goto Windows7Family
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "2" goto Windows80Family
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "3" goto Windows81Family

echo ==^> Skipping Windows Update ^(KB2999226^) due to it being non-applicable to the current platform
goto exit0

:: We figured out that we're in the correct family. Now we need to figure out the
:: architecture and whether it's the Windows server or client.
:Windows7Family
systeminfo | find "OS Name:" | find /c "Microsoft Windows Server" >NUL
if errorlevel 1 goto Windows7
goto Windows2008R2

:Windows80Family
systeminfo | find "OS Name:" | find /c "Microsoft Windows Server" >NUL
if errorlevel 1 goto Windows2012
goto Windows80

:Windows81Family
systeminfo | find "OS Name:" | find /c "Microsoft Windows Server" >NUL
if errorlevel 1 goto Windows81
goto Windows2012R2

:: If it wasn't a server class operating system, then we must be a client.. In
:: this case, we need to distinguish which architecture we actually are and then
:: we can distinguish between which url is the correct one.
:Windows7
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto Windows7x86
goto Windows7x64

:Windows80
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto Windows80x86
goto Windows80x64

:Windows81
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto Windows81x86
goto Windows81x64

:Windows2008
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto Windows2008x86
goto Windows2008x64

:: The following cases simply assign the url depending on the detected platform.
:Windows7x86
echo ==^> Detected Platform: Microsoft Windows 7.0 ^(x86^)
set "KB2999226_URL=%KB2999226_WIN7X86_URL%"
goto prepare_kb2999226

:Windows7x64
echo ==^> Detected Platform: Microsoft Windows 7.0 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN7X64_URL%"
goto prepare_kb2999226

:Windows80x86
echo ==^> Detected Platform: Microsoft Windows 8.0 ^(x86^)
set "KB2999226_URL=%KB2999226_WIN80X86_URL%"
goto prepare_kb2999226

:Windows80x64
echo ==^> Detected Platform: Microsoft Windows 8.0 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN80X64_URL%"
goto prepare_kb2999226

:Windows81x86
echo ==^> Detected Platform: Microsoft Windows 8.1 ^(x86^)
set "KB2999226_URL=%KB2999226_WIN81X86_URL%"
goto prepare_kb2999226

:Windows81x64
echo ==^> Detected Platform: Microsoft Windows 8.1 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN81X64_URL%"
goto prepare_kb2999226

:Windows2008x86
echo ==^> Detected Platform: Microsoft Windows Server 2008 ^(x86^)
set "KB2999226_URL=%KB2999226_WIN2008X86_URL%"
goto prepare_kb2999226

:Windows2008x64
echo ==^> Detected Platform: Microsoft Windows Server 2008 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN2008X64_URL%"
goto prepare_kb2999226

:Windows2008R2
echo ==^> Detected Platform: Microsoft Windows Server 2008R2 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN2008R2_URL%"
goto prepare_kb2999226

:Windows2012
echo ==^> Detected Platform: Microsoft Windows Server 2012 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN2012_URL%"
goto prepare_kb2999226

:Windows2012R2
echo ==^> Detected Platform: Microsoft Windows Server 2012R2 ^(x64^)
set "KB2999226_URL=%KB2999226_WIN2012R2_URL%"
goto prepare_kb2999226

:: Now that we've figured out the url, we just need to figure out where to
:: place it. We're also going to need to extract it and determine the filename
:: for the .cab file inside it. We rip all of this information from the url.
:prepare_kb2999226
for %%n in (%KB2999226_URL%) do set "KB2999226_FILENAME=%%~nxn"

for %%n in (%KB2999226_FILENAME%) do set "KB2999226_BASEFILENAME=%%~nn"
set "KB2999226_PATH=%TEMP%\%KB2999226_FILENAME%"
set "KB2999226_DIR=%TEMP%\%KB2999226_BASEFILENAME%.extracted"

:: Download the file to the path that was just calculated.
:download_kb2999226
call "%SystemRoot%\_download.cmd" "%KB2999226_URL%" "%KB2999226_PATH%"

if errorlevel 1 (
  echo ==^> ERROR: Unable to download file from %KB2999226_URL%
  goto exit1
)

if not exist "%KB2999226_PATH%" (
  echo ==^> ERROR: Unable to locate downloaded file at %KB2999226_PATH%
  goto exit1
)

:: Next we'll need to use wusa.exe to extract this update. We extract the cab
:: file directly from the patch in order to manually install it with dism.exe.
:: This is because usage of wusa.exe requires Windows Updates in order to work
:: properly. So to prevent the need of forcing users to install Windows Updates,
:: or even starting the wuauserv service we do it this way. It's just Microsoft's
:: Visual C runtime anyways...
:extract_kb2999226
echo ==^> Extracting KB2999226 to path %KB2999226_DIR%
start "" /wait wusa "%KB2999226_PATH%" "/extract:%KB2999226_DIR%"
if not exist "%KB2999226_DIR%\%KB2999226_BASEFILENAME%.cab" (
  echo ==^> ERROR: Unable to extract Windows Update ^(KB2999226^) to %KB2999226_DIR%
  goto exit1
)

:: So, we now should have the cab file for KB2999226. Final thing that we need
:: to do is to install it with dism, and make sure that it actually worked.
:install_kb2999226
echo ==^> Manually installing KB2999226 from file %KB2999226_DIR%\%KB2999226_BASEFILENAME%.cab
start "" /wait dism /online /add-package "/packagepath:%KB2999226_DIR%\%KB2999226_BASEFILENAME%.cab"
if errorlevel 1 (
  echo ==^> ERROR: Unable to install Windows Update ^(KB2999226^) from %KB2999226_DIR%\%KB2999226_BASEFILENAME%.cab
  goto exit 1
)

echo ==^> Successfully installed Windows Update ^(KB2999226^)
goto exit0

:: These are our exit branches for setting the errorlevel using the exact
:: same trickery as the other provisioning scripts.
:exit0
@ver>nul
@goto :exit

:exit1
@verify other 2>nul
@goto :exit

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%
