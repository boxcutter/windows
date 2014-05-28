@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

if not defined LESSMSI_URL set LESSMSI_URL=https://github.com/activescott/lessmsi/releases/download/v1.1.7/lessmsi-v1.1.7.zip
if not defined SEVENZIP_URL set SEVENZIP_URL=http://downloads.sourceforge.net/sevenzip/7z922.msi
if not defined VBOX_ISO_URL set VBOX_ISO_URL=http://download.virtualbox.org/virtualbox/4.3.12/VBoxGuestAdditions_4.3.12.iso
if not defined VMWARE_TOOLS_TAR_URL set VMWARE_TOOLS_TAR_URL=https://softwareupdate.vmware.com/cds/vmw-desktop/ws/10.0.2/1744117/windows/packages/tools-windows-9.6.2.exe.tar

goto main

::::::::::::
:find_unzip_vbs
::::::::::::

for %%i in ("%TEMP%" %PACKER_SEARCH_PATHS%) do if exist "%%~i\unzip.vbs" set UNZIP_VBS=%%~i\unzip.vbs

if exist "%UNZIP_VBS%" goto :eof

set UNZIP_VBS=%TEMP%\unzip.vbs

echo Set fso = CreateObject("Scripting.FileSystemObject")>"%UNZIP_VBS%"
echo ZipFile=fso.GetAbsolutePathName(Wscript.Arguments(0))>>"%UNZIP_VBS%"
echo ExtractTo=fso.GetAbsolutePathName(Wscript.Arguments(1))>>"%UNZIP_VBS%"
echo If NOT fso.FolderExists(ExtractTo) Then>>"%UNZIP_VBS%"
echo    fso.CreateFolder(ExtractTo)>>"%UNZIP_VBS%"
echo End If>>"%UNZIP_VBS%"
echo set objShell = CreateObject("Shell.Application")>>"%UNZIP_VBS%"
echo set FilesInZip=objShell.NameSpace(ZipFile).items>>"%UNZIP_VBS%"
echo objShell.NameSpace(ExtractTo).CopyHere(FilesInZip)>>"%UNZIP_VBS%"
echo Set fso = Nothing>>"%UNZIP_VBS%"
echo Set objShell = Nothing>>"%UNZIP_VBS%"

goto :eof

::::::::::::
:install_sevenzip
::::::::::::

pushd

set SEVENZIP_EXE=
set SEVENZIP_DLL=
for %%i in (7z.exe) do set SEVENZIP_EXE=%%~$PATH:i
if defined SEVENZIP_EXE goto return0

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_EXE @if exist "%%~i\7z.exe" set SEVENZIP_EXE=%%~i\7z.exe

if not defined SEVENZIP_EXE goto unmsi_sevenzip

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_DLL @if exist "%%~i\7z.dll" set SEVENZIP_DLL=%%~i\7z.dll

if not defined SEVENZIP_DLL goto unmsi_sevenzip

copy /y "%SEVENZIP_EXE%" "%SystemRoot%\" || goto unmsi_sevenzip
copy /y "%SEVENZIP_DLL%" "%SystemRoot%\" || goto unmsi_sevenzip

goto return0

:unmsi_sevenzip

for %%i in ("%SEVENZIP_URL%") do set SEVENZIP_ZIP=%%~nxi
set SEVENZIP_DIR=%TEMP%\sevenzip
set SEVENZIP_PATH=%SEVENZIP_DIR%\%SEVENZIP_ZIP%

echo ==^> Creating "%SEVENZIP_DIR%"
mkdir "%SEVENZIP_DIR%"
cd /d "%SEVENZIP_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SEVENZIP_URL%" "%SEVENZIP_PATH%"
) else (
  echo ==^> Downloadling "%SEVENZIP_URL%" to "%SEVENZIP_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SEVENZIP_URL%', '%SEVENZIP_PATH%')" <NUL
)
if not exist "%SEVENZIP_PATH%" goto return1

echo ==^> Unpacking "%SEVENZIP_PATH%" to "%SEVENZIP_DIR%"

for %%i in ("%LESSMSI_URL%") do set LESSMSI_ZIP=%%~nxi
set LESSMSI_DIR=%TEMP%\lessmsi
set LESSMSI_PATH=%LESSMSI_DIR%\%LESSMSI_ZIP%

