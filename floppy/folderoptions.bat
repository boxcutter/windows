<!-- :
@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Setting folder options. Please wait...

echo ==^> Setting folder options
echo ==^> Show file extensions
:: Default is 1 - hide file extensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v HideFileExt /t REG_DWORD /d 0
echo ==^> Show hidden files and folders
:: Default is 2 - do not show hidden files and folders
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v Hidden /t REG_DWORD /d 1
echo ==^> Display Full path
:: Default FullPath 0 and FullPathAddress 0
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v FullPath /t REG_DWORD /d 1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v FullPathAddress /t REG_DWORD /d 1

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
