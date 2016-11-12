@setlocal EnableDelayedExpansion EnableExtensions
SET PACKER_DEBUG=true
@for %%i in (~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Bitvise SSH Server.  Please wait...

if not defined BITVISE_URL set BITVISE_URL=http://dl.bitvise.com/BvSshServer-Inst.exe

for %%i in (%BITVISE_URL%) do set BITVISE_EXE=%%~nxi
set BITVISE_DIR=%TEMP%\bitvise
set BITVISE_PATH=%BITVISE_DIR%\%BITVISE_EXE%

echo ==^> Creating "%BITVISE_DIR%"
mkdir "%BITVISE_DIR%"
pushd "%BITVISE_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%BITVISE_URL%" "%BITVISE_PATH%"
) else (
  echo ==^> Downloading "%BITVISE_URL%" to "%BITVISE_PATH%"
  if defined http_proxy (
    powershell -Command "$wc = (New-Object System.Net.WebClient); $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')); $wc.DownloadFile('%BITVISE_URL%', '%BITVISE_PATH%')" >nul
  ) else (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%BITVISE_URL%', '%BITVISE_PATH%')" >nul
  )
)

if not exist "%BITVISE_PATH%" goto exit1

echo ==^> Blocking SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="%ProgramFiles%\Bitvise SSH Server\BvSshServer.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=block protocol=TCP localport=22

echo ==^> Installing Bitvise SSH Server
"%BITVISE_PATH%" -defaultSite -acceptEULA
echo ==^> Configuring Bitvise SSH Server
"%ProgramFiles%\Bitvise SSH Server\BssCfg.exe" setting importtext bitvisessh.cfg

sc query BvSshServer | findstr "RUNNING" >nul
if errorlevel 1 goto sshd_not_running

echo ==^> Stopping the Bitvise SSH Server Service
sc stop BvSshServer

:is_sshd_running

timeout 1

sc query BvSshServer | findstr "STOPPED" >nul
if errorlevel 1 goto is_sshd_running

:sshd_not_running
ver>nul

echo ==^> Unblocking SSH port 22 on the firewall
netsh advfirewall firewall delete rule name="SSHD"
netsh advfirewall firewall delete rule name="ssh"

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit

REM # Configure Bitvise SSH server
REM start-process -FilePath 'C:\Program Files\Bitvise SSH Server\BssCfg.exe' -ArgumentList 'settings importtext A:\bitvisessh.cfg' -wait -verb RunAs
REM
REM # Start Bitvise SSH server
REM Set-Service -Name BvSshServer -StartupType Automatic -Status Running 
REM
REM # Disable firewall
REM netsh advfirewall set allprofiles state off
