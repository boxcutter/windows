@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined SEVENZIP_32_URL set SEVENZIP_32_URL=http://7-zip.org/a/7z1604.msi
if not defined SEVENZIP_64_URL set SEVENZIP_64_URL=http://www.7-zip.org/a/7z1604-x64.msi

if defined ProgramFiles(x86) (
  set SEVENZIP_URL=%SEVENZIP_64_URL%
) else (
  set SEVENZIP_URL=%SEVENZIP_32_URL%
)

echo ==^> Uninstalling 7zip
if exist "%SystemRoot%\7z.exe" del /f "%SystemRoot%\7z.exe"
if exist "%SystemRoot%\7z.dll" del /f "%SystemRoot%\7z.dll"

for %%i in ("%SEVENZIP_URL%") do set SEVENZIP_MSI=%%~nxi
set SEVENZIP_DIR=%TEMP%\sevenzip
set SEVENZIP_PATH=%SEVENZIP_DIR%\%SEVENZIP_MSI%

if not exist "%SEVENZIP_DIR%" echo ==^> WARNING: Directory not found: "%SEVENZIP_DIR%" & goto delete_sevenzip

cd /d "%SEVENZIP_DIR%"

if not exist "%SEVENZIP_PATH%" echo ==^> WARNING: File not found: "%SEVENZIP_PATH%" & goto delete_sevenzip

echo ==^> Uninstalling "%SEVENZIP_PATH%"
msiexec /qb /x "%SEVENZIP_PATH%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /x "%SEVENZIP_PATH%"
ver>nul

goto exit0

:delete_sevenzip

set SEVENZIP_INSTALL_DIR=

for %%i in ("%ProgramFiles%" "%ProgramW6432%" "%ProgramFiles(x86)%") do if exist "%%~i\7-Zip" set SEVENZIP_INSTALL_DIR=%%~i\7-Zip

if not exist "%SEVENZIP_INSTALL_DIR%" echo ==^> WARNING: Directory not found: "%SEVENZIP_INSTALL_DIR%" & goto exit0

echo ==^> Removing "%SEVENZIP_INSTALL_DIR%"
rmdir /q /s "%SEVENZIP_INSTALL_DIR%"

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
