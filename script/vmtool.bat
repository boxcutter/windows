:: TODO: add steps to download hyperv Integration Tools .cab file based on OS and install them if the user hasn't specific their own URL
@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Downloading and installing virtual machine tools.  Please wait...

if not exist "%SystemRoot%\_download.cmd" (
  echo ==^> ERROR: Unable to download virtual machine tools due to missing download tool
  goto :exit1
)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
if not defined SEVENZIP_32_URL set SEVENZIP_32_URL=http://7-zip.org/a/7z1604.msi
if not defined SEVENZIP_64_URL set SEVENZIP_64_URL=http://7-zip.org/a/7z1604-x64.msi
if not defined VBOX_ISO_URL set VBOX_ISO_URL=http://download.virtualbox.org/virtualbox/5.1.30/VBoxGuestAdditions_5.1.30.iso
if not defined VMWARE_TOOLS_LATEST_ISOURL set VMWARE_TOOLS_LATEST_ISOURL=https://packages.vmware.com/tools/releases/11.1.0/windows/VMware-tools-windows-11.1.0-16036546.iso
if not defined VMWARE_TOOLS_OLD_ISOURL set VMWARE_TOOLS_OLD_ISOURL=https://packages.vmware.com/tools/releases/10.2.5/windows/VMware-tools-windows-10.2.5-8068406.iso
goto main

::::::::::::
:install_sevenzip
::::::::::::
if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set SEVENZIP_URL=%SEVENZIP_32_URL%
) else (
  set SEVENZIP_URL=%SEVENZIP_64_URL%
)
pushd .
set SEVENZIP_EXE=
set SEVENZIP_DLL=
for %%i in (7z.exe) do set SEVENZIP_EXE=%%~$PATH:i
if defined SEVENZIP_EXE goto return0
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_EXE @if exist "%%~i\7z.exe" set SEVENZIP_EXE=%%~i\7z.exe
if not defined SEVENZIP_EXE goto get_sevenzip
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_DLL @if exist "%%~i\7z.dll" set SEVENZIP_DLL=%%~i\7z.dll
if not defined SEVENZIP_DLL goto get_sevenzip
ver >nul
call :copy_sevenzip
if not errorlevel 1 goto return0

:get_sevenzip
for %%i in ("%SEVENZIP_URL%") do set SEVENZIP_MSI=%%~nxi
set "SEVENZIP_DIR=%TEMP%\sevenzip"
set "SEVENZIP_PATH=%SEVENZIP_DIR%\%SEVENZIP_MSI%"
echo ==^> Creating "%SEVENZIP_DIR%"
mkdir "%SEVENZIP_DIR%"
cd /d "%SEVENZIP_DIR%"

call "%SystemRoot%\_download.cmd" "%SEVENZIP_URL%" "%SEVENZIP_PATH%"
if errorlevel 1 (
  echo ==^> ERROR: Unable to download file from %SEVENZIP_URL%
  goto exit1
)

if not exist "%SEVENZIP_PATH%" goto return1

echo ==^> Installing "%SEVENZIP_PATH%"
msiexec /qb /i "%SEVENZIP_PATH%"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%SEVENZIP_PATH%"
ver>nul

set SEVENZIP_INSTALL_DIR=
for %%i in ("%ProgramFiles%" "%ProgramW6432%" "%ProgramFiles(x86)%") do if exist "%%~i\7-Zip" set SEVENZIP_INSTALL_DIR=%%~i\7-Zip
if exist "%SEVENZIP_INSTALL_DIR%" cd /D "%SEVENZIP_INSTALL_DIR%" & goto find_sevenzip
echo ==^> ERROR: Directory not found: "%ProgramFiles%\7-Zip"
goto return1

:find_sevenzip
set SEVENZIP_EXE=
for /r %%i in (7z.exe) do if exist "%%~i" set SEVENZIP_EXE=%%~i
if not exist "%SEVENZIP_EXE%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

set SEVENZIP_DLL=
for /r %%i in (7z.dll) do if exist "%%~i" set SEVENZIP_DLL=%%~i
if not exist "%SEVENZIP_DLL%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

