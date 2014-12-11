@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if "%1" == "" goto main

goto %1

goto :eof

::::::::::::
:find_tee
::::::::::::

set _TEE_CMD=

for %%i in (tee.cmd tee.exe) do set _TEE_CMD=%%~$PATH:i
if exist "%_TEE_CMD%" goto :eof

for %%i in ("%SystemRoot%" %PACKER_SEARCH_PATHS%) do if exist "%%~i\tee.exe" set _TEE_CMD=%%~i\tee.exe
if exist "%_TEE_CMD%" goto :eof

for %%i in ("%SystemRoot%" %PACKER_SEARCH_PATHS%) do if exist "%%~i\tee.cmd" set _TEE_CMD=%%~i\tee.cmd
if exist "%_TEE_CMD%" goto :eof

set _TEE_CMD=%SystemRoot%\tee.cmd
set _TEE_JS=%SystemRoot%\tee.js

:: see http://stackoverflow.com/a/10719322/1432614
echo var fso = new ActiveXObject("Scripting.FileSystemObject");>"%_TEE_JS%"
echo var out = fso.OpenTextFile(WScript.Arguments(0),2,true);>>"%_TEE_JS%"
echo var chr;>>"%_TEE_JS%"
echo while( ^^!WScript.StdIn.AtEndOfStream ) {>>"%_TEE_JS%"
echo   chr=WScript.StdIn.Read(1);>>"%_TEE_JS%"
echo   WScript.StdOut.Write(chr);>>"%_TEE_JS%"
echo   out.Write(chr);>>"%_TEE_JS%"
echo }>>"%_TEE_JS%"

echo @cscript //E:JScript //nologo "%_TEE_JS%" %%* >"%_TEE_CMD%"

set _TEE_JS=

goto :eof

::::::::::::
:output_debug_info
::::::::::::

@echo on

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

netstat -an

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

goto :eof

::::::::::::
:main
::::::::::::

set _PACKER_LOG_ID=

for /f %%a in ("%TIME%") do for /f "delims=:. tokens=1-4" %%b in ("%%a") do (
  if %%b leq 9 (
    set _PACKER_LOG_ID=0%%b-%%c-%%d.%%e
  ) else (
    set _PACKER_LOG_ID=%%b-%%c-%%d.%%e
  )
)

if not defined _PACKER_LOG_ID set _PACKER_LOG_ID=%RANDOM%

set PACKER_DEBUG_LOG=%TEMP%\packer_debug_%_PACKER_LOG_ID%.log.txt

echo ==^> Generating debug log

call :find_tee

call "%~0" output_debug_info | "%_TEE_CMD%" "%PACKER_DEBUG_LOG%"

if not defined PACKER_LOG_DIR set PACKER_LOG_DIR=z:\c\packer_logs

set PACKER_LOG_PATH=%PACKER_LOG_DIR%\%COMPUTERNAME%

echo ==^> Saving debug log to "%PACKER_LOG_PATH%"

if not exist "%PACKER_LOG_PATH%" mkdir "%PACKER_LOG_PATH%"
if not exist "%PACKER_LOG_PATH%" echo ==^> WARNING: Unable to create directory "%PACKER_LOG_PATH%" & goto exit0

xcopy /c /e /h /i /k /r /y "%PACKER_DEBUG_LOG%" "%PACKER_LOG_PATH%\"

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
