@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Downloading and installing required Windows Update (KB2919355).  Please wait...

:: Check for all of our prerequisites needed to install KB2919355
if not exist "%SystemRoot%\_download.cmd" (
  echo ==^> ERROR: Unable to download required Windows Update ^(KB2919355^) due to missing download tool
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
set "KB2919355_WIN81X86_URL=https://download.microsoft.com/download/4/E/C/4EC66C83-1E15-43FD-B591-63FB7A1A5C04/Windows8.1-KB2919355-x86.msu"
set "KB2919355_WIN81X64_URL=https://download.microsoft.com/download/D/B/1/DB1F29FC-316D-481E-B435-1654BA185DCF/Windows8.1-KB2919355-x64.msu"
set "KB2919355_WIN2012R2_URL=https://download.microsoft.com/download/2/5/6/256CCCFB-5341-4A8D-A277-8A81B21A1E35/Windows8.1-KB2919355-x64.msu"

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
if "%PlatformVersionMajor%" == "6" if "%PlatformVersionMinor%" == "3" goto Windows81Family

echo ==^> Skipping Windows Update ^(KB2919355^) due to it being non-applicable to the current platform
goto exit0

:: We figured out that we're in the correct family. Now we need to figure out the
:: architecture and whether it's the Windows8 server or client.
:Windows81Family
systeminfo | find "OS Name:" | find /c "Microsoft Windows Server" >NUL
if errorlevel 1 goto Windows2012R2

:: If it wasn't a server class operating system, then we must be a client.. In
:: this case, we need to distinguish which architecture we actually are and then
:: we can distinguish between which url is the correct one.
:Windows81
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto Windows81x86
goto Windows81x64

:: The following cases simply assign the url depending on the detected platform.
:Windows81x86
set "KB2919355_URL=%KB2919355_WIN81X86_URL%"
goto prepare_kb2919355

:Windows81x64
set "KB2919355_URL=%KB2919355_WIN81X64_URL%"
goto prepare_kb2919355

:Windows2012R2
set "KB2919355_URL=%KB2919355_WIN2012R2_URL%"
goto prepare_kb2919355

:: Now that we've figured out the url, we just need to figure out where to
:: place it. We're also going to need to extract it and determine the filename
:: for the .cab file inside it. We rip all of this information from the url.
:prepare_kb2919355
for %%n in (%KB2919355_URL%) do set "KB2919355_FILENAME=%%~nxn"

for %%n in (%KB2919355_FILENAME%) do set "KB2919355_BASEFILENAME=%%~nn"
set "KB2919355_PATH=%TEMP%\%KB2919355_FILENAME%"
set "KB2919355_DIR=%TEMP%\%KB2919355_BASEFILENAME%.extracted"

:: Download the file to the path that was just calculated.
:download_kb2919355
call "%SystemRoot%\_download.cmd" "%KB2919355_URL%" "%KB2919355_PATH%"

if errorlevel 1 (
  echo ==^> ERROR: Unable to download file from %KB2919355_URL%
  goto exit1
)

if not exist "%KB2919355_PATH%" goto exit1

:: Next we'll need to use wusa.exe to extract this update. We extract the cab
:: file directly from the patch in order to manually install it with dism.exe.
:: This is because usage of wusa.exe requires Windows Updates in order to work
:: properly. So to prevent the need of forcing users to install Windows Updates,
:: or even starting the wuauserv service we do it this way. It's just Microsoft's
:: Visual C runtime anyways...
:extract_kb2919355
start "" /wait wusa "%KB2919355_PATH%" "/extract:%KB2919355_DIR%"
if not exist "%KB2919355_DIR%\%KB2919355_BASEFILENAME%.cab" (
  echo ==^> ERROR: Unable to extract Windows Update ^(KB2919355^) to %KB2919355_DIR%
  goto exit1
)

:: So, we now should have the cab file for KB2919355. Final thing that we need
:: to do is to install it with dism, and make sure that it actually worked.
:install_kb2919355
start "" /wait dism /online /add-package "/packagepath:%KB2919355_DIR%\%KB2919355_BASEFILENAME%.cab"
if errorlevel 1 (
  echo ==^> ERROR: Unable to install Windows Update ^(KB2919355^) from %KB2919355_DIR%\%KB2919355_BASEFILENAME%.cab
  goto exit 1
)

echo ==^> Successfully installed Windows Update ^(KB2919355^)
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