echo ==^> Creating "%LESSMSI_DIR%"
mkdir "%LESSMSI_DIR%"
cd /d "%LESSMSI_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%LESSMSI_URL%" "%LESSMSI_PATH%"
) else (
  echo ==^> Downloadling "%LESSMSI_URL%" to "%LESSMSI_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%LESSMSI_URL%', '%LESSMSI_PATH%')" <NUL
)
if not exist "%LESSMSI_PATH%" goto return1

call :find_unzip_vbs

if not exist "%UNZIP_VBS%" echo ==^> ERROR: File not found: "%UNZIP_VBS%" & goto return1

echo ==^> Unzipping "%LESSMSI_PATH%" to "%LESSMSI_DIR%"
cscript "%UNZIP_VBS%" //b "%LESSMSI_PATH%" "%LESSMSI_DIR%"

set LESSMSI_EXE=

for %%i in ("%LESSMSI_DIR%\*.exe") do set LESSMSI_EXE=%%~i

if not exist "%LESSMSI_EXE%" echo ==^> ERROR: Failed to unzip "%LESSMSI_PATH%" & goto return1

"%LESSMSI_EXE%" x "%SEVENZIP_PATH%" 7z.exe 7z.dll

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%LESSMSI_EXE%" x "%SEVENZIP_PATH%" 7z.exe 7z.dll
ver>nul

set SEVENZIP_EXE=

for /r %%i in (7z.exe) do if exist "%%~i" set SEVENZIP_EXE=%%~i

if not exist "%SEVENZIP_EXE%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

set SEVENZIP_DLL=

for /r %%i in (7z.dll) do if exist "%%~i" set SEVENZIP_DLL=%%~i

if not exist "%SEVENZIP_DLL%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

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

echo "%PACKER_BUILDER_TYPE%" | findstr /i "vmware" >nul
if not errorlevel 1 goto vmware

echo "%PACKER_BUILDER_TYPE%" | findstr /i "virtualbox" >nul
if not errorlevel 1 goto virtualbox

echo ==^> ERROR: Unknown PACKER_BUILDER_TYPE: "%PACKER_BUILDER_TYPE%"

goto exit1

::::::::::::
:vmware
::::::::::::

if exist "%SystemDrive%\Program Files (x86)" (
  set VMWARE_TOOLS_SETUP_EXE=setup64.exe
) else (
  set VMWARE_TOOLS_SETUP_EXE=setup.exe
)

for %%i in ("%VMWARE_TOOLS_TAR_URL%") do set VMWARE_TOOLS_TAR=%%~nxi
set VMWARE_TOOLS_DIR=%TEMP%\vmware
set VMWARE_TOOLS_TAR_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_TAR%
set VMWARE_TOOLS_ISO=windows.iso

mkdir "%VMWARE_TOOLS_DIR%"
pushd "%VMWARE_TOOLS_DIR%"

set VMWARE_TOOLS_SETUP_PATH=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VMWARE_TOOLS_SETUP_PATH @if exist "%%~i\VMwareToolsUpgrader.exe" set VMWARE_TOOLS_SETUP_PATH=%%~i\%VMWARE_TOOLS_SETUP_EXE%

if defined VMWARE_TOOLS_SETUP_PATH goto install_vmware_tools

set VMWARE_TOOLS_ISO_PATH=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VMWARE_TOOLS_ISO_PATH @if exist "%%~i\%VMWARE_TOOLS_ISO%" set VMWARE_TOOLS_ISO_PATH=%%~i\%VMWARE_TOOLS_ISO%

if defined VMWARE_TOOLS_ISO_PATH goto install_vmware_tools_from_iso

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%VMWARE_TOOLS_TAR_URL%" "%VMWARE_TOOLS_TAR_PATH%"
) else (
  echo ==^> Downloadling "%VMWARE_TOOLS_TAR_URL%" to "%VMWARE_TOOLS_TAR_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VMWARE_TOOLS_TAR_URL%', '%VMWARE_TOOLS_TAR_PATH%')" <NUL
)
if not exist "%VMWARE_TOOLS_TAR_PATH%" goto exit1

call :install_sevenzip
if errorlevel 1 goto exit1

pushd "%VMWARE_TOOLS_DIR%"

7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_TAR_PATH%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e "%VMWARE_TOOLS_TAR_PATH%"
ver>nul

set VMWARE_TOOLS_INSTALLER_PATH=

for %%i in (tools-windows-*.exe) do set VMWARE_TOOLS_INSTALLER_PATH=%CD%\%%~i