:copy_sevenzip
echo ==^> Copying "%SEVENZIP_EXE%" to "%SystemRoot%"
copy /y "%SEVENZIP_EXE%" "%SystemRoot%\" || goto return1
copy /y "%SEVENZIP_DLL%" "%SystemRoot%\" || goto return1

:return0
popd
ver>nul
goto return

:return1
popd
verify other 2>nul

:return
goto :eof

::::::::::::
:main
::::::::::::

:: Get the PlatformVersion from SystemInfo
for /f "delims=:; tokens=1,2" %%a in ('systeminfo') do (
  if "%%a" == "OS Version" set "PlatformVersionRow=%%b"
)

:: Extract the major/minor version (stripped)
for /f "delims=.; tokens=1,2,3" %%a in ("%PlatformVersionRow%") do (
  for /f "tokens=1" %%v in ("%%a") do set "PlatformVersionMajor=%%v"
  for /f "tokens=1" %%v in ("%%b") do set "PlatformVersionMinor=%%v"
  for /f "tokens=1" %%v in ("%%c") do set "PlatformVersionRelease=%%v"
)

:: Get the PlatformFlavor from SystemInfo
for /f "delims=:; tokens=1,2" %%a in ('systeminfo') do (
  if "%%a" == "OS Name" set "PlatformFlavorRow=%%b"
)

:: Detect whether we're using a server or client flavor
for /f "tokens=1,2,3" %%a in ("%PlatformFlavorRow%") do if "%%a" == "Microsoft" if "%%b" == "Windows" if "%%c" == "Server" (
  set "PlatformFlavor=Server"
) else (
  set "PlatformFlavor=Client"
)

echo ==^> Detected Windows Platform Version ^(%PlatformFlavor%^): %PlatformVersionMajor%.%PlatformVersionMinor%.%PlatformVersionRelease%

:: Figure out the build type
echo "%PACKER_BUILDER_TYPE%" | findstr /i "vmware" >nul
if not errorlevel 1 goto vmware
echo "%PACKER_BUILDER_TYPE%" | findstr /i "vsphere" >nul
if not errorlevel 1 goto vmware
echo "%PACKER_BUILDER_TYPE%" | findstr /i "virtualbox" >nul
if not errorlevel 1 goto virtualbox
echo "%PACKER_BUILDER_TYPE%" | findstr /i "parallels" >nul
if not errorlevel 1 goto parallels
echo "%PACKER_BUILDER_TYPE%" | findstr /i "hyperv" >nul
if not errorlevel 1 goto hyperv
echo ==^> ERROR: Unknown PACKER_BUILDER_TYPE: "%PACKER_BUILDER_TYPE%"
pushd .
goto exit1

::::::::::::
:vmware
::::::::::::
if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set "VMWARE_TOOLS_SETUP_EXE=setup.exe"
  set "VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles%\VMware"
  echo ==^> Detected virtualization platform ^(x86^): VMware
) else (
  set "VMWARE_TOOLS_SETUP_EXE=setup64.exe"
  set "VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles(x86)%\VMware"
  echo ==^> Detected virtualization platform ^(x64^): VMware
)

:: Figure out which iso to use depending on the platform version. The w7 family
:: only allows us up to tools version 10.2.5 unless we update to SP1.
if %PlatformVersionMajor% LSS 6 goto vmware_old_isourl
if %PlatformVersionMajor% EQU 6 if %PlatformVersionMinor% EQU 0 if %PlatformVersionRelease% GTR 7600 goto vmware_new_isourl
if %PlatformVersionMajor% EQU 6 if %PlatformVersionMinor% EQU 0 goto vmware_old_isourl
if %PlatformVersionMajor% EQU 6 if %PlatformVersionMinor% EQU 1 if %PlatformVersionRelease% GTR 7600 goto vmware_new_isourl
if %PlatformVersionMajor% EQU 6 if %PlatformVersionMinor% EQU 1 goto vmware_old_isourl
goto vmware_new_isourl

