@if not defined packer_debug echo off

setlocal EnableExtensions EnableDelayedExpansion

set VAGRANT_KEY_URL=https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
set AUTHORIZED_KEYS=%USERPROFILE%\.ssh\authorized_keys

echo ==^> Installing vagrant public key
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

PATH=%PATH%;a:\
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if defined _download (
  call "%_download%" "%VAGRANT_KEY_URL%" "%AUTHORIZED_KEYS%"
) else (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VAGRANT_KEY_URL%', '%AUTHORIZED_KEYS%')" <NUL
)

echo ==^> Disabling vagrant account password expiration
wmic USERACCOUNT WHERE "Name='vagrant'" set PasswordExpires=FALSE
