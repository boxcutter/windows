@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Uninstalling Bitvise SSH Server.  Please wait...

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

echo ==^> Stopping the Bitvise SSH Server Service
sc stop BvSshServer
timeout 2

echo ==^> Uninstalling Bitvise SSH Server
copy "%ProgramFiles%\Bitvise SSH Server\uninst.exe' %TEMP%
"%TEMP%\uninst.exe" "Bitvise SSH Server" -unat
timeout 2

echo ==^> Deleting Bitvise SSH Server registry key
reg delete "HKLM\Software\Wow6432Node\Bitvise" /f
reg delete "HKLM\Software\Bitvise" /f

echo ==^> Removing Bitvise SSH Server directory
rmdir /s /q "%ProgramFiles%\Bitvise SSH Server"
del /f /q %TEMP%\uninst.exe
