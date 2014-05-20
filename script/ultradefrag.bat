@if not defined PACKER_DEBUG echo off

setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

set ULTRADEFRAG_VERSION=6.0.2

if exist "%SystemDrive%\Program Files (x86)" (
  set ULTRADEFRAG_ZIP=ultradefrag-portable-%ULTRADEFRAG_VERSION%.bin.amd64.zip
) else (
  set ULTRADEFRAG_ZIP=ultradefrag-portable-%ULTRADEFRAG_VERSION%.bin.i386.zip
)

set ULTRADEFRAG_URL=http://downloads.sourceforge.net/ultradefrag/%ULTRADEFRAG_ZIP%
set ULTRADEFRAG_DIR=%TEMP%\ultradefrag
set ULTRADEFRAG_ZIP_LOCAL_PATH=%ULTRADEFRAG_DIR%\%ULTRADEFRAG_ZIP%

mkdir "%ULTRADEFRAG_DIR%"

echo ==^> Downloadling %ULTRADEFRAG_URL% to %ULTRADEFRAG_ZIP_LOCAL_PATH%
PATH=%PATH%;a:\
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%ULTRADEFRAG_URL%" "%ULTRADEFRAG_ZIP_LOCAL_PATH%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ULTRADEFRAG_URL%', '%ULTRADEFRAG_ZIP_LOCAL_PATH%')" <NUL
)

echo ==^> Download complete

echo ==^> Unzipping UltraDefrag from "%ULTRADEFRAG_ZIP_LOCAL_PATH%"
"%ProgramFiles%\7-Zip\7z.exe" e -o"%ULTRADEFRAG_DIR%" "%ULTRADEFRAG_ZIP_LOCAL_PATH%"

echo ==^> Running UltraDefrag on %SystemDrive%
"%ULTRADEFRAG_DIR%\udefrag.exe" --optimize --repeat %SystemDrive%

echo ==^> Removing "%ULTRADEFRAG_DIR%"
del /F /S /Q "%ULTRADEFRAG_DIR%"

exit 0
