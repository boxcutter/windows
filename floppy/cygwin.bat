@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Cygwin. Please wait...

if not defined CYGWIN_ARCH (
  :: Force CYGWIN_ARCH to 32-bit - 64-bit seems to crash a lot
  set CYGWIN_ARCH=x86

  :: Force CYGWIN_ARCH to 64-bit - 32-bit seems to crash a lot on Windows 2008 and 2012
  :: 64-bit OS also needs a 64-bit shell for calls to DISM to work correctly
  wmic os get Caption | findstr "2008 2012 2016" >nul
  if not errorlevel 1 set CYGWIN_ARCH=x86_64
)

if not defined CYGWIN_HOME       set CYGWIN_HOME=%SystemDrive%\cygwin
if not defined CYGWIN_MIRROR_URL set CYGWIN_MIRROR_URL=http://mirrors.kernel.org/sourceware/cygwin
if not defined CYGWIN_PACKAGES   set CYGWIN_PACKAGES=openssh
if not defined CYGWIN_TRIES      set CYGWIN_TRIES=3
if not defined CYGWIN_URL        set CYGWIN_URL=http://cygwin.com/setup-x86.exe
if not defined SSHD_PASSWORD     set SSHD_PASSWORD=D@rj33l1ng

for %%i in ("%CYGWIN_URL%") do set CYGWIN_EXE=%%~nxi
set CYGWIN_DIR=%TEMP%\cygwin
set CYGWIN_PATH=%CYGWIN_DIR%\%CYGWIN_EXE%

title Installing Cygwin and %CYGWIN_PACKAGES% to %CYGWIN_HOME%. Please wait...

echo ==^> Creating "%CYGWIN_DIR%"
mkdir "%CYGWIN_DIR%"
pushd "%CYGWIN_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CYGWIN_URL%" "%CYGWIN_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%CYGWIN_URL%" "%CYGWIN_PATH%
)
if errorlevel 1 goto exit1

echo ==^> Blocking SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="%CYGWIN_HOME%\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=block protocol=TCP localport=22

set CYGWIN_TRY=0

:retry

set /a CYGWIN_TRY=%CYGWIN_TRY%+1

echo ==^> Installing Cygwin (attempt %CYGWIN_TRY% of %CYGWIN_TRIES%)

"%CYGWIN_PATH%" -a %CYGWIN_ARCH% -q -R %CYGWIN_HOME% -P %CYGWIN_PACKAGES% -s %CYGWIN_MIRROR_URL%

if not errorlevel 1 goto installed_ok

echo ==^> The Cygwin installation failed and returned error %ERRORLEVEL%.

if /i %CYGWIN_TRY% geq %CYGWIN_TRIES% goto exit1

choice /C Y /N /T %PACKER_PAUSE% /D Y /M "Waiting for %PACKER_PAUSE% seconds, press Y to continue: "

goto retry

:installed_ok

if not exist a:\cygwin.sh echo ==^> ERROR: File not found: a:\cygwin.sh & goto exit1

echo ==^> Running a:\cygwin.sh
set CYGWIN=ntsecbinmode mintty nodosfilewarning
pushd "%CYGWIN_HOME%\bin"
PATH=%PATH%;%CYGWIN_HOME%\bin
bash /cygdrive/a/cygwin.sh "%SSHD_PASSWORD%"

if errorlevel 1 goto exit1

:: cygwin has its own timeout command
popd

echo ==^> Waiting for the sshd service to finish starting
timeout 5

sc query sshd | findstr "RUNNING" >nul
if errorlevel 1 goto sshd_not_running

echo ==^> Stopping the sshd service

sc stop sshd

:is_sshd_running

timeout 1

sc query sshd | findstr "STOPPED" >nul
if errorlevel 1 goto is_sshd_running

:sshd_not_running
ver>nul

echo ==^> Unblocking SSH port 22 on the firewall
netsh advfirewall firewall delete rule name="SSHD"
netsh advfirewall firewall delete rule name="ssh"

echo ==^> Opening SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="%CYGWIN_HOME%\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

:: This fix simply masks the issue, we need to fix the underlying cause
:: echo ==^> Overriding sshd_server username in environment
:: reg add "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "@for %%i in (%%USERPROFILE%%) do @set USERNAME=%%~ni" /f

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