:: Otherwise, we need to use an older version to avoid needing to update
:vmware_old_isourl
set "VMWARE_TOOLS_ISO_URL=%VMWARE_TOOLS_OLD_ISOURL%"
goto download_vmware_tools_iso

:: We can use the most recent iso according to our detected platform. This
:: should only require KB2999226 which should've been installed already.
:vmware_new_isourl
set "VMWARE_TOOLS_ISO_URL=%VMWARE_TOOLS_LATEST_ISOURL%"
goto download_vmware_tools_iso

:: Setup all the paths we're going to need in order to download our iso
:download_vmware_tools_iso
for %%i in ("%VMWARE_TOOLS_ISO_URL%") do set VMWARE_TOOLS_ISONAME=%%~nxi
set "VMWARE_TOOLS_DIR=%TEMP%\vmware"
set "VMWARE_TOOLS_ISO_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISONAME%"
echo ==^> Installing the VMware tools using directory %VMWARE_TOOLS_DIR%

mkdir "%VMWARE_TOOLS_DIR%"
pushd "%VMWARE_TOOLS_DIR%"
set VMWARE_TOOLS_SETUP_PATH=

:: First check to see if the iso already exists. If it does and the file is not
:: zero, then we clear VMWARE_TOOLS_ISO_URL. This will then branch straight to
:: install_vmware_tools_from_iso process. Otherwise, we need to download the iso
:: to the correct place.
set _VMWARE_TOOLS_SIZE=0
if defined VMWARE_TOOLS_ISO_PATH for %%i in (%VMWARE_TOOLS_ISO_PATH%) do set _VMWARE_TOOLS_SIZE=%%~zi
if defined _VMWARE_TOOLS_SIZE if not "%_VMWARE_TOOLS_SIZE%" == "0" set VMWARE_TOOLS_ISO_URL=
if not defined VMWARE_TOOLS_ISO_URL goto install_vmware_tools_from_iso

echo ==^> Downloading the VMware tools from %VMWARE_TOOLS_ISO_UrL%

call "%SystemRoot%\_download.cmd" "%VMWARE_TOOLS_ISO_URL%" "%VMWARE_TOOLS_ISO_PATH%"
if errorlevel 1 (
  echo ==^> ERRROR: Unable to download file from %VMWARE_TOOLS_ISO_URL%
  goto exit1
)

if not exist "%VMWARE_TOOLS_ISO_PATH%" (
  echo ==^> ERROR: Unable to locate downloaded file at %VMWARE_TOOLS_ISO_PATH%
  goto exit1
)

:: Now we need to install 7-zip in case it isn't already installed. This way we
:: can extract the iso we just downloaded and run its setup.
:install_vmware_tools_from_iso
call :install_sevenzip
if errorlevel 1 (
  echo ==^> ERROR: Failure trying to install 7-zip archiver
  goto exit1
)

:: Now that we have the iso, we can extract it with 7-zip and make sure its got
:: everything that we're looking for.
:extract_vmware_tools_from_iso
echo ==^> Extracting the VMware Tools installer to %VMWARE_TOOLS_DIR% from %VMWARE_TOOLS_ISO_PATH%
7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"
ver>nul
set "VMWARE_TOOLS_SETUP_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_SETUP_EXE%"
if not exist "%VMWARE_TOOLS_SETUP_PATH%" echo ==^> Unable to extract "%VMWARE_TOOLS_ISO_PATH%" & goto exit1

:: Our iso has been validated so all we need to do is to run the correct exe
:install_vmware_tools
echo ==^> Installing VMware tools with %VMWARE_TOOLS_SETUP_PATH%
"%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
@if not errorlevel 3010 if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
@if errorlevel 3010 echo ==^> Successfully installed VMware tools ^(reboot required^)
ver>nul
goto exit0

