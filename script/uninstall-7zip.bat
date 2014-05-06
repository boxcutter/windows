@if not defined PACKER_DEBUG echo off

setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

set SEVENZIP_INSTALL_LOCAL_DIR=%TEMP%\7zip

echo ==^> Uninstalling 7zip
for %%i in ("%SEVENZIP_INSTALL_LOCAL_DIR%\*.msi") do msiexec /qb /x "%%~i"

echo ==^> Removing "%SEVENZIP_INSTALL_LOCAL_DIR%"
del /F /S /Q "%SEVENZIP_INSTALL_LOCAL_DIR%"

exit 0
