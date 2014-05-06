setlocal EnableDelayedExpansion
setlocal EnableExtensions
title Enabling Windows Remote Management. Please wait...

echo ==^> Turning off User Account Control (UAC)
:: see http://www.howtogeek.com/howto/windows-vista/enable-or-disable-uac-from-the-windows-vista-command-line/
cmd.exe /c reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

if exist C:\Windows\SysWOW64\cmd.exe C:\Windows\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

systeminfo | findstr /B /C:"OS Name" | findstr /C:"Windows 7"
if errorlevel 1 goto no_fixnetwork

:: see http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
powershell -File a:\fixnetwork.ps1 <NUL
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

:no_fixnetwork

cmd.exe /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm quickconfig -q
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm quickconfig -transport:http
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config @{MaxTimeoutms="1800000"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config/service @{AllowUnencrypted="true"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config/service/auth @{Basic="true"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config/client/auth @{Basic="true"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

:: see http://social.technet.microsoft.com/Forums/windowsserver/en-US/a1e65f0f-2550-49ae-aee2-56a9bdcfb8fb/windows-7-remote-administration-firewall-group?forum=winserverManagement
cmd.exe /c netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c netsh firewall add portopening TCP 5985 "Port 5985"
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c net stop winrm
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c sc config winrm start= auto
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%

cmd.exe /c net start winrm
@if errorlevel 1 echo ERROR: The previous command returned error %ERRORLEVEL%
