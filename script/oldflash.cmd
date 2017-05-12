@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined OLDFLASH_URL set OLDFLASH_URL=http://download.oldapps.com/Flash_Player/install_flash_player14.0.0.145_ax.exe

for %%i in ("%OLDFLASH_URL%") do set OLDFLASH_EXE=%%~nxi
set OLDFLASH_DIR=%TEMP%\oldflash
set OLDFLASH_PATH=%OLDFLASH_DIR%\%OLDFLASH_EXE%

echo ==^> Creating "%OLDFLASH_DIR%"
mkdir "%OLDFLASH_DIR%"
pushd "%OLDFLASH_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%OLDFLASH_URL%" "%OLDFLASH_PATH%"
) else (
  echo ==^> Downloading "%OLDFLASH_URL%" to "%OLDFLASH_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%OLDFLASH_URL%', '%OLDFLASH_PATH%')" <NUL
)
if not exist "%OLDFLASH_PATH%" goto exit1

echo ==^> Installing old flash on %SystemDrive%
"%OLDFLASH_PATH%" -install
echo AutoUpdateDisable=1 > %SYSTEMROOT%\System32\Macromed\Flash\mms.cfg

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%OLDFLASH_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%OLDFLASH_DIR%"
rmdir /q /s "%OLDFLASH_DIR%"

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

