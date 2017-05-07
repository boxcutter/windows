@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

call :init %0 %*

call :download "%OPENSSH_URL%"
if %ERRORLEVEL% neq 0 (
    goto exit
)

call :debug Blocking SSH port 22 on the firewall
call :run netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="%ProgramFiles%\OpenSSH\usr\sbin\sshd.exe" enable=yes
call :run netsh advfirewall firewall add rule name="ssh"  dir=in action=block protocol=TCP localport=22

call :debug Installing OpenSSH
call :run "%downloaded_file%" /S /port=22 /privsep=1 /password=%SSHD_PASSWORD%

:: wait for opensshd service to finish starting
timeout 5

sc query opensshd | findstr "RUNNING" >nul
if %ERRORLEVEL% neq 0 (
    goto sshd_not_running
)

call :debug Stopping the sshd service
sc stop opensshd

:is_sshd_running

timeout 1

sc query opensshd | findstr "STOPPED" >nul
if %ERRORLEVEL% neq 0 (
    goto is_sshd_running
)

:sshd_not_running
ver >nul

call :debug Unblocking SSH port 22 on the firewall
call :run netsh advfirewall firewall delete rule name="SSHD"
call :run netsh advfirewall firewall delete rule name="ssh"

call :debug Setting temp location
call :run rmdir /q /s "%ProgramFiles%\OpenSSH\tmp"
call :run mklink /d "%ProgramFiles%\OpenSSH\tmp" "%SystemRoot%\Temp"

call :run icacls "%SystemRoot%\Temp" /grant %USERNAME%:(OI)(CI)F

call :debug Adding missing environment variables to %USERPROFILE%\.ssh\environment

if not exist "%USERPROFILE%\.ssh" (
    call :run mkdir "%USERPROFILE%\.ssh"
)

set _sshenv=%USERPROFILE%\.ssh\environment
echo.>"%_sshenv%"

echo>>"%_sshenv%" APPDATA=%SystemDrive%\Users\%USERNAME%\AppData\Roaming
echo>>"%_sshenv%" COMMONPROGRAMFILES=%SystemDrive%\Program Files\Common Files
echo>>"%_sshenv%" LOCALAPPDATA=%SystemDrive%\Users\%USERNAME%\AppData\Local
echo>>"%_sshenv%" PROGRAMDATA=%SystemDrive%\ProgramData
echo>>"%_sshenv%" PROGRAMFILES=%SystemDrive%\Program Files
echo>>"%_sshenv%" PSMODULEPATH=%SystemDrive%\Windows\system32\WindowsPowerShell\v1.0\Modules\
echo>>"%_sshenv%" PUBLIC=%SystemDrive%\Users\Public
echo>>"%_sshenv%" SESSIONNAME=Console
echo>>"%_sshenv%" TEMP=%SystemDrive%\Users\%USERNAME%\AppData\Local\Temp
echo>>"%_sshenv%" TMP=%SystemDrive%\Users\%USERNAME%\AppData\Local\Temp
:: This fix simply masks the issue, we need to fix the underlying cause
:: to override sshd_server:
:: echo USERNAME=%USERNAME%>>"%_sshenv%"

if not defined OSArchitecture (
    for /f "tokens=*" %%i in ('wmic os get Version /value ^| find "="') do (
        set %%i
    )
)

if /i "%OSArchitecture%" == "64-bit" (
    echo>>"%_sshenv%" COMMONPROGRAMFILES^(X86^)=%SystemDrive%\Program Files ^(x86^)\Common Files
    echo>>"%_sshenv%" COMMONPROGRAMW6432=%SystemDrive%\Program Files\Common Files
    echo>>"%_sshenv%" PROGRAMFILES^(X86^)=%SystemDrive%\Program Files ^(x86^)
    echo>>"%_sshenv%" PROGRAMW6432=%SystemDrive%\Program Files
)

call :debug Fixing opensshd's configuration to be less strict
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace 'StrictModes yes', 'StrictModes no' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#UseDNS yes', 'UseDNS no' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"

call :debug Opening SSH port 22 on the firewall
call :run netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="%ProgramFiles%\OpenSSH\usr\sbin\sshd.exe" enable=yes
call :run netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

call :debug Ensuring user %USERNAME% can login
call :run icacls "%USERPROFILE%" /grant %USERNAME%:(OI)(CI)F
call :run icacls "%ProgramFiles%\OpenSSH\bin" /grant %USERNAME%:(OI)RX
call :run icacls "%ProgramFiles%\OpenSSH\usr\sbin" /grant %USERNAME%:(OI)RX

call :debug Setting user's home directories to their windows profile directory
call :run powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\passwd') | Foreach-Object { $_ -replace '/home/(\w+)', '/cygdrive/c/Users/$1' } | Set-Content '%ProgramFiles%\OpenSSH\etc\passwd'"

:: This fix simply masks the issue, we need to fix the underlying cause
:: call :debug Overriding sshd_server username in environment
:: reg add "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "@for %%i in (%%USERPROFILE%%) do @set USERNAME=%%~ni" /f

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
