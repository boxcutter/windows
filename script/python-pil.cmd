@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PYTHON_PIL_URL set PYTHON_PIL_URL=http://effbot.org/downloads/PIL-1.1.7.win32-py2.7.exe

for %%i in ("%PYTHON_PIL_URL%") do set PYTHON_PIL_EXE=%%~nxi
set PYTHON_PIL_DIR=%TEMP%\pil
set PYTHON_PIL_PATH=%PYTHON_PIL_DIR%\%PYTHON_PIL_EXE%

echo ==^> Creating "%PYTHON_PIL_DIR%"
mkdir "%PYTHON_PIL_DIR%"
pushd "%PYTHON_PIL_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%PYTHON_PIL_URL%" "%PYTHON_PIL_PATH%"
) else (
  echo ==^> Downloading "%PYTHON_PIL_URL%" to "%PYTHON_PIL_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_PIL_URL%', '%PYTHON_PIL_PATH%')" <NUL
)
if not exist "%PYTHON_PIL_PATH%" goto exit1

echo ==^> Installing python PIL on %SystemDrive%
"%systemdrive%\Python27\Scripts\easy_install.exe" "%PYTHON_PIL_PATH%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%PYTHON_PIL_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%PYTHON_PIL_DIR%"
rmdir /q /s "%PYTHON_PIL_DIR%"

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

