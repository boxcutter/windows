@if not defined PACKER_DEBUG echo off

setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

set SDELETE_URL=http://live.sysinternals.com/sdelete.exe
set SDELETE_DIR=%TEMP%\sdelete
set SDELETE_LOCAL_PATH=%SDELETE_DIR%\sdelete.exe

mkdir "%SDELETE_DIR%"

echo ==^> Downloadling %SDELETE_URL% to %SDELETE_LOCAL_PATH%
PATH=%PATH%;a:\
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%SDELETE_URL%" "%SDELETE_LOCAL_PATH%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SDELETE_URL%', '%SDELETE_LOCAL_PATH%')" <NUL
)

echo ==^> Download complete

"%SystemRoot%\System32\reg.exe" ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f

echo ==^> Running SDelete on %SystemDrive%
"%SDELETE_LOCAL_PATH%" -z %SystemDrive%

echo ==^> Removing "%SDELETE_DIR%"
del /F /S /Q "%SDELETE_DIR%"

exit 0
