@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

REM This script is not included on the floppy by default.
REM If you're using update.bat, include this file if you
REM want to run scripts following all updates/reboots.

title Running post update scripts. Please wait...

@for %%i in (%~dp0\zz*.cmd) do (
  echo ==^> Running "%%~i"  
  @call "%%~i"
)

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
