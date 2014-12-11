@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

echo ==^> Regenerating .Net native image cache

if defined ProgramFiles(x86) (
  set DOTNET_FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework64
) else (
  set DOTNET_FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework
)

if not exist "%DOTNET_FRAMEWORK_DIR%" echo ==^> ERROR: Directory not found "%DOTNET_FRAMEWORK_DIR%" & goto exit1

for /r "%DOTNET_FRAMEWORK_DIR%" %%i in (ngen.exe) do if exist "%%~i" (
  echo ==> Executing: "%%~i" update /force
  echo.|time|findstr "current"
  "%%~i" update /force
  echo.|time|findstr "current"
)

:exit0

@ping 127.0.0.1
@ver>nul

@goto :exit

:exit1

@ping 127.0.0.1
@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%
