@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Disabling new network prompt. Please wait...

echo ==^> Disabling new network prompt
reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
