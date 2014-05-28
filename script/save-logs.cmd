@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

echo ==^> Saving installation logs

if not defined PACKER_LOG_DIR set PACKER_LOG_DIR=z:\c\packer_logs

set PACKER_LOG_PATH=%PACKER_LOG_DIR%\%COMPUTERNAME%
if not exist "%PACKER_LOG_PATH%" mkdir "%PACKER_LOG_PATH%"
if not exist "%PACKER_LOG_PATH%" echo ==^> ERROR: Unable to create directory "%PACKER_LOG_PATH%" & goto exit1

xcopy /c /i /y "%TEMP%\*.log.txt" "%PACKER_LOG_PATH%"

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
