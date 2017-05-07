@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

call :init vmtool.bat %*

if not defined OSArchitecture (
    for /f "tokens=*" %%i in ('wmic os get OSArchitecture /value ^| find "="') do (
        set %%i
    )
)

echo "%PACKER_BUILDER_TYPE%" | findstr /i "vmware" >nul
if %ERRORLEVEL% equ 0 (
    goto vmware
)
echo "%PACKER_BUILDER_TYPE%" | findstr /i "virtualbox" >nul
if %ERRORLEVEL% equ 0 (
    goto virtualbox
)
echo "%PACKER_BUILDER_TYPE%" | findstr /i "parallels" >nul
if %ERRORLEVEL% equ 0 (
    goto parallels
)
call :error Unknown PACKER_BUILDER_TYPE: "%PACKER_BUILDER_TYPE%"
goto exit1


:vmware

    if /i "%OSArchitecture%" == "32-bit" (
        set VMWARE_TOOLS_SETUP_EXE=setup.exe
    ) else (
        set VMWARE_TOOLS_SETUP_EXE=setup64.exe
    )

    for %%i in ("%VMWARE_TOOLS_TAR_URL%") do (
        set VMWARE_TOOLS_TAR=%%~nxi
    )

    set VMWARE_TOOLS_DIR=%PACKER_TMP%\vmware
    set VMWARE_TOOLS_TAR_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_TAR%
    set VMWARE_TOOLS_ISO=windows.iso

    call :run mkdir "%VMWARE_TOOLS_DIR%"

    set VMWARE_TOOLS_SETUP_PATH=
    for %%i in (%PACKER_SEARCH_PATHS%) do (
        if not defined VMWARE_TOOLS_SETUP_PATH (
            if exist "%%~i\VMwareToolsUpgrader.exe" (
                set VMWARE_TOOLS_SETUP_PATH=%%~i\%VMWARE_TOOLS_SETUP_EXE%
            )
        )
    )
    if defined VMWARE_TOOLS_SETUP_PATH (
        goto install_vmware_tools
    )

    call :locate "%VMWARE_TOOLS_ISO%"
    set VMWARE_TOOLS_ISO_PATH=%located_file%

    :: if windows.iso is zero bytes, then download it
    set _VMWARE_TOOLS_SIZE=0
    if defined VMWARE_TOOLS_ISO_PATH (
        for %%i in (%VMWARE_TOOLS_ISO_PATH%) do (
            set _VMWARE_TOOLS_SIZE=%%~zi
        )
    )
    if %_VMWARE_TOOLS_SIZE% equ 0 (
        set VMWARE_TOOLS_ISO_PATH=
    )
    if defined VMWARE_TOOLS_ISO_PATH (
        goto install_vmware_tools_from_iso
    )

    call :wget "%VMWARE_TOOLS_TAR_URL%" "%VMWARE_TOOLS_TAR_PATH%"
    if %ERRORLEVEL% neq 0 (
        goto exit
    )

    call :install_sevenzip
    where /q $path:7z.exe
    if %ERRORLEVEL% neq 0 (
        goto exit
    )

    call :run 7z e -y -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_TAR_PATH%" *tools-windows*
    if exist  "%VMWARE_TOOLS_DIR%\*.iso" (
        ren "%VMWARE_TOOLS_DIR%\*.iso" "windows.iso"
        set VMWARE_TOOLS_ISO_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISO%
    )

    if defined VMWARE_TOOLS_ISO_PATH (
        goto install_vmware_tools_from_iso
    )

    set VMWARE_TOOLS_INSTALLER_PATH=
    for %%i in ("%VMWARE_TOOLS_DIR%\tools-windows-*.exe") do (
        set VMWARE_TOOLS_INSTALLER_PATH=%%~i
    )
    if not exist "%VMWARE_TOOLS_INSTALLER_PATH%" (
        call :error Failed to unzip "%VMWARE_TOOLS_TAR_PATH%"
        goto exit1
    )

    call :run "%VMWARE_TOOLS_INSTALLER_PATH%" /s /l"%PACKER_TMP%\vmware_tools_installer.log"

    set VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles%\VMware
    if defined ProgramFiles(x86) (
        set VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles(x86)%\VMware
    )
    if not exist "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" (
        call :error Directory not found: "%VMWARE_TOOLS_PROGRAM_FILES_DIR%"
        goto exit1
    )

    set VMWARE_TOOLS_PROGRAM_FILES_ISO=
    for /r "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" %%i in (%VMWARE_TOOLS_ISO%) do (
        if exist "%%~i" (
            set VMWARE_TOOLS_PROGRAM_FILES_ISO=%%~i
        )
    )

    if not exist "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" (
        call :error File not found: "%VMWARE_TOOLS_ISO%" in "%VMWARE_TOOLS_PROGRAM_FILES_DIR%"
        goto exit1
    )

    set VMWARE_TOOLS_ISO_PATH="%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISO%"

    call :run copy /y "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" "%VMWARE_TOOLS_ISO_PATH%"
    if not exist "%VMWARE_TOOLS_ISO_PATH%" (
        call :error File not found: "%VMWARE_TOOLS_ISO_PATH%"
        goto exit1
    )

    rmdir /q /s "%VMWARE_TOOLS_PROGRAM_FILES_DIR%\tools-windows" || ver >nul

    rmdir "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" || ver >nul

    :install_vmware_tools_from_iso

    call :install_sevenzip
    where /q $path:7z.exe
    if %ERRORLEVEL% neq 0 (
        goto exit
    )

    call :run 7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"

    set VMWARE_TOOLS_SETUP_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_SETUP_EXE%

    if not exist "%VMWARE_TOOLS_SETUP_PATH%" (
        call :error %_arg0%: Unable to unzip "%VMWARE_TOOLS_ISO_PATH%"
        goto exit1
    )

    :install_vmware_tools

    call :run "%VMWARE_TOOLS_SETUP_PATH%" /s /v "/qn REBOOT=ReallySuppress ADDLOCAL=ALL" /l"%PACKER_TMP%\vmware_tools.log"

    goto exit0


