@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined INSTALL_FEATURES set INSTALL_FEATURES=TelnetClient

title Installing features. Please wait...

for %%f in (%INSTALL_FEATURES%) do (
  echo ==^> Checking if the %%f feature is installed
  @set CurrentFeature=''
  for /f "tokens=2 delims=:" %%s in (
    'Dism /Online /Get-FeatureInfo /FeatureName:%%f ^| find "State : "') do (
    @set CurrentFeature="%%s"
  )
  if not !CurrentFeature!==" Enabled" (
    echo ==^> Installing the %%f feature
    Dism /Online /Enable-Feature /FeatureName:%%f /All
    @if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: Dism /Online /Enable-Feature /FeatureName:%%f /All
  )
)

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
