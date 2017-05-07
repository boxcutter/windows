@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

call :init %0 %*

call :debug Turning off User Account Control [UAC]
:: see http://www.howtogeek.com/howto/windows-vista/enable-or-disable-uac-from-the-windows-vista-command-line/
call :run reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f

call :debug Setting the PowerShell ExecutionPolicy to RemoteSigned [64 bit]
call :run powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <nul

if exist "%SystemRoot%\SysWOW64\cmd.exe" (
  call :debug Setting the PowerShell ExecutionPolicy to RemoteSigned [32 bit]
  call :run "%SystemRoot%\SysWOW64\cmd.exe" /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <nul
)

call :info Executing: wmic os get Caption ^| findstr /c:"Windows 7" /c:"Windows 10"

wmic os get Caption /value | findstr /c:"Windows 7" /c:"Windows 10" >nul
if %ERRORLEVEL% neq 0 (
    goto skip_fixnetwork
)

if not exist a:\fixnetwork.ps1 (
    call :error %0: File not found: a:\fixnetwork.ps1
    goto skip_network
)

call :debug Setting the Network Location to private
:: see http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
call :run powershell -File a:\fixnetwork.ps1 <nul

:skip_fixnetwork

call :debug Changing remote UAC account policy
call :run reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

call :debug Blocking WinRM port 5985 on the firewall
call :run netsh advfirewall firewall add rule name="winrm"  dir=in action=block protocol=TCP localport=5985

call :debug Configuring Windows Remote Management [WinRM] service

if "%PACKER_DEBUG%" geq "5" (
    set WINRMCP_DEBUG=1
)

call :run call winrm quickconfig -q

call :run call winrm quickconfig -transport:http

call :run call winrm set winrm/config @{MaxTimeoutms="1800000"}

call :run call winrm set winrm/config/client/auth @{Basic="true"}

call :run call winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}

call :run call winrm set winrm/config/service @{AllowUnencrypted="true"}

call :run call winrm set winrm/config/service @{MaxConcurrentOperationsPerUser="1000"}

call :run call winrm set winrm/config/service/auth @{Basic="true"}

call :run call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="2048"}

call :run call winrm set winrm/config/winrs @{MaxShellsPerUser="5"}

:: the space after start= is required
call :run sc config winrm start= disabled

:: wait for winrm service to finish starting
call :sleep 5

sc query winrm | findstr "RUNNING" >nul
if %ERRORLEVEL% neq 0 (
    goto winrm_not_running
)

call :debug Stopping winrm service

call :run sc stop winrm

:is_winrm_running

call :sleep 1

sc query winrm | findstr "STOPPED" >nul
if %ERRORLEVEL% neq 0 (
    goto is_winrm_running
)

:winrm_not_running

call :debug Unblocking WinRM port 5985 on the firewall
call :run netsh advfirewall firewall delete rule name="winrm"

:: see https://community.spiceworks.com/topic/105916-netsh-advfirewall-remote-administration-new-enable-yes-no-rules-match

call :run netsh firewall set service type=remoteadmin mode=enable

call :run netsh advfirewall firewall set rule group="remote administration" new enable=yes

call :debug Opening WinRM port 5985 on the firewall
:: see http://social.technet.microsoft.com/Forums/windowsserver/en-US/a1e65f0f-2550-49ae-aee2-56a9bdcfb8fb/windows-7-remote-administration-firewall-group?forum=winserverManagement
call :run netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

call :run netsh advfirewall firewall add rule name="winrm"  dir=in action=allow protocol=TCP localport=5985

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