if not exist "%VMWARE_TOOLS_INSTALLER_PATH%" echo ==^> ERROR: Failed to unzip "%VMWARE_TOOLS_TAR_PATH%" & goto exit1

"%VMWARE_TOOLS_INSTALLER_PATH%" /s

if exist "%SystemDrive%\Program Files (x86)" (
  set VMWARE_TOOLS_PROGRAM_FILES_DIR=%SystemDrive%\Program Files ^(x86^)\VMware
) else (
  set VMWARE_TOOLS_PROGRAM_FILES_DIR=%SystemDrive%\Program Files\VMware
)

if not exist "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" echo ==^> ERROR: Directory not found: "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" & goto exit1

set VMWARE_TOOLS_PROGRAM_FILES_ISO=

for /r "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" %%i in (%VMWARE_TOOLS_ISO%) do if exist "%%~i" set VMWARE_TOOLS_PROGRAM_FILES_ISO=%%~i

if not exist "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" echo ==^> ERROR: File not found: "%VMWARE_TOOLS_ISO%" in "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" & goto exit1

set VMWARE_TOOLS_ISO_PATH="%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISO%"

copy /y "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" "%VMWARE_TOOLS_ISO_PATH%"

if not exist "%VMWARE_TOOLS_ISO_PATH%" echo ==^> ERROR: File not found: "%VMWARE_TOOLS_ISO_PATH%" & goto exit1

rmdir /q /s "%VMWARE_TOOLS_PROGRAM_FILES_DIR%\tools-windows" || ver>nul

rmdir "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" || ver>nul

:install_vmware_tools_from_iso

call :install_sevenzip
if errorlevel 1 goto exit1

echo ==^> Extracting the VMWare Tools installer
7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"
ver>nul

set VMWARE_TOOLS_SETUP_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_SETUP_EXE%

if not exist "%VMWARE_TOOLS_SETUP_PATH%" echo ==^> Unable to unzip "%VMWARE_TOOLS_ISO_PATH%" & goto exit1

:install_vmware_tools

echo ==^> Installing VMware tools
"%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
ver>nul

goto exit0

::::::::::::
:virtualbox
::::::::::::

if exist "%SystemDrive%\Program Files (x86)" (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-amd64.exe
) else (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-x86.exe
)

for %%i in ("%VBOX_ISO_URL%") do set VBOX_ISO=%%~nxi
set VBOX_ISO_DIR=%TEMP%\vmware
set VBOX_ISO_PATH=%VBOX_ISO_DIR%\%VBOX_ISO%
set VBOX_ISO=VBoxGuestAdditions.iso

mkdir "%VBOX_ISO_DIR%"
pushd "%VBOX_ISO_DIR%"

set VBOX_SETUP_PATH=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VBOX_SETUP_PATH @if exist "%%~i\%VBOX_SETUP_EXE%" set VBOX_SETUP_PATH=%%~i\%VBOX_SETUP_EXE%

if defined VBOX_SETUP_PATH goto install_vbox_guest_additions

set VBOX_ISO_PATH=

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VBOX_ISO_PATH @if exist "%%~i\%VBOX_ISO%" set VBOX_ISO_PATH=%%~i\%VBOX_ISO%

if defined VBOX_ISO_PATH goto install_vbox_guest_additions_from_iso

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%VBOX_ISO_URL%" "%VBOX_ISO_PATH%"
) else (
  echo ==^> Downloadling "%VBOX_ISO_URL%" to "%VBOX_ISO_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VBOX_ISO_URL%', '%VBOX_ISO_PATH%')" <NUL
)
if not exist "%VBOX_ISO_PATH%" goto exit1

:install_vbox_guest_additions_from_iso

call :install_sevenzip
if errorlevel 1 goto exit1

pushd "%VBOX_ISO_DIR%"

echo ==^> Extracting the VirtualBox Guest Additions installer
7z e -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%"
ver>nul

set VBOX_SETUP_PATH=%VBOX_ISO_DIR%\%VBOX_SETUP_EXE%

if not exist "%VBOX_SETUP_PATH%" echo ==^> Unable to unzip "%VBOX_ISO_PATH%" & goto exit1

:install_vbox_guest_additions

if not exist a:\oracle-cert.cer echo ==^> ERROR: File not found: a:\oracle-cert.cer & goto exit1

echo ==^> Installing Oracle certificate to keep install silent
certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer

echo ==^> Installing VirtualBox Guest Additions
"%VBOX_SETUP_PATH%" /S

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VBOX_SETUP_PATH%" /S
ver>nul

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
