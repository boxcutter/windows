<!-- :
@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

call :init %0 %*

call :run cscript //nologo "%~f0?.wsf" %*

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
--->
<job><script language="VBScript">
Option Explicit

deleteStartupEntry

Dim updateSession, updateSearcher, searchResult
On Error Resume Next
Set updateSession = CreateObject("Microsoft.Update.Session")
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
updateSession.ClientApplicationID = "packer"
On Error Resume Next
Set updateSearcher = updateSession.CreateUpdateSearcher()
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
LogWrite "Searching for updates..."
On Error Resume Next
Set searchResult = updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
If searchResult.Updates.Count Then
    LogWrite "There are " & searchResult.Updates.Count & " applicable updates"
End if
If searchResult.Updates.Count = 0 Then
    LogWrite "There are no applicable updates."
    ExecutePostInstallBatch
    WScript.Quit(0)
End If

Dim updatesToDownload, updatesToInstall, installResult
Set updatesToDownload = getUpdatesToDownload(searchResult)
Set updatesToInstall = downloadUpdates(updateSession, updatesToDownload)
Set installResult = installUpdates(updateSession, updatesToInstall)
If installResult.RebootRequired Then
    addStartupEntry
    reboot(".")
    WScript.Quit(0)
Else
    ExecutePostInstallBatch
End If

WScript.Quit(0)

Sub ExecutePostInstallBatch
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")

    If (fso.FileExists("a:\_post_update_install.bat")) Then
        Dim objShell
        Set objShell = WScript.CreateObject("WScript.Shell")
        objShell.Run "a:\_post_update_install.bat"
    End If
End Sub

Sub LogWrite(message)
    Dim strFile, objFSO, objFile
    Const ForAppending = 8
    strFile = getTempDir() & "\update.log"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.OpenTextFile(strFile, ForAppending, True)
    objFile.WriteLine(Now & ": " & message)
    WScript.Echo message
    objFile.Close
End Sub

Function getUpdatesToDownload(searchResult)
    LogWrite "Creating collection of updates to download."
    Dim updatesToDownload, i
    On Error Resume Next
    Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
    For i = 0 to searchResult.Updates.Count-1
        Dim update, addThisUpdate
        Set update = searchResult.Updates.Item(i)
        addThisUpdate = false
        If update.InstallationBehavior.CanRequestUserInput = true Then
            LogWrite i + 1 & "> skipping: " & update.Title & " because it requires user input"
        Else
            If update.EulaAccepted = false Then
                LogWrite i + 1 & "> note: " & update.Title & " has a license agreement that must be accepted:"
                update.AcceptEula()
            End If
            addThisUpdate = true
        End If
        If addThisUpdate = true Then
            LogWrite i + 1 & "> adding: " & update.Title
            updatesToDownload.Add(update)
        End If
    Next

    If updatesToDownload.Count = 0 Then
        LogWrite "All applicable updates were skipped."
        WScript.Quit
    End If
    Set getUpdatesToDownload = updatesToDownload
End Function

Function downloadUpdates(updateSession, updatesToDownload)
    LogWrite "Downloading updates..."
    Dim updateDownloader
    Set updateDownloader = updateSession.CreateUpdateDownloader()
    updateDownloader.Updates = updatesToDownload
    updateDownloader.Download()
    LogWrite "Successfully downloaded updates..."

    Dim updatesToInstall, rebootMayBeRequired, i
    rebootMayBeRequired = false
    Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")
    For i = 0 To searchResult.Updates.Count-1
        Dim update
        Set update = searchResult.Updates.Item(i)
        If update.IsDownloaded = true Then
            LogWrite i + 1 & "> " & update.Title
            updatesToInstall.Add(update)
            If update.InstallationBehavior.RebootBehavior > 0 Then
                rebootMayBeRequired = true
            End If
        End If
    Next

    If updatesToInstall.Count = 0 Then
        LogWrite "No updates were successfully downloaded."
        WScript.Quit
    End If

    Set downloadUpdates = updatesToInstall
End Function

Function installUpdates(updateSession, updatesToInstall)
    LogWrite "Installing updates..."
    Dim installer, installationResult, i
    On Error Resume Next
    Set installer = updateSession.CreateUpdateInstaller()
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
    installer.Updates = updatesToInstall
    On Error Resume Next
    Set installationResult = installer.Install()
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
    LogWrite "Installation Result: " & installationResult.ResultCode
    LogWrite "Reboot Required: " & installationResult.RebootRequired
    LogWrite "Listing of updates installed and individual installation results:"
    For i = 0 to updatesToInstall.Count - 1
        LogWrite i + 1 & "> " & updatesToInstall.Item(i).Title & ": " & installationResult.GetUpdateResult(i).ResultCode
    Next
    Set installUpdates = installationResult
End Function

Sub deleteStartupEntry
    Const HKEY_LOCAL_MACHINE = &H80000002
    Dim strComputer
    strComputer = "."
    Dim reg, strKeyPath, strValueName, strValue
    Set reg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Run"
    strValueName = "WindowsUpdate"
    LogWrite "Chedking to see if the following registry key exits:"
    LogWrite "HKLM\" & strKeyPath
    reg.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
    If IsNull(strValue) Then
        LogWrite "The registry key does not exist from a prior run."
    Else
        LogWrite "The registry key exists from a prior run, deleting..."
        reg.DeleteValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName
        LogWrite "Registry key deleted."
    End If
End Sub

Sub addStartupEntry
    Dim objShell, fullName, strPath
    Set objShell = CreateObject("WScript.Shell")
    fullName = WScript.ScriptFullName
    strPath = Left(fullName, InStrRev(fullName, "?.wsf") - 1)

    Const HKEY_LOCAL_MACHINE = &H80000002
    Dim strComputer, reg, strKeyPath, strValueName
    strComputer = "."
    Set reg=GetObject("winmgmts:{impersonationLevel=impersonate}!//" & strComputer & "/root/default:StdRegProv")
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Run"
    strValueName = "WindowsUpdate"
    LogWrite "Writing " & strValueName & " = " & strPath
    LogWrite "to registry key"
    LogWrite "HKLM\" & strKeyPath
    reg.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strPath
End Sub

Sub reboot(computerName)
    LogWrite "Rebooting " & computerName
    Dim objWMIService, colOS, objOS
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & computerName & "\root\cimv2")
    Set colOS = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objOS in colOS
        objOS.Reboot()
    Next
End Sub

Function getEnv(varName)
    Dim strTry, objShell
    strTry    = "%" & varName & "%"
    Set objShell = CreateObject("WScript.Shell")
    getEnv = objShell.ExpandEnvironmentStrings(strTry)
    If getEnv = strTry Then
        getEnv = ""
    End If
End Function

Function getTempDir()
    getTempDir = getEnv("PACKER_TMP")
    If getTempDir = "" Then
        getTempDir = getEnv("TEMP")
    End If
End Function

</script></job>