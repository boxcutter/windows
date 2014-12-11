@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Disabling automatic machine account password changes. Please wait...

echo ==^> Disabling automatic machine account password changes
:: http://support.microsoft.com/kb/154501
reg add "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v DisablePasswordChange /t REG_DWORD /d 2 /f

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
