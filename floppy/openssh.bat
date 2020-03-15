@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Openssh. Please wait...

if not defined OPENSSH_URL set OPENSSH_URL=http://www.mls-software.com/files/setupssh-7.2p2-1-v1.exe
if not defined SSHD_PASSWORD  set SSHD_PASSWORD=D@rj33l1ng

for %%i in (%OPENSSH_URL%) do set OPENSSH_EXE=%%~nxi
set OPENSSH_DIR=%TEMP%\openssh
set OPENSSH_PATH=%OPENSSH_DIR%\%OPENSSH_EXE%

echo ==^> Creating "%OPENSSH_DIR%"
mkdir "%OPENSSH_DIR%"
pushd "%OPENSSH_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%OPENSSH_URL%" "%OPENSSH_PATH%"
)
if not exist "%OPENSSH_PATH%" goto exit1

echo ==^> Blocking SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="%ProgramFiles%\OpenSSH\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh"  dir=in action=block protocol=TCP localport=22

echo ==^> Installing OpenSSH
"%OPENSSH_PATH%" /S /port=22 /privsep=1 /password=%SSHD_PASSWORD%

:: wait for opensshd service to finish starting
timeout 5

sc query opensshd | findstr "RUNNING" >nul
if errorlevel 1 goto sshd_not_running

echo ==^> Stopping the sshd service
sc stop opensshd

:is_sshd_running

timeout 1

sc query opensshd | findstr "STOPPED" >nul
if errorlevel 1 goto is_sshd_running

:sshd_not_running
ver>nul

echo ==^> Unblocking SSH port 22 on the firewall
netsh advfirewall firewall delete rule name="SSHD"
netsh advfirewall firewall delete rule name="ssh"

echo ==^> Setting temp location
rmdir /q /s "%ProgramFiles%\OpenSSH\tmp"
mklink /d "%ProgramFiles%\OpenSSH\tmp" "%SystemRoot%\Temp"

icacls "%SystemRoot%\Temp" /grant %USERNAME%:(OI)(CI)F

echo ==^> Adding missing environment variables to %USERPROFILE%\.ssh\environment

if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

set SSHENV=%USERPROFILE%\.ssh\environment

echo APPDATA=%SystemDrive%\Users\%USERNAME%\AppData\Roaming>>"%SSHENV%"
echo COMMONPROGRAMFILES=%SystemDrive%\Program Files\Common Files>>"%SSHENV%"
echo LOCALAPPDATA=%SystemDrive%\Users\%USERNAME%\AppData\Local>>"%SSHENV%"
echo PROGRAMDATA=%SystemDrive%\ProgramData>>"%SSHENV%"
echo PROGRAMFILES=%SystemDrive%\Program Files>>"%SSHENV%"
echo PSMODULEPATH=%SystemDrive%\Windows\system32\WindowsPowerShell\v1.0\Modules\>>"%SSHENV%"
echo PUBLIC=%SystemDrive%\Users\Public>>"%SSHENV%"
echo SESSIONNAME=Console>>"%SSHENV%"
echo TEMP=%SystemDrive%\Users\%USERNAME%\AppData\Local\Temp>>"%SSHENV%"
echo TMP=%SystemDrive%\Users\%USERNAME%\AppData\Local\Temp>>"%SSHENV%"
:: This fix simply masks the issue, we need to fix the underlying cause
:: to override sshd_server:
:: echo USERNAME=%USERNAME%>>"%SSHENV%"

if exist "%SystemDrive%\Program Files (x86)" (
  echo COMMONPROGRAMFILES^(X86^)=%SystemDrive%\Program Files ^(x86^)\Common Files>>"%SSHENV%"
  echo COMMONPROGRAMW6432=%SystemDrive%\Program Files\Common Files>>"%SSHENV%"
  echo PROGRAMFILES^(X86^)=%SystemDrive%\Program Files ^(x86^)>>"%SSHENV%"
  echo PROGRAMW6432=%SystemDrive%\Program Files>>"%SSHENV%"
)

echo ==^> Fixing opensshd's configuration to be less strict
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace 'StrictModes yes', 'StrictModes no' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace '#UseDNS yes', 'UseDNS no' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\sshd_config') | Foreach-Object { $_ -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt' } | Set-Content '%ProgramFiles%\OpenSSH\etc\sshd_config'"

echo ==^> Opening SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="%ProgramFiles%\OpenSSH\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

echo ==^> Ensuring user %USERNAME% can login
icacls "%USERPROFILE%" /grant %USERNAME%:(OI)(CI)F
icacls "%ProgramFiles%\OpenSSH\bin" /grant %USERNAME%:(OI)RX
icacls "%ProgramFiles%\OpenSSH\usr\sbin" /grant %USERNAME%:(OI)RX

echo ==^> Setting user's home directories to their windows profile directory
powershell -Command "(Get-Content '%ProgramFiles%\OpenSSH\etc\passwd') | Foreach-Object { $_ -replace '/home/(\w+)', '/cygdrive/c/Users/$1' } | Set-Content '%ProgramFiles%\OpenSSH\etc\passwd'"

:: This fix simply masks the issue, we need to fix the underlying cause
:: echo ==^> Overriding sshd_server username in environment
:: reg add "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "@for %%i in (%%USERPROFILE%%) do @set USERNAME=%%~ni" /f

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
