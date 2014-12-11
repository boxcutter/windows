@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SHUTDOWN_SECONDS set PACKER_SHUTDOWN_SECONDS=0

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp





echo ==^> Uninstalling OpenSSH

set _PACKER_UNINSTALL_SSH_CMD=%TEMP%\packer_uninstall_ssh.cmd

echo ==^> Creating %_PACKER_UNINSTALL_SSH_CMD%

echo >"%_PACKER_UNINSTALL_SSH_CMD%" echo on
::@todo(rasa) remove debugging
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" netsh advfirewall firewall show rule name=all
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" set _PACKER_SHUTDOWN_TMP=%TEMP%\packer_uninstall_ssh.tmp
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" sc query ^| findstr "SERVICE_NAME" ^| findstr /v "eventlog taskscheduler winrm" ^>"%%_PACKER_SHUTDOWN_TMP%%"
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" for /f "delims=: tokens=2" %%%%i IN (%%_PACKER_SHUTDOWN_TMP%%) do echo net stop /y %%%%i
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" net stop opensshd
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" sc delete opensshd


echo >>"%_PACKER_UNINSTALL_SSH_CMD%" takeown /r /d y /f "%SystemDrive%\Users\sshd_server"
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" icacls "%SystemDrive%\Users\sshd_server" /t /grant Everyone:F
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" takeown /r /d y /f "%ProgramFiles%\OpenSSH"
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" icacls "%ProgramFiles%\OpenSSH" /t /grant Everyone:F

echo >>"%_PACKER_UNINSTALL_SSH_CMD%" "%ProgramFiles%\OpenSSH\uninstall.exe" /S

::@todo(rasa) remove debugging
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" netsh advfirewall firewall show rule name=all

echo >>"%_PACKER_UNINSTALL_SSH_CMD%" rmdir /s /q "%SystemDrive%\Users\sshd_server"
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" rmdir /s /q "%ProgramFiles%\OpenSSH"

echo >>"%_PACKER_UNINSTALL_SSH_CMD%" taskkill /f /im SSHD.EXE /t

echo >>"%_PACKER_UNINSTALL_SSH_CMD%" rmdir /s /q "%SystemDrive%\Users\sshd_server"
echo >>"%_PACKER_UNINSTALL_SSH_CMD%" rmdir /s /q "%ProgramFiles%\OpenSSH"

echo >>"%_PACKER_UNINSTALL_SSH_CMD%" "%SystemRoot%\system32\shutdown.exe" /s /t %PACKER_SHUTDOWN_SECONDS% /f /d p:4:1 /c Packer_Shutdown

::@todo(rasa) remove debugging
echo ==^> %_PACKER_UNINSTALL_SSH_CMD%
type "%_PACKER_UNINSTALL_SSH_CMD%"
echo ==^> /%_PACKER_UNINSTALL_SSH_CMD%

echo ==^> Creating task packer_uninstall_ssh to run %_PACKER_UNINSTALL_SSH_CMD%
schtasks /create /sc once /tn packer_uninstall_ssh /tr "%_PACKER_UNINSTALL_SSH_CMD% >%_PACKER_UNINSTALL_SSH_CMD%.log 2>&1" /st 00:00 /sd 12/31/2099 /f /rl HIGHEST /RU SYSTEM
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: schtasks /create /sc once /tn packer_uninstall_ssh /tr "%_PACKER_UNINSTALL_SSH_CMD% >%_PACKER_UNINSTALL_SSH_CMD%.log 2>&1" /st 00:00 /sd 12/31/2099 /f /rl HIGHEST /RU SYSTEM

echo ==^> Running task packer_uninstall_ssh
schtasks /run /tn packer_uninstall_ssh
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: schtasks /run /tn packer_uninstall_ssh

schtasks /query /tn packer_uninstall_ssh
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: schtasks /query /tn packer_uninstall_ssh

:: echo ==^> Waiting 120 seconds for system shutdown
:: for /l %%i in (1,1,120) do (
::   echo !time!
::   schtasks /query /tn packer_uninstall_ssh
::   ::choice /C Y /D Y /N /T 1 >nul
::   ping -w 1000 -n 1 10.112.35.81 >nul 2>nul
:: )

:exit0

@ver>nul

@goto :exit

:exit1

@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%
