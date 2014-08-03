setlocal EnableDelayedExpansion EnableExtensions
title Setting power configuration. Please wait...

echo ==^> Setting power configuration to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

echo ==^> Turning off monitor timeout
powercfg -Change -monitor-timeout-ac 0
powercfg -Change -monitor-timeout-dc 0

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