:virtualbox

    if /i "%OSArchitecture%" == "32-bit" (
        set VBOX_SETUP_EXE=VBoxWindowsAdditions-x86.exe
    ) else (
        set VBOX_SETUP_EXE=VBoxWindowsAdditions-amd64.exe
    )

    for %%i in ("%VBOX_ISO_URL%") do (
        set VBOX_ISO=%%~nxi
    )

    set VBOX_ISO_DIR=%PACKER_TMP%\virtualbox
    set VBOX_ISO_PATH=%VBOX_ISO_DIR%\%VBOX_ISO%
    set VBOX_ISO=VBoxGuestAdditions.iso

    call :run mkdir "%VBOX_ISO_DIR%"

    call :locate "%VBOX_SETUP_EXE%"
    set VBOX_SETUP_PATH=%located_file%

    if defined VBOX_SETUP_PATH (
        goto install_vbox_guest_additions
    )

    call :locate "%VBOX_ISO%"
    set VBOX_ISO_PATH=%located_file%

    :: if VBoxGuestAdditions.iso is zero bytes, then download it
    set _VBOX_ISO_SIZE=0
    if exist "%VBOX_ISO_PATH%" (
        for %%i in (%VBOX_ISO_PATH%) do (
            set _VBOX_ISO_SIZE=%%~zi
        )
    )
    if %_VBOX_ISO_SIZE% gtr 0 (
        goto install_vbox_guest_additions_from_iso
    )

    call :wget "%VBOX_ISO_URL%" "%VBOX_ISO_PATH%"
    if %ERRORLEVEL% neq 0 (
        goto exit
    )

    :install_vbox_guest_additions_from_iso

    call :install_sevenzip

    where /q $path:7z.exe
    if %ERRORLEVEL% neq 0 (
        goto exit
    )

    call :run 7z e -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%"

    set VBOX_SETUP_PATH=%VBOX_ISO_DIR%\%VBOX_SETUP_EXE%
    if not exist "%VBOX_SETUP_PATH%" (
        call :error %_arg0% Unable to unzip "%VBOX_ISO_PATH%"
        goto exit1
    )

    :install_vbox_guest_additions

    if not exist a:\oracle-cert.cer (
        call :error File not found: a:\oracle-cert.cer
        goto exit1
    )

    call :run certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer

    call :run "%VBOX_SETUP_PATH%" /l /S

    goto exit0


