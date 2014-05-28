@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if not defined PACKER_DEBUG echo off

echo ==^> Uninstalling 7zip
if exist "%SystemRoot%\7z.exe" del /f "%SystemRoot%\7z.exe"
if exist "%SystemRoot%\7z.dll" del /f "%SystemRoot%\7z.dll"

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit

echo ==^> Script exiting with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
