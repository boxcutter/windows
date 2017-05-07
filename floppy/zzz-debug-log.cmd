@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

call :init %0 %*

if not defined PACKER_LOG_DIR (
    set PACKER_LOG_DIR=z:\c\packer_logs
)

if "%1" == "" (
    goto main
)

goto %1

goto :eof

::::::::::::
:output_debug_info
::::::::::::

@echo on

@echo %date% %time%: %0 log started

for %%i in (a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:) do (
    if exist "%%~i" (
        dir "%%~i\"
    )
)

@echo ==============================

dir "%ProgramFiles%"

@echo ==============================

if defined ProgramFiles(x86) (
    dir "%ProgramFiles(x86)%"
)

@echo ==============================

for /r %SystemDrive%\ %%i in (*.iso) do (
    echo %%i
)

@echo ==============================

for /r "%USERPROFILE%\.ssh" %%i in (*.*) do (
    type "%%~i"
)

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

:: echo ==^> reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP" /s:

:: reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP" /s

@echo ==============================

for %%i in ("%USERPROFILE%\AppData\Local\Temp" "%SystemRoot%\TEMP") do (
    if exist "%%~i" (
        dir /s "%%~i\"
    )
)

@echo ==============================

goto :eof

::::::::::::
:main
::::::::::::

set _log_id=

for /f %%a in ("%TIME%") do (
    for /f "delims=:. tokens=1-4" %%b in ("%%a") do (
      if %%b leq 9 (
        set _log_id=0%%b-%%c-%%d.%%e
      ) else (
        set _log_id=%%b-%%c-%%d.%%e
      )
    )
)

if not defined _log_id (
    set _log_id=%RANDOM%
)

set _debug_log=%PACKER_TMP%\packer_debug_%_log_id%.log

echo ==^> Generating debug log

call "%~0" output_debug_info | "%TEE_CMD%" "%_debug_log%"

set _log_path=%PACKER_LOG_DIR%\%COMPUTERNAME%

echo ==^> Saving debug log to "%_log_path%"

if not exist "%_log_path%" (
    mkdir "%_log_path%"
)
if not exist "%_log_path%" (
    echo ==^> WARNING: Unable to create directory "%_log_path%"
    goto exit0
)

xcopy /c /e /h /i /k /r /y "%_debug_log%" "%_log_path%\"

goto exit0

:exit
    :: the rest if this file was appended from /suffix.cmd
    @if %ERRORLEVEL% equ 0 (
        @call :info %~nx0: exiting with %ERRORLEVEL%
        @if defined PACKER_PAUSE (
            @call :pause %PACKER_PAUSE%
        )
        @exit /b 0
        @goto :eof
    )
    @call :error %~nx0: exiting with %ERRORLEVEL%
    @if defined PACKER_IGNORE_ERRORS (
        @call :debug Setting exit code to 0 as PACKER_IGNORE_ERRORS is set
        @exit /b 0
        @goto :eof
    )
    @if defined PACKER_PAUSE_ON_ERROR (
        @set _el=%ERRORLEVEL%
        @call :pause
        @exit /b %_el%
        @goto :eof
    )
    @if defined PACKER_SHUTDOWN_ON_ERROR (
        @call :info Shutting down as PACKER_SHUTDOWN_ON_ERROR is set...
        @shutdown /s /t 0 /f /d p:4:1 /c "Packer shutdown as %0 returned error %ERRORLEVEL%"
        @ping -t 127.0.0.1
    )
    @exit /b %ERRORLEVEL%
    goto :eof

:exit0
    @ver >nul
    @goto exit

:exit1
    @verify other 2>nul
    @goto exit

:download
    @for %%z in ("%~1") do @(
        @set _filename=%%~nxz
    )
    @set downloaded_file=%~2
    @if defined _filename (
        @call :locate "%_filename%"
        @if exist "!located_file!" (
            @set downloaded_file=!located_file!
            @ver >nul
            @goto :eof
        )
        @if not defined downloaded_file (
            @set downloaded_file=%PACKER_TMP%\%_filename%
        )
    )
    @call :wget "%~1" "%downloaded_file%"
    @if not exist "%downloaded_file%" (
        @set downloaded_file=
    )
    @set _filename=
    @goto :eof