::::::::::::
:virtualbox
::::::::::::
if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-x86.exe
  echo ==^> Detected virtualization platform ^(x86^): VirtualBox
) else (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-amd64.exe
  echo ==^> Detected virtualization platform ^(x64^): VirtualBox
)
for %%i in ("%VBOX_ISO_URL%") do set VBOX_ISO=%%~nxi
set "VBOX_ISO_DIR=%TEMP%\virtualbox"
set "VBOX_ISO_PATH=%VBOX_ISO_DIR%\%VBOX_ISO%"
set "VBOX_ISO=VBoxGuestAdditions.iso"
echo ==^> Installing the VirtualBox Guest Additions with directory %VBOX_ISO_DIR%

mkdir "%VBOX_ISO_DIR%"
pushd "%VBOX_ISO_DIR%"
set VBOX_SETUP_PATH=
set VBOX_SETUP_DIR=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VBOX_SETUP_PATH @if exist "%%~i\%VBOX_SETUP_EXE%" (set VBOX_SETUP_PATH=%%~i\%VBOX_SETUP_EXE% & set VBOX_SETUP_DIR=%%~i)
if defined VBOX_SETUP_PATH goto install_vbox_guest_additions

:: if VBoxGuestAdditions.iso is zero bytes, then download it
set _VBOX_ISO_SIZE=0
@for %%i in (%PACKER_SEARCH_PATHS%) do @if exist "%%~i\%VBOX_ISO%" set VBOX_ISO_PATH=%%~i\%VBOX_ISO%
if exist "%VBOX_ISO_PATH%" for %%i in (%VBOX_ISO_PATH%) do set _VBOX_ISO_SIZE=%%~zi
if %_VBOX_ISO_SIZE% GTR 0 goto install_vbox_guest_additions_from_iso

call "%SystemRoot%\_download.cmd" "%VBOX_ISO_URL%" "%VBOX_ISO_PATH%"
if errorlevel 1 (
  echo ==^> ERROR: Unable to download file from %VBOX_ISO_URL%
  goto exit1
)

if not exist "%VBOX_ISO_PATH%" goto exit1

:install_vbox_guest_additions_from_iso
call :install_sevenzip
if errorlevel 1 (
  echo ==^> ERROR: Failure trying to install 7-zip archiver
  goto exit1
)

echo ==^> Extracting the VirtualBox Guest Additions installer
7z x -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%" cert
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%"
ver>nul
set "VBOX_SETUP_PATH=%VBOX_ISO_DIR%\%VBOX_SETUP_EXE%"
if not exist "%VBOX_SETUP_PATH%" echo ==^> Unable to unzip "%VBOX_ISO_PATH%" & goto exit1

:install_vbox_guest_additions
echo ==^> Installing Oracle certificate to keep install silent
powershell -Command "Get-ChildItem %VBOX_SETUP_DIR%\cert\ -Filter vbox*.cer | ForEach-Object { %VBOX_SETUP_DIR%\cert\VBoxCertUtil.exe add-trusted-publisher $_.FullName --root $_.FullName }" <NUL
echo ==^> Installing VirtualBox Guest Additions
"%VBOX_SETUP_PATH%" /S
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VBOX_SETUP_PATH%" /S
ver>nul
goto :exit0

::::::::::::
:parallels
::::::::::::
set "PARALLELS_INSTALL=PTAgent.exe"
echo ==^> Detected virtualization platform: Parallels

set "PARALLELS_DIR=%TEMP%\parallels"
set "PARALLELS_PATH=%PARALLELS_DIR%\%PARALLELS_INSTALL%"
set "PARALLELS_ISO=prl-tools-win.iso"
echo ==^> Installing the Parallels Tools with directory %PARALLELS_DIR%

mkdir "%PARALLELS_DIR%"
pushd "%PARALLELS_DIR%"
set PARALLELS_ISO_PATH=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined PARALLELS_ISO_PATH @if exist "%%~i\%PARALLELS_ISO%" set PARALLELS_ISO_PATH=%%~i\%PARALLELS_ISO%
REM parallels tools don't have a download :(
call :install_sevenzip
if errorlevel 1 (
  echo ==^> ERROR: Failure trying to install 7-zip archiver
  goto exit1
)

