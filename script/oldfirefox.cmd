@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

@echo on
::if not defined OLDFIREFOX_URL set OLDFIREFOX_URL=http://download.oldapps.com/Firefox/Firefox%20Setup%2025.0.1.exe
if not defined OLDFIREFOX_URL set OLDFIREFOX_URL=https://ftp.mozilla.org/pub/firefox/releases/25.0/win32/en-US/Firefox%%%%20Setup%%%%2025.0.exe

set OLDFIREFOX_EXE=FirefoxSetup.exe
set OLDFIREFOX_DIR=%TEMP%\oldfirefox
set OLDFIREFOX_PATH=%OLDFIREFOX_DIR%\%OLDFIREFOX_EXE%

echo ==^> Creating "%OLDFIREFOX_DIR%"
mkdir "%OLDFIREFOX_DIR%"
pushd "%OLDFIREFOX_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%OLDFIREFOX_URL%" "%OLDFIREFOX_PATH%"
) else (
  echo ==^> Downloading "%OLDFIREFOX_URL%" to "%OLDFIREFOX_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%OLDFIREFOX_URL%', '%OLDFIREFOX_PATH%')" <NUL
)
if not exist "%OLDFIREFOX_PATH%" goto exit1

echo ==^> Installing old FIREFOX on %SystemDrive%
"%OLDFIREFOX_PATH%" -ms -ira

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%OLDFIREFOX_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%OLDFIREFOX_DIR%"
rmdir /q /s "%OLDFIREFOX_DIR%"

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

