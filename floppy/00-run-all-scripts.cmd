@echo off
setlocal EnableDelayedExpansion EnableExtensions

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\WindowsPowerShell\v1.0;%PATH%;%~dp0

pushd "%~dp0"

for %%i in (_packer_config*.cmd) do call "%%~i"

if defined PACKER_DEBUG (
  set _PACKER_CMD_OPTS=
  echo on
) else (
  set _PACKER_CMD_OPTS=/q
)

set _PACKER_LOG="%TEMP%\%~n0.log.txt"

echo %date% %time%: %0 Started >>%_PACKER_LOG%
title Running %0, please wait...

dir /b /on "%~d0\*.bat" "%~d0\*.cmd" | findstr /v "^_" | findstr /i /v %~nx0 >"%TEMP%\%~n0.run.tmp"

for %%i in (tee.exe) do set _PACKER_TEE=%%~$PATH:i

echo 2>&1 >>%_PACKER_LOG%
set | sort >>%_PACKER_LOG%

echo "%TEMP%\%~n0.run.tmp": >>%_PACKER_LOG%
type "%TEMP%\%~n0.run.tmp" >>%_PACKER_LOG%

for /f %%i in (%TEMP%\%~n0.run.tmp) do (
  pushd "%~dp0"
  echo %date% %time%: Executing %%~i >>%_PACKER_LOG%

  title Executing %%~i...
  if defined _PACKER_TEE (
    "%ComSpec%" %_PACKER_CMD_OPTS% /c "%%~nxi" 2>&1 | "%_PACKER_TEE%" "%TEMP%\%%~ni.log.txt"
  ) else (
    "%ComSpec%" %_PACKER_CMD_OPTS% /c "%%~nxi"
  )
  echo ==^> Error level %ERRORLEVEL% was returned by %%~i
  echo %date% %time%: Error level %ERRORLEVEL% returned by %%~i >>%_PACKER_LOG%
  if errorlevel 1 (
    if defined PACKER_PAUSE_ON_ERROR (
      pause
    )
    if defined PACKER_SHUTDOWN_ON_ERROR (
      shutdown /s /t 0 /f /d p:4:1 /c "Packer Fatal Shutdown"
    )
  ) else (
    if defined PACKER_PAUSE choice /C Y /N /T %PACKER_PAUSE% /D Y /M "Waiting for %PACKER_PAUSE% seconds, press Y to continue: "
  )
  popd
)

echo %date% %time%: %0 Finished >>%_PACKER_LOG%
