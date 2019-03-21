@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if exist %~dp0\_packer_config.cmd (
    copy %~dp0\_packer_config.cmd "%SystemRoot%\"
)

goto main

::::::::::::
:find_tee
::::::::::::

set _TEE_CMD=

for %%i in (tee.cmd tee.exe) do set _TEE_CMD=%%~$PATH:i
if exist "%_TEE_CMD%" goto :eof

for %%i in ("%SystemRoot%" %PACKER_SEARCH_PATHS%) do if exist "%%~i\tee.exe" set _TEE_CMD=%%~i\tee.exe
if exist "%_TEE_CMD%" goto :eof

for %%i in ("%SystemRoot%" %PACKER_SEARCH_PATHS%) do if exist "%%~i\tee.cmd" set _TEE_CMD=%%~i\tee.cmd
if exist "%_TEE_CMD%" goto :eof

set _TEE_CMD=%SystemRoot%\tee.cmd
set _TEE_JS=%SystemRoot%\tee.js

:: see http://stackoverflow.com/a/10719322/1432614
echo var fso = new ActiveXObject("Scripting.FileSystemObject");>"%_TEE_JS%"
echo var out = fso.OpenTextFile(WScript.Arguments(0),2,true);>>"%_TEE_JS%"
echo var chr;>>"%_TEE_JS%"
echo while( ^^!WScript.StdIn.AtEndOfStream ) {>>"%_TEE_JS%"
echo   chr=WScript.StdIn.Read(1);>>"%_TEE_JS%"
echo   WScript.StdOut.Write(chr);>>"%_TEE_JS%"
echo   out.Write(chr);>>"%_TEE_JS%"
echo }>>"%_TEE_JS%"

echo @cscript //E:JScript //nologo "%_TEE_JS%" %%* >"%_TEE_CMD%"

set _TEE_JS=

goto :eof

::::::::::::
:main
::::::::::::

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\WindowsPowerShell\v1.0;%PATH%;%~dp0

pushd "%~dp0"

if defined PACKER_DEBUG (
  set _PACKER_CMD_OPTS=
) else (
  set _PACKER_CMD_OPTS=/q
)

set _PACKER_LOG=%TEMP%\%~n0.log.txt
set _PACKER_RUN=%TEMP%\%~n0.run.tmp

echo %date% %time%: %0 Started >>"%_PACKER_LOG%"
title %0 Started, please wait...

dir /b /on "%~d0\*.bat" "%~d0\*.cmd" | findstr /v "^_" | findstr /i /v %~nx0 >"%_PACKER_RUN%"

echo ==========>>"%_PACKER_LOG%"
echo %_PACKER_RUN%: >>"%_PACKER_LOG%"
echo ==========>>"%_PACKER_LOG%"
type "%_PACKER_RUN%" >>"%_PACKER_LOG%"
echo.>>"%_PACKER_LOG%"

echo ==========>>"%_PACKER_LOG%"
echo Environment: >>"%_PACKER_LOG%"
echo ==========>>"%_PACKER_LOG%"
set | sort >>"%_PACKER_LOG%"
echo.>>"%_PACKER_LOG%"

call :find_tee

for /f %%i in (%_PACKER_RUN%) do (
  pushd "%~dp0"
  echo %date% %time%: Executing %%~i >>"%_PACKER_LOG%"
  echo ==^> Executing %%~i
  title Executing %%~i, please wait...

  if exist "%temp%\%%~ni.err" del "%temp%\%%~ni.err"

  ("%ComSpec%" %_PACKER_CMD_OPTS% /c "%~d0\%%~nxi" 2>&1 || copy /y nul "%temp%\%%~ni.err" >nul) | "%_TEE_CMD%" "%TEMP%\%%~ni.log.txt"
  if exist "%temp%\%%~ni.err" (
    echo ==^> %%~i returned an error. See "%TEMP%\%%~ni.log.txt" for details.
    echo %date% %time%: %%~i returned an error. See "%TEMP%\%%~ni.log.txt" for details. >>"%_PACKER_LOG%"
    if defined PACKER_PAUSE_ON_ERROR (
      echo 
      title Press any key to continue . . .
      pause
    )
    if defined PACKER_SHUTDOWN_ON_ERROR (
      shutdown /s /t 0 /f /d p:4:1 /c "Packer shutdown as %%~i returned error %errorlevel%"
    )
  ) else (
    echo ==^> %%~i completed successfully.
    echo %date% %time%: %%~i completed successfully. >>"%_PACKER_LOG%"
    if defined PACKER_PAUSE (
      title Waiting for %PACKER_PAUSE% seconds, press Y to continue
      choice /C Y /N /T %PACKER_PAUSE% /D Y /M "Waiting for %PACKER_PAUSE% seconds, press Y to continue: "
    )
  )
  if exist "%temp%\%%~ni.err" del "%temp%\%%~ni.err"
  popd
)

echo %date% %time%: %0 Finished >>"%_PACKER_LOG%"
title %0 Finished
exit /b 0
