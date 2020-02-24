@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined HANDLE_URL set HANDLE_URL=http://live.sysinternals.com/handle.exe

for %%i in ("%HANDLE_URL%") do set HANDLE_EXE=%%~nxi
set HANDLE_DIR=%TEMP%\handle
set HANDLE_PATH=%HANDLE_DIR%\%HANDLE_EXE%

echo ==^> Creating "%HANDLE_DIR%"
mkdir "%HANDLE_DIR%"
pushd "%HANDLE_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%HANDLE_URL%" "%HANDLE_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%HANDLE_URL%" "%HANDLE_PATH%"
)
if not exist "%HANDLE_PATH%" goto exit1

reg add HKCU\Software\Sysinternals\Handle /v EulaAccepted /t REG_DWORD /d 1 /f

echo ==^> Copying "%HANDLE_PATH%" to "%SystemRoot%"
copy /y "%HANDLE_PATH%" "%SystemRoot%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: copy /y "%HANDLE_PATH%" "%SystemRoot%"
ver>nul

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
