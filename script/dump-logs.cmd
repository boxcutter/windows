@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

for %%i in ("%TEMP%\*.log.txt") do (
  echo =========================================================================
  echo ==^> Dumping %%~i:
  echo =========================================================================
  echo %%i | findstr /i cygwin >nul
  if not errorlevel 1 (
    findstr /r /v /c:"^Installing file" /c:"^Adding required dependency" /c:"^io_stream::mklink" /c:"^Downloaded " /c:"^get_url_to_file " /c:"^Checking MD5 for file:" /c:"^MD5 verified OK: file" /c:"^Extracting from file:" "%%~i"
  ) else (
    type "%%~i"
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
