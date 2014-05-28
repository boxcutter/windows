@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

echo ==^> Regenerating .Net native image cache

if exist "%SystemDrive%\Program Files (x86)" (
  set DOTNET_FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework64
) else (
  set DOTNET_FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework
)

for /r "%DOTNET_FRAMEWORK_DIR%" %%i in (ngen.exe) do if exist "%%~i" (
  echo ==> Executing: "%%~i" update /force
  echo.|time|findstr "current"
  "%%~i" update /force
  echo.|time|findstr "current"
)

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
