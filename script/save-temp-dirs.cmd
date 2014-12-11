@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

echo ==^> Saving all installation files

if not defined PACKER_LOG_DIR set PACKER_LOG_DIR=z:\c\packer_logs

set PACKER_LOG_PATH=%PACKER_LOG_DIR%\%COMPUTERNAME%
if not exist "%PACKER_LOG_PATH%" mkdir "%PACKER_LOG_PATH%"
if not exist "%PACKER_LOG_PATH%" echo ==^> WARNING: Unable to create directory "%PACKER_LOG_PATH%" & goto exit0

xcopy /c /i /y "%TEMP%\*.log.txt" "%PACKER_LOG_PATH%\"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: xcopy /c /i /y "%TEMP%\*.log.txt" "%PACKER_LOG_PATH%\"

xcopy /c /e /h /i /k /r /y "%TEMP%" "%PACKER_LOG_PATH%\temp\"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: xcopy /c /e /h /i /k /r /y "%TEMP%" "%PACKER_LOG_PATH%\temp\"

xcopy /c /e /h /i /k /r /y "%SystemRoot%\TEMP" "%PACKER_LOG_PATH%\windows_temp\"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: xcopy /c /e /h /i /k /r /y "%SystemRoot%\TEMP" "%PACKER_LOG_PATH%\windows_temp\"

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

