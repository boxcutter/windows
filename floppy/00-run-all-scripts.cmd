@echo off
setlocal EnableDelayedExpansion EnableExtensions

PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\WindowsPowerShell\v1.0;%PATH%;%~dp0

for %%i in (_packer_config.cmd) do set _packer_config=%%~$PATH:i

if defined _packer_config call "%_packer_config%"

set CMD_OPTS=/Q

if defined PACKER_DEBUG set CMD_OPTS=
if defined PACKER_DEBUG echo on

cd /d %~dp0

set packer_log="%TEMP%\%~n0.txt"

echo.|time|findstr "current" >>%packer_log%
echo %0: started. >>%packer_log%
title Running %0, please wait...

dir /b /on %~d0\*.bat %~d0\*.cmd | findstr /v "^_" | findstr /i /v %~nx0 >"%TEMP%\runlist.txt"

for %%i in (tee.exe) do set _tee=%%~$PATH:i

for /F %%i in (%TEMP%\runlist.txt) do (
  echo.|time|findstr "current" >>%packer_log%
  echo %0: executing %%~i >>%packer_log%

  title Executing %%~i...
  if defined _tee (
    cmd %CMD_OPTS% /c "%%~nxi" 2>&1 | "%_tee%" "%TEMP%\%%~ni.txt"
  ) else (
    cmd %CMD_OPTS% /c "%%~nxi"
  )
  echo %0 %%~i returned errorlevel %ERRORLEVEL% >>%packer_log%
  if defined PACKER_PAUSE timeout /T %PACKER_PAUSE%
)

del "%TEMP%\runlist.txt"

echo.|time|findstr "current" >>%packer_log%
echo %0: finished. >>%packer_log%
