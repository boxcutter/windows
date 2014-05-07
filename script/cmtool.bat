@if not defined PACKER_DEBUG echo off

setlocal EnableExtensions EnableDelayedExpansion

:: If TEMP is not defined in this shell instance, define it ourselves
if not defined TEMP set TEMP=%USERPROFILE%\AppData\Local\Temp

if "%CM%" == "chef" goto chef
if "%CM%" == "nocm" goto nocm

echo ==^> ERROR: Unknown cm: "%CM%"

goto :eof

:chef

set REMOTE_SOURCE_MSI_URL=https://www.getchef.com/chef/install.msi
set LOCAL_DESTINATION_MSI_PATH=%TEMP%\chef-client-latest.msi
set FALLBACK_QUERY_STRING=?DownloadContext=PowerShell

:: Always latest, for now
echo ==^> Downloading Chef client %CM_VERSION%
PATH=%PATH%;a:\
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%REMOTE_SOURCE_MSI_URL%" "%LOCAL_DESTINATION_MSI_PATH%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%REMOTE_SOURCE_MSI_URL%%FALLBACK_QUERY_STRING%', '%LOCAL_DESTINATION_MSI_PATH%')" <NUL
)

echo ==^> Installing Chef client %CM_VERSION%
msiexec /qb /i "%LOCAL_DESTINATION_MSI_PATH%"

echo ==^> Cleaning up Chef install
del /F /Q "%LOCAL_DESTINATION_MSI_PATH%"

goto :eof

:nocm

echo ==^> Building box without a configuration management tool.

goto :eof
