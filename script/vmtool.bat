@if not defined PACKER_DEBUG echo off

setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

if exist "%SystemDrive%\Program Files (x86)" (
  set SEVENZIP_INSTALL=7z922-x64.msi
  set VBOX_INSTALL=VBoxWindowsAdditions-amd64.exe
  set VMWARE_INSTALL=setup64.exe
) else (
  set SEVENZIP_INSTALL=7z922.msi
  set VBOX_INSTALL=VBoxWindowsAdditions-x86.exe
  set VMWARE_INSTALL=setup.exe
)

set SEVENZIP_URL=http://downloads.sourceforge.net/sevenzip/%SEVENZIP_INSTALL%
set SEVENZIP_INSTALL_LOCAL_DIR=%TEMP%\7zip
set SEVENZIP_INSTALL_LOCAL_PATH=%SEVENZIP_INSTALL_LOCAL_DIR%\%SEVENZIP_INSTALL%

mkdir "%SEVENZIP_INSTALL_LOCAL_DIR%"

echo ==^> Downloadling %SEVENZIP_URL% to %SEVENZIP_INSTALL_LOCAL_PATH%
PATH=%PATH%;a:\
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%SEVENZIP_URL%" "%SEVENZIP_INSTALL_LOCAL_PATH%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SEVENZIP_URL%', '%SEVENZIP_INSTALL_LOCAL_PATH%')" <NUL
)

echo ==^> Download complete
echo ==^> Installing 7zip from "%SEVENZIP_INSTALL_LOCAL_PATH%"
msiexec /qb /i "%SEVENZIP_INSTALL_LOCAL_PATH%"

echo "%PACKER_BUILDER_TYPE%" | findstr /I "vmware" >nul
if not errorlevel 1 goto vmware

echo "%PACKER_BUILDER_TYPE%" | findstr /I "virtualbox" >nul
if not errorlevel 1 goto virtualbox

echo ==^> ERROR: Unknown PACKER_BUILDER_TYPE: %PACKER_BUILDER_TYPE%

goto :finish

:vmware

echo ==^> Extracting the VMWare Tools installer
"%SystemDrive%\Program Files\7-Zip\7z.exe" x -o"%TEMP%\vmware" "%USERPROFILE%\windows.iso" "%VMWARE_INSTALL%"

echo ==^> Installing VMware tools
"%TEMP%\vmware\%VMWARE_INSTALL%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"

echo ==^> Cleaning up VMware tools install
del /F /S /Q "%TEMP%\vmware"

echo ==^> Removing "%USERPROFILE%\windows.iso"
del /F "%USERPROFILE%\windows.iso"

goto finish

:virtualbox

echo ==^> Extracting the VirtualBox Guest Additions installer
"%SystemDrive%\Program Files\7-Zip\7z.exe" x -o"%TEMP%\virtualbox" "%USERPROFILE%\VBoxGuestAdditions.iso" "%VBOX_INSTALL%"

echo ==^> Installing Oracle certificate to keep install silent
certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer

echo ==^> Installing VirtualBox Guest Additions
"%TEMP%\virtualbox\%VBOX_INSTALL%" /S

echo ==^> Cleaning up VirtualBox Guest Additions install
del /F /S /Q "%TEMP%\virtualbox"

echo ==^> Removing "%USERPROFILE%\VBoxGuestAdditions.iso"
del /F "%USERPROFILE%\VBoxGuestAdditions.iso"

goto finish

:finish

exit 0
