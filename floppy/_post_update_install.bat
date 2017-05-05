@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

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
