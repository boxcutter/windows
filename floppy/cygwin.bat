setlocal EnableDelayedExpansion EnableExtensions

:: Force CYGWIN_ARCH to 32-bit - 64-bit seems to crash a lot
set CYGWIN_ARCH=x86

:: Force CYGWIN_ARCH to 64-bit - 32-bit seems to crash a lot on Windows 2012
systeminfo | findstr /B /C:"OS Name" | findstr "2012"
if not errorlevel 1 set CYGWIN_ARCH=x86_64

:: Force CYGWIN_ARCH to 64-bit - 32-bit seems to crash a lot on Windows 2008
systeminfo | findstr /B /C:"OS Name" | findstr "2008"
if not errorlevel 1 set CYGWIN_ARCH=x86_64

set CYGWIN_SETUP_URL=http://cygwin.com/setup-%CYGWIN_ARCH%.exe
set CYGWIN_SETUP_LOCAL_PATH=%TEMP%\setup-%CYGWIN_ARCH%.exe
set CYGWIN_HOME=%SystemDrive%\cygwin
set CYGWIN_PACKAGES=openssh
set CYGWIN_MIRROR_URL=http://mirrors.kernel.org/sourceware/cygwin

PATH=%PATH%;%CYGWIN_HOME%\bin

title Installing Cygwin and %CYGWIN_PACKAGES% to %CYGWIN_HOME%. Please wait...

cd /D "%TEMP%"

echo ==^> Downloading "%CYGWIN_SETUP_URL%" to "%CYGWIN_SETUP_LOCAL_PATH%"

PATH=%PATH%;~dp0
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%CYGWIN_SETUP_URL%" "%CYGWIN_SETUP_LOCAL_PATH%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%CYGWIN_SETUP_URL%', '%CYGWIN_SETUP_LOCAL_PATH%')" <NUL
)

echo ==^> Installing Cygwin
"%CYGWIN_SETUP_LOCAL_PATH%" -a %CYGWIN_ARCH% -q -R %CYGWIN_HOME% -P %CYGWIN_PACKAGES% -s %CYGWIN_MIRROR_URL%

echo ==^> Stopping the ssh service
cygrunsrv -E sshd

echo ==^> Opening firewall port 22 for the sshd service
netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="%CYGWIN_HOME%\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

echo ==^> Shelling out to configure Unix bits
set CYGWIN=ntsecbinmode mintty nodosfilewarning
bash a:/cygwin.sh "abc&&123!!"

echo ==^> Deleting the Cygwin installer and downloaded packages
del "%CYGWIN_SETUP_LOCAL_PATH%"
for /D %%i in (%TEMP%\http*.*) do del /s /q "%%~i"

echo ==^> Fixing corrupt recycle bin - see http://www.winhelponline.com/blog/fix-corrupted-recycle-bin-windows-7-vista/
rd /s /q %SystemDrive%\$Recycle.bin