:init
    @set _arg0=%~nx1
    @call :set_vars
    @rem Directory must exist, so let's create it
    @if not exist "%PACKER_TMP%" (
        @mkdir "%PACKER_TMP%"
    )
    @call :set_tee_cmd
    @call :set_powershell_version
    @call :info %_arg0%: starting in %CD%: %*
    @goto :eof

:locate
    @set located_file=
    @for %%z in (%PACKER_SEARCH_PATHS%) do @(
        @if not defined located_file (
            @if exist "%%~z\%~1" (
                @set located_file=%%~z\%~1
            )
        )
    )
    @if not defined located_file (
        @for %%z in ("%~1") do @(
            @set located_file=%%~$PATH:z
        )
    )
    @goto :eof

:log
    @echo %TIME% %*
    @echo %TIME% %* >>"%PACKER_LOG%"
    @goto :eof

:debug
    @if "%PACKER_DEBUG%" geq "4" (
        @call :log [DEBUG] %*
    )
    @goto :eof

:info
    @if "%PACKER_DEBUG%" geq "3" (
        @call :log [INFO ] %*
    )
    @goto :eof

:warn
    @if "%PACKER_DEBUG%" geq "2" (
        @call :log [WARN ] %*
    )
    @goto :eof

:error
    @if "%PACKER_DEBUG%" geq "1" (
        @call :log [ERROR] %*
    )
    @goto :eof

:fatal
    @call :log [FATAL] %*
    @goto :eof

:pause
    @set _pause_seconds=%1
    @if not defined _pause_seconds (
        @set _pause_seconds=2147483647
    )
    @set _tempfile=%USERPROFILE%\Desktop\DeleteToContinue.txt
    @echo Remove this file to continue >"%_tempfile%"
    @echo Waiting %_pause_seconds% seconds, or for %_tempfile% to disappear...
    @for /f %%z in ('copy "%~f0" nul /z') do @(
        @set "_cr=%%z"
    )
    @for /l %%z in (1,1,%_pause_seconds%) do @(
        @if exist "%_tempfile%" (
            @if defined PACKER_BUILD_NAME (
                @if "%PACKER_DEBUG%" geq "4" (
                    @set /p ".=Waiting %%z of %_pause_seconds% seconds, or for %_tempfile% to disappear...!_cr!" <nul
                )
                @call :sleep 1
            ) else (
                @set /p ".=Waiting %%z of %_pause_seconds% seconds, a key to be pressed, or for %_tempfile% to disappear...!_cr!" <nul
                @timeout /T 1 >nul
            )
        )
    )
    @echo.
    @if exist "%_tempfile%" (
        @del "%_tempfile%"
    )
    @set _cr=
    @set _tempfile=
    @set _pause_seconds=
    @goto :eof

:run
    @call :info Executing: %*
    @ver >nul
    @%*
    @if %ERRORLEVEL% equ 3010 (
        @call :info %ERRORLEVEL% [reboot required] returned by: %*
        @goto :eof
    )
    @if %ERRORLEVEL% neq 0 (
        @call :error %ERRORLEVEL% returned by: %*
    )
    @goto :eof

:schtask
    @if not defined _schtask_cmd (
        @if defined PACKER_BUILD_NAME (
            @call :locate _schtask.cmd
            @if exist "%located_file%" (
                @set _schtask_cmd=call "%located_file%"
            )
        )
        @if not defined _schtask_cmd (
            @set _schtask_cmd=call
        )
    )
    @call :run %_schtask_cmd% %*
    @goto :eof

:set_powershell_version
    @if not defined POWERSHELL_VERSION (
        @for %%x in (3 1) do @(
            @if not defined POWERSHELL_VERSION (
                @for /f "tokens=2*" %%y in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\%%x\PowerShellEngine" /v PowerShellVersion') do @(
                    @set POWERSHELL_VERSION=%%~z
                )
            )
        )
    )
    @goto :eof

