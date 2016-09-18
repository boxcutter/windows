@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PYTHON_URL set PYTHON_URL=https://www.python.org/ftp/python/2.7.12/python-2.7.12.amd64.msi

for %%i in ("%PYTHON_URL%") do set PYTHON_EXE=%%~nxi
set PYTHON_DIR=%TEMP%\python
set PYTHON_PATH=%PYTHON_DIR%\%PYTHON_EXE%

echo ==^> Creating "%PYTHON_DIR%"
mkdir "%PYTHON_DIR%"
pushd "%PYTHON_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%PYTHON_URL%" "%PYTHON_PATH%"
) else (
  echo ==^> Downloading "%PYTHON_URL%" to "%PYTHON_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_URL%', '%PYTHON_PATH%')" <NUL
)
if not exist "%PYTHON_PATH%" goto exit1

echo ==^> Installing python on %SystemDrive%
msiexec /qb /i "%PYTHON_PATH%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%PYTHON_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%PYTHON_DIR%"
rmdir /q /s "%PYTHON_DIR%"

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

