@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_PAGEFILE_MB set PACKER_PAGEFILE_MB=512

title Modifying pagefile. Please wait...

echo ==^> Checking if pagefile is automatically managed

for /f "tokens=*" %%f in (
  'wmic computersystem get AutomaticManagedPagefile /value ^| find "="') do (
  @set "%%f"
)

if not '%AutomaticManagedPagefile%'=='FALSE' (
  echo ==^> Configuring pagefile automatic management to False
  wmic computersystem set AutomaticManagedPagefile=False
  @if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: wmic computersystem where name="%COMPUTERNAME%" set AutomaticManagedPagefile=False
)

echo ==^> Checking pagefile size

for /f "tokens=*" %%f in (
  'wmic pagefileset where name^="%SystemDrive%\\pagefile.sys" get InitialSize^,MaximumSize /value ^| find "="') do (
  set "%%f"
)

if not '%InitialSize%'=='%PACKER_PAGEFILE_MB%' @set wrongsize=1
if not '%MaximumSize%'=='%PACKER_PAGEFILE_MB%' @set wrongsize=1

if defined wrongsize (
  echo ==^> Configuring pagefile size
  wmic pagefileset where name="%SystemDrive%\\pagefile.sys" set InitialSize=%PACKER_PAGEFILE_MB%,MaximumSize=%PACKER_PAGEFILE_MB%
  @if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: wmic pagefileset where name="%SystemDrive%\\pagefile.sys" set InitialSize=%PACKER_PAGEFILE_MB%,MaximumSize=%PACKER_PAGEFILE_MB%
)

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
