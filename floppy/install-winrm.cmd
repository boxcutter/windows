@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Enabling Windows Remote Management. Please wait...

echo ==^> Turning off User Account Control ^(UAC^)
:: see http://www.howtogeek.com/howto/windows-vista/enable-or-disable-uac-from-the-windows-vista-command-line/
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

title Enabling Windows Remote Management. Please wait...

echo ==^> Setting the PowerShell ExecutionPolicy to RemoteSigned - 64 bit
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"

if exist %SystemRoot%\SysWOW64\cmd.exe (
  echo ==^> Setting the PowerShell ExecutionPolicy to RemoteSigned - 32 bit
  %SystemRoot%\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
  @if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" <NUL
)

wmic os get Caption | findstr /c:"Windows 7" /c:"Windows 10" >nul
if errorlevel 1 goto skip_fixnetwork

if not exist a:\fixnetwork.ps1 echo ==^> ERROR: File not found: a:\fixnetwork.ps1

echo ==^> Setting the Network Location to private
:: see http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
powershell -File a:\fixnetwork.ps1 <NUL
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: powershell -File a:\fixnetwork.ps1

:skip_fixnetwork

echo ==^> Changing remote UAC account policy
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

:: Disable the Windows Remote Management firewall group while we quickconfig winrm.
:: This group includes the rules WINRM-HTTP-In-TCP-NoScope, WINRM-HTTP-In-TCP-PUBLIC,
:: and WINRM-HTTP-In-TCP.
echo ==^> Blocking Windows Remote Management ^(WINRM-HTTP-In-TCP^) on the firewall
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=no
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: netsh advfirewall firewall set rule group="Windows Remote Management" new enable=no

echo ==^> Configuring Windows Remote Management ^(WinRM^) service

call winrm quickconfig -q
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm quickconfig -q

call winrm quickconfig -transport:http
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm quickconfig -transport:http

call winrm set winrm/config @{MaxTimeoutms="1800000"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config @{MaxTimeoutms="1800000"}

call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="800"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config/winrs @{MaxMemoryPerShellMB="800"}

call winrm set winrm/config/service @{AllowUnencrypted="true"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config/service @{AllowUnencrypted="true"}

call winrm set winrm/config/service/auth @{Basic="true"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config/service/auth @{Basic="true"}

call winrm set winrm/config/client/auth @{Basic="true"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config/client/auth @{Basic="true"}

call winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}

sc config winrm start= disabled
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: sc config winrm start= disabled

:: wait for winrm service to finish starting
timeout 5

sc query winrm | findstr "RUNNING" >nul
if errorlevel 1 goto winrm_not_running

echo ==^> Stopping winrm service

sc stop winrm

:is_winrm_running

timeout 5

sc query winrm | findstr "STOPPED" >nul
if errorlevel 1 goto is_winrm_running

:winrm_not_running

echo ==^> Restoring Windows Remote Management ^(WINRM-HTTP-In-TCP^) on the firewall
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
