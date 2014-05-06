@if not defined PACKER_DEBUG echo off

setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

echo ==^> Cleaning "%TEMP%"
del /F /S /Q "%TEMP%\*.*"

echo ==^> Cleaning "%SystemRoot%\TEMP"
for %%i in ("%SystemRoot%\TEMP\*.*") do if /i not "%%~nx" equ "%~nx0" del /F /S /Q "%%~i"

exit 0
