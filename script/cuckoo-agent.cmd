@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

@echo on
if not defined AGENT_URL set AGENT_URL=https://raw.githubusercontent.com/cuckoosandbox/cuckoo/master/agent/agent.py

for %%i in ("%AGENT_URL%") do set AGENT_EXE=%%~nxi
set AGENT_DIR=%TEMP%\agent
set AGENT_PATH=%AGENT_DIR%\%AGENT_EXE%

echo ==^> Creating "%AGENT_DIR%"
mkdir "%AGENT_DIR%"
pushd "%AGENT_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%AGENT_URL%" "%AGENT_PATH%"
) else (
  echo ==^> Downloading "%AGENT_URL%" to "%AGENT_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%AGENT_URL%', '%AGENT_PATH%')" <NUL
)
if not exist "%AGENT_PATH%" goto exit1

echo ==^> Installing python on %SystemDrive%
move %AGENT_PATH% "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\startup\agent.pyw"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%AGENT_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%AGENT_DIR%"
rmdir /q /s "%AGENT_DIR%"

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

