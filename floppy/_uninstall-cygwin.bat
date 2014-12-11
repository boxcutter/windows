@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Uninstalling Cygwin. Please wait...

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

timeout 2

pushd %SystemDrive%\

echo ==^> Removing Cygwin shortcuts

rmdir /s /q "%SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\cygwin"
del /f /q %SystemDrive%\Users\Public\Desktop\Cygwin*

echo ==^> Stopping SSH daemon

cygwin\bin\cygrunsrv -E sshd
cygwin\bin\cygrunsrv -R sshd

timeout 5

taskkill /f /im SSHD.EXE /t

timeout 2

echo ==^> Closing port 22 on firewall
netsh advfirewall firewall delete rule name="SSHD"
netsh advfirewall firewall delete rule name="ssh"

echo ==^> Taking ownership of \cygwin directory.
takeown /r /d y /f cygwin
icacls cygwin /t /grant Everyone:F

echo ==^> Removing \cygwin directory
rmdir /s /q cygwin

echo ==^> Shutting down system
shutdown /s /t 10 /f /d p:4:1 /c "Packer Shutdown"

:exit
