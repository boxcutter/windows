@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Upgrading Windows Update Agent.  Please wait...

if not exist "%SystemRoot%\_download.cmd" (
    echo ==^> ERROR: Unable to upgrade the Windows Update Agent due to missing download tool
    goto :exit1
)

if not defined WUA_64_URL set WUA_64_URL=http://download.windowsupdate.com/windowsupdate/redist/standalone/7.6.7600.320/WindowsUpdateAgent-7.6-x64.exe
if not defined WUA_32_URL set WUA_32_URL=http://download.windowsupdate.com/windowsupdate/redist/standalone/7.6.7600.320/WindowsUpdateAgent-7.6-x86.exe

if defined ProgramFiles(x86) (
    set WUA_URL=%WUA_64_URL%
) else (
    set WUA_URL=%WUA_32_URL%
)

for %%i in (%WUA_URL%) do set WUA_EXE=%%~nxi
set WUA_DIR=%TEMP%\wua
set WUA_PATH=%WUA_DIR%\%WUA_EXE%

echo ==^> Creating "%WUA_DIR%"
mkdir "%WUA_DIR%"

call "%SystemRoot%\_download.cmd" "%WUA_URL%" "%WUA_PATH%"
if errorlevel 1 (
    echo ==^> ERROR: Unable to download file from %WUA_URL%
    goto exit1
)

if not exist "%WUA_PATH%" goto exit1

echo ==^> Upgrading Windows Update Agent
"%WUA_PATH%" /quiet

echo ==^> Removing "%WUA_DIR%"
rmdir /q /s "%WUA_DIR%"

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
