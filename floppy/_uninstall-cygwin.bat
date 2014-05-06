ping -n 2 127.0.0.1 >nul
cd /D %SystemDrive%\

rmdir /s /q "%SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\cygwin"
del /F /Q %SystemDrive%\Users\Public\Desktop\Cygwin*

cygwin\bin\cygrunsrv -E sshd
cygwin\bin\cygrunsrv -R sshd

ping -n 5 127.0.0.1 >nul

taskkill /F /IM sshd.exe /T

ping -n 2 127.0.0.1 >nul

rem close firewall on port 22
cmd /c if exist %Systemroot%\system32\netsh.exe netsh advfirewall firewall delete rule name="SSHD"
cmd /c if exist %Systemroot%\system32\netsh.exe netsh advfirewall firewall delete rule name="ssh"

takeown /r /d y /f cygwin
icacls cygwin /t /grant Everyone:F
rmdir /s /q cygwin

shutdown /s /t 10 /f /d p:4:1 /c "Packer Shutdown"
