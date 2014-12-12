@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

echo ==^> Regenerating .Net native image cache

for %%i in (Framework Framework64) do (
  if exist "%SystemRoot%\Microsoft.NET\%%~i" (
    pushd "%SystemRoot%\Microsoft.NET\%%~i"

    set ngen=
    for /r %%j in (ngen.exe) do if exist "%%~j" (
      set ngen=%%~j
    )

    echo ==^> Executing: "!ngen!" update /force /queue
    "!ngen!" update /force /queue
    echo ==^> Executing: "!ngen!" executequeueditems
    "!ngen!" executequeueditems

    popd
  )
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