echo ==^> Extracting the Parallels Tools installer
echo ==^>   to %PARALLELS_DIR%\*
7z x -o"%PARALLELS_DIR%" "%PARALLELS_ISO_PATH%"
ping 127.0.0.1

echo ==^> Installing Parallels Tools from %PARALLELS_PATH%
"%PARALLELS_PATH%" /install_silent

REM parallels tools installer tends to exit while the install agent
REM is still running, need to sleep while it's running so we don't
REM delete the tools.
@if errorlevel 1 echo=^> WARNING: Error %ERRORLEVEL% was returned by: "%PARALLELS_PATH%" /install_silent
ver>nul

echo ==^> Cleaning up Parallels Tools install
del /F /S /Q "%PARALLELS_DIR"

echo ==^> Removing "%PARALLELS_ISO_PATH"
del /F "%PARALLELS_ISO_PATH"
goto :exit0

::::::::::::
:hyperv
::::::::::::
echo ==^> Detected virtualization platform: HyperV

for /F "usebackq tokens=3,4,5" %%i in (`REG query "hklm\software\microsoft\windows NT\CurrentVersion" /v ProductName`) do set GUEST_OS=%%i %%j %%k

set GUEST_OS

if "%GUEST_OS%" == "Windows Server 2016" goto :exit0

::First, download the appropriate Windows Update CAB file from here: https://support.microsoft.com/en-us/kb/3063109
::  Windows 8.1: http://www.microsoft.com/downloads/details.aspx?familyid=cd142c42-204a-4566-b767-795e3409b135
::  Windows 8.1: http://www.microsoft.com/downloads/details.aspx?familyid=3a5a9015-c121-44dd-ad2e-962f66532da7
::  Windows Server 2012 R2: http://www.microsoft.com/downloads/details.aspx?familyid=a7704851-70bb-46c1-96d2-1b6f7ca226af
::  Windows Server 2012: http://www.microsoft.com/downloads/details.aspx?familyid=185812c8-8eb5-43c8-8505-70a262f4277d
::  Windows 7: http://www.microsoft.com/downloads/details.aspx?familyid=54c62651-0fc9-4642-ad12-404b3356825e
::  Windows 7: http://www.microsoft.com/downloads/details.aspx?familyid=c84f2899-d997-42af-bd5d-cb97086e3b09
::  Windows Server 2008 R2: http://www.microsoft.com/downloads/details.aspx?familyid=2dd45bd8-6bcd-47aa-8322-3e10b52b1f1f
::Open up Windows Powershell with elevated privileges.
::Set the correct path to the CAB file you’ve downloaded. For example:
::  $integrationServicesCabPath="C:\Downloads\windows6.2-hypervintegrationservices-x86.cab"
::Install the patch using the following command:
::  Add-WindowsPackage -Online -PackagePath $integrationServicesCabPath

goto :exit0

:exit0
@ver>nul
@goto :exit

:exit1
@verify other 2>nul
@goto :exit

:exit
@set _ERRORLEVEL=%ERRORLEVEL%
@echo ==^> Script exiting with errorlevel %_ERRORLEVEL%
@popd
@ping 127.0.0.1

@if %_ERRORLEVEL% gtr 0 (@call :error) else (@call :pause)
@goto :_exit

:error
@if not defined PACKER_PAUSE_ON_ERROR goto :eof
@echo Packer paused. Press Ctrl-C to abort:
@pause
@goto :eof

:pause
@if PACKER_PAUSE leq 0 goto :eof
@set _TEMPNAME=%TEMP%\%~nx0-%RANDOM%.tmp
@for /L %%i in (1,1,%PACKER_PAUSE%) do @call :pause1 %%i
@del "%_TEMPNAME%"
@goto :eof

:pause1
@echo.|time|findstr /R /C:": [0-9]">%_TEMPNAME%
@for /F "tokens=5* " %%a in (%_TEMPNAME%) do @echo %%a: Waiting %1 of %PACKER_PAUSE% seconds...
@choice /C Y /N /T 1 /D Y /M " " >NUL
@goto :eof

:_exit
@exit /b %_ERRORLEVEL%
