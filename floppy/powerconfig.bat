@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Setting power configuration. Please wait...

echo ==^> Setting power configuration to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

echo ==^> Turning off Hibernation
powercfg -h off

echo ==^> Turning off monitor timeout
powercfg -Change -monitor-timeout-ac 0
powercfg -Change -monitor-timeout-dc 0

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