:set_tee_cmd
    @if not defined TEE_CMD (
        @call :locate tee.exe
        @if exist "%located_file%" (
            @set TEE_CMD="%located_file%"
        )
        @if not defined TEE_CMD (
            @call :locate _tee.cmd
            @if exist "%located_file%" (
               @set TEE_CMD="%located_file%"
            )
        )
        @if not defined TEE_CMD (
            @set TEE_CMD=echo
        )
    )
    @goto :eof

:set_vars
    @if not defined CHOCOLATEY_APPS (
        @set CHOCOLATEY_APPS=chocolatey*.txt
    )
    @if not defined CHOCOLATEY_INSTALL_OPTIONS (
        @set CHOCOLATEY_INSTALL_OPTIONS=--force
    )
    @if not defined CYGWIN_MIRROR_URL (
        @set CYGWIN_MIRROR_URL=http://mirrors.kernel.org/sourceware/cygwin
    )
    @if not defined MIN_POWERSHELL_VERSION (
        @set MIN_POWERSHELL_VERSION=2.0
    )
    @if not defined PACKER_DEBUG (
        @set PACKER_DEBUG=3
    )
    @if not defined PACKER_LOG_DIR (
        @set PACKER_LOG_DIR=z:\c\packer_logs
    )
    @if not defined PACKER_PAGEFILE_MB (
        @set PACKER_PAGEFILE_MB=512
    )
    @if not defined PACKER_PASSWORD (
        @set PACKER_PASSWORD=%USERNAME%
    )
    @if not defined PACKER_RUN (
        @set PACKER_RUN=_run-scripts.txt
    )
    @if not defined PACKER_SCRIPTS_TO_RUN (
        @set PACKER_SCRIPTS_TO_RUN=*.bat *.cmd *.ps1
    )
    @if not defined PACKER_SEARCH_PATHS (
        @set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
    )
    @if not defined PACKER_SERVICES (
        @set PACKER_SERVICES=opensshd sshd winrm
    )
    @if not defined PACKER_TIMEOUT (
        @set PACKER_TIMEOUT=2700
    )
    @if not defined PACKER_TMP (
        @set PACKER_TMP=%TEMP%\packer
    )
    @if not defined PACKER_LOG (
        @set PACKER_LOG=%PACKER_TMP%\packer.log
    )
    @if not defined SCOOP_APPS (
        @set SCOOP_APPS=scoop*.txt
    )
    @if not defined SSHD_PASSWORD (
        @set SSHD_PASSWORD=D@rj33l1ng
    )
    @if not exist "%PACKER_TMP%" (
        @mkdir "%PACKER_TMP%"
    )
    @goto :eof

:sleep
    @set /a "_sleep=%1+1" >nul
    @ping -n %_sleep% 127.0.0.1 >nul 2>nul
    @set _sleep=
    @goto :eof

:stop
    @call :sleep 5
    @sc query "%~1" | findstr "RUNNING" >nul 2>nul
    @if %ERRORLEVEL% neq 0 (
        @goto :eof
    )
    @call :run sc stop "%~1"
    @for /l %%z in (1,1,60) do @(
        @call :sleep 1
        @sc query "%~1" | findstr "STOPPED" >nul 2>nul
        @if %ERRORLEVEL% equ 0 (
            @goto :eof
        )
    )
    @goto :eof

:wget
    @where /q $path:_download.cmd
    @if %ERRORLEVEL% neq 0 (
        @if exist "a:\01-install-wget.cmd" (
            @call "a:\01-install-wget.cmd"
        )
    )
    @call :run call _download.cmd %*
    @goto :eof

:unzip
    @where /q $path:_unzip.cmd
    @if %ERRORLEVEL% neq 0 (
        @if exist "a:\01-install-unzip.cmd" (
            @call "a:\01-install-unzip.cmd"
        )
    )
    @call :run call _unzip.cmd %*
    @goto :eof

:: end of /suffix.cmd
