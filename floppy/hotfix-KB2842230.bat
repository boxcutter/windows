:: Windows 8 / Windows 2012 require KB2842230 hotfix to properly honor a
:: customized MaxMemoryPerShellMB value.
:: https://support.microsoft.com/en-us/kb/2842230?wa=wsignin1.0

@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

:: get windows version
for /f "tokens=2 delims=[]" %%G in ('ver') do (set _version=%%G)
for /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') do (set _major=%%G& set _minor=%%H& set _build=%%I)

:: 6.2 or 6.3
if %_major% neq 6 goto :exit
if %_minor% lss 2 goto :exit
if %_minor% gtr 3 goto :exit

title Installing Hotfix KB2842230. Please wait...

if not defined HOTFIX_2842230_URL set HOTFIX_2842230_URL=https://chocolateypackages.s3.amazonaws.com/KB2842230.1.0.2.nupkg

for %%i in (%HOTFIX_2842230_URL%) do set HOTFIX_2842230_EXE=%%~nxi
set HOTFIX_2842230_DIR=%TEMP%\KB2842230
set HOTFIX_2842230_PATH=%HOTFIX_2842230_DIR%\%HOTFIX_2842230_EXE%.zip

echo ==^> Creating "%HOTFIX_2842230_DIR%"
mkdir "%HOTFIX_2842230_DIR%"
pushd "%HOTFIX_2842230_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%HOTFIX_2842230_URL%" "%HOTFIX_2842230_PATH%"
) else (
  call %SystemRoot%\_download_ps1.cmd "%HOTFIX_2842230_URL%" "%HOTFIX_2842230_PATH%"
)

if errorlevel 1 goto exit1

echo ==^> Extracting Hotfix KB2842230
@for %%i in (%~dp0\unzip.vbs) do @cscript //nologo "%%~i" "%HOTFIX_2842230_PATH%" "%HOTFIX_2842230_DIR%"

echo ==^> Installing Hotfix KB2842230
@echo on
start /wait wusa "%HOTFIX_2842230_DIR%\Windows8-RT-KB2842230-x64.msu" /quiet /norestart

:exit0

ver>nul

:exit1

verify other 2>nul

:exit
