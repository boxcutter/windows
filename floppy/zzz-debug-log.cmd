@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

if "%1" == "output_debug_info" goto output_debug_info

set LOG_ID=%RANDOM%

for /f %%a in ("%TIME%") do for /f "delims=:. tokens=1-4" %%b in ("%%a") do (
  if %%b leq 9 (
    set LOG_ID=0%%b-%%c-%%d.%%e
  ) else (
    set LOG_ID=%%b-%%c-%%d.%%e
  )
)

set PACKER_DEBUG_LOG=%TEMP%\packer_debug_%LOG_ID%.log.txt

echo ==^> Displaying debug log

call "%~0" output_debug_info

echo ==^> Saving debug log to "%PACKER_DEBUG_LOG%"

call "%~0" output_debug_info >"%PACKER_DEBUG_LOG%"

if not defined PACKER_LOG_DIR set PACKER_LOG_DIR=z:\c\packer_logs

set PACKER_LOG_PATH=%PACKER_LOG_DIR%\%COMPUTERNAME%

echo ==^> Saving all installation files to "%PACKER_LOG_PATH%"

if not exist "%PACKER_LOG_PATH%" mkdir "%PACKER_LOG_PATH%"
if not exist "%PACKER_LOG_PATH%" echo ==^> WARNING: Unable to create directory "%PACKER_LOG_PATH%" & goto exit0

xcopy /c /e /h /i /k /r /y "%TEMP%\*.log.txt" "%PACKER_LOG_PATH%\"
xcopy /c /e /h /i /k /r /y "%TEMP%" "%PACKER_LOG_PATH%\temp\"
xcopy /c /e /h /i /k /r /y "%SystemRoot%\TEMP" "%PACKER_LOG_PATH%\windows_temp\"

goto exit0

::::::::::::
:output_debug_info
::::::::::::

echo on

@echo %date% %time%: %0 log started

for %%i in (a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:) do if exist "%%~i" dir "%%~i\"

@echo ==============================

dir "%ProgramFiles%"

@echo ==============================

if defined ProgramFiles(x86) dir "%ProgramFiles(x86)%"

@echo ==============================

for /r %SystemDrive%\ %%i in (*.iso) do echo %%i

@echo ==============================

for /r "%USERPROFILE%\.ssh" %%i in (*.*) do type "%%~i"

@echo ==============================

set | sort

@echo ==============================

ipconfig

@echo ==============================

systeminfo

@echo ==============================

net start

@echo ==============================

for %%i in (%PACKER_SERVICES%) do (
  sc query %%i
)

:: echo ==^> reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP" /s:

:: reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP" /s

@echo ==============================

for %%i in ("%USERPROFILE%\AppData\Local\Temp" "%SystemRoot%\TEMP") do if exist "%%~i" dir /s "%%~i\"

@echo ==============================

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