:parallels

    set PARALLELS_INSTALL=PTAgent.exe

    set PARALLELS_DIR=%PACKER_TMP%\parallels
    set PARALLELS_PATH=%PARALLELS_DIR%\%PARALLELS_INSTALL%
    set PARALLELS_ISO=prl-tools-win.iso
    call :run mkdir "%PARALLELS_DIR%"

    call :locate "%PARALLELS_ISO%"
    set PARALLELS_ISO_PATH=%located_file%

    REM parallels tools don't have a download :^(
    call :install_sevenzip
    where /q $path:7z.exe
    if %ERRORLEVEL% neq 0 (
        goto exit
    )
    @echo ==^> Extracting the Parallels Tools installer
    @echo ==^>   to %PARALLELS_DIR%\*
    call :run 7z x -o"%PARALLELS_DIR%" "%PARALLELS_ISO_PATH%"
    @echo ==^> Installing Parallels Tools
    @echo ==^>   from %PARALLELS_PATH%
    call :run "%PARALLELS_PATH%" /install_silent
    REM parallels tools installer tends to exit while the install agent
    REM is still running, need to sleep while it's running so we don't
    REM delete the tools.
    @echo ==^> Cleaning up Parallels Tools install
    del /f /s /q "%PARALLELS_DIR"
    @echo ==^> Removing "%PARALLELS_ISO_PATH"
    del /f "%PARALLELS_ISO_PATH"
    goto exit0


:install_sevenzip

    set _7z_exe=
    set _7z_dll=
    for %%i in (7z.exe) do (
        set _7z_exe=%%~$PATH:i
    )
    if defined _7z_exe (
        set _7z_exe=
        goto return0
    )
    for %%i in (%PACKER_SEARCH_PATHS%) do (
        if not defined _7z_exe (
            if exist "%%~i\7z.exe" (
                set _7z_exe=%%~i\7z.exe
            )
        )
    )
    if not defined _7z_exe (
        goto get_sevenzip
    )
    for %%i in (%PACKER_SEARCH_PATHS%) do (
        if not defined _7z_dll (
            if exist "%%~i\7z.dll" (
                set _7z_dll=%%~i\7z.dll
            )
        )
    )
    if not defined _7z_dll (
        goto get_sevenzip
    )
    call :copy_sevenzip
    if %ERRORLEVEL% equ 0 (
        goto return0
    )

    :get_sevenzip

    for %%i in ("%SEVENZIP_URL%") do (
        set _7z_msi=%%~nxi
    )
    set _7z_path=%PACKER_TMP%\%_7z_msi%
    call :wget "%SEVENZIP_URL%" "%_7z_path%"
    if %ERRORLEVEL% neq 0 (
        goto return1
    )
    call :run msiexec /qb /i "%_7z_path%"
    set _7z_dir=
    for %%i in ("%ProgramFiles%" "%ProgramW6432%" "%ProgramFiles(x86)%") do (
        if exist "%%~i\7-Zip" (
            set _7z_dir=%%~i\7-Zip
        )
    )
    if exist "%_7z_dir%" (
        cd /d "%_7z_dir%"
        goto find_sevenzip
    )
    call :error Directory not found: "%ProgramFiles%\7-Zip"
    goto return1


    :find_sevenzip
        set _7z_exe=
        for /r %%i in (7z.exe) do (
            if exist "%%~i" (
                set _7z_exe=%%~i
            )
        )
        if not exist "%_7z_exe%" (
            call :error Failed to unzip "%_7z_path%"
            goto return1
        )
        set _7z_dll=
        for /r %%i in (7z.dll) do (
            if exist "%%~i" (
                set _7z_dll=%%~i
            )
        )
        if not exist "%_7z_dll%" (
            call :error Failed to unzip "%_7z_path%"
            goto return1
        )

    :copy_sevenzip
        call :debug Copying "%_7z_exe%" to "%SystemRoot%"
        ver >nul
        call :run copy /y "%_7z_exe%" "%SystemRoot%\"
        if %ERRORLEVEL% neq 0 (
            goto return1
        )
        call :run copy /y "%_7z_dll%" "%SystemRoot%\"
        if %ERRORLEVEL% neq 0 (
            goto return1
        )
        goto return0

    :return0
        ver >nul
        goto :eof

    :return1
        verify other 2>nul
        goto :eof

    :return
        goto :eof

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
