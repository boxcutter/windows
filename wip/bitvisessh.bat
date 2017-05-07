@setlocal EnableDelayedExpansion EnableExtensions
SET PACKER_DEBUG=true
@for %%i in (~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Bitvise SSH Server.  Please wait...

for %%i in (%BITVISE_URL%) do set BITVISE_EXE=%%~nxi
set BITVISE_DIR=%TEMP%\bitvise
set BITVISE_PATH=%BITVISE_DIR%\%BITVISE_EXE%

echo ==^> Creating "%BITVISE_DIR%"
mkdir "%BITVISE_DIR%"
pushd "%BITVISE_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%BITVISE_URL%" "%BITVISE_PATH%"
) else (
  echo ==^> Downloading "%BITVISE_URL%" to "%BITVISE_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%BITVISE_URL%', '%BITVISE_PATH%')" <NUL
)
if not exist "%BITVISE_PATH%" goto exit1

echo ==^> Blocking SSH port 22 on the firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="%ProgramFiles%\Bitvise SSH Server\BvSshServer.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=block protocol=TCP localport=22

echo ==^> Installing Bitvise SSH Server
"%BITVISE_PATH%" -defaultSite -acceptEULA
echo ==^> Configuring Bitvise SSH Server
"%ProgramFiles%\Bitvise SSH Server\BssCfg.exe" setting importtext bitvisessh.cfg

sc query BvSshServer | findstr "RUNNING" >nul
if errorlevel 1 goto sshd_not_running

echo ==^> Stopping the Bitvise SSH Server Service
sc stop BvSshServer

:is_sshd_running

timeout 1

sc query BvSshServer | findstr "STOPPED" >nul
if errorlevel 1 goto is_sshd_running

:sshd_not_running
ver>nul

echo ==^> Unblocking SSH port 22 on the firewall
netsh advfirewall firewall delete rule name="SSHD"
netsh advfirewall firewall delete rule name="ssh"

:exit0
ver>nul
goto :exit

:exit1
verify other 2>nul

:exit
	if %ERRORLEVEL% neq 0 (
		call :log %0 ERROR: %0 exiting with code %ERRORLEVEL%
		if %PACKER_IGNORE_ERRORS% neq 0 (
			call :log Overiding exit code as PACKER_IGNORE_ERRORS is set
			goto :exit0
		)
	) else (
		call :log %0 exiting with code %ERRORLEVEL%
	)
	exit /b %ERRORLEVEL%

:exit0
	ver>nul
	goto :exit

:exit1
	verify other 2>nul
	goto :exit

:log
	echo %* >&2
	echo %TIME% %* >>"%PACKER_LOG%"
	goto :eof

:run
	call :log Executing: %*
	ver>nul
	%*
	if %ERRORLEVEL% neq 0 (
		call :log ERROR: %ERRORLEVEL% returned by: %*
	)
	goto :eof

:sleep
	@set /a "_sleep=%1+1" >nul
	@ping -n %_sleep% 127.0.0.1 >nul 2>nul
	@goto :eof

:wget
	where _download.cmd >nul 2>nul
	if %ERRORLEVEL% neq 0 (
		if exist "a:\01-install-wget.cmd" (
			call "a:\01-install-wget.cmd"
		)
	)
	call :run call _download.cmd %*
	goto :eof

:unzip
	where _unzip.cmd >nul 2>nul
	if %ERRORLEVEL% neq 0 (
		if exist "a:\01-install-unzip.cmd" (
			call "a:\01-install-unzip.cmd"
		)
	)
	call :run call _unzip.cmd %*
	goto :eof
