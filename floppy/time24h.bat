@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Setting time format. Please wait...

echo ==^> Setting time format to 24 hour time
reg add "HKCU\Control Panel\International" /f /v sShortTime /t REG_SZ /d "HH:mm"
reg add "HKCU\Control Panel\International" /f /v sTimeFormat /t REG_SZ /d "HH:mm:ss" 

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
