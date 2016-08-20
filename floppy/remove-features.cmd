@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined REMOVE_FEATURES set REMOVE_FEATURES=InkAndHandwritingServices

title Removing features. Please wait...

for %%f in (%REMOVE_FEATURES%) do (
  echo ==^> Checking if the %%f feature is removed
  @set CurrentFeature=''
  for /f "tokens=2 delims=:" %%s in (
    'Dism /Online /Get-FeatureInfo /FeatureName:%%f ^| find "State : "') do (
    @set CurrentFeature="%%s"
  )
  if not !CurrentFeature!==" Disabled with Payload Removed" (
    echo ==^> Removing the %%f feature
    Dism /Online /Disable-Feature /FeatureName:%%f /Remove
    @if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: Dism /Online /Disable-Feature /FeatureName:%%f /Remove
  )
)

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
