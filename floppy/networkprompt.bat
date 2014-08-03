setlocal EnableDelayedExpansion EnableExtensions
title Disabling new network prompt. Please wait...

echo ==^> Disabling new network prompt
reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
