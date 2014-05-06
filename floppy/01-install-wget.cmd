setlocal EnableDelayedExpansion EnableExtensions

:: bitsadmin can't download http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
set url=http://users.ugent.be/~bpuype/wget/wget.exe
set filename=%windir%\wget.exe

path=%path%;%~dp0
for %%i in (_download.cmd) do set _download=%%~$PATH:i
if not defined _download goto no_download
call "%_download%" "%url%" "%filename%"

if exist "%filename%" goto :eof

:no_download

echo ==^> Downloading "%url%" to "%filename%"

set bitsadmin=

for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i

if not defined bitsadmin if exist %SystemRoot%\System32\bitsadmin.exe set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

if not defined bitsadmin goto powershell

:bitsadmin

for %%i in ("%filename%") do set jobname=%%~nxi

"%bitsadmin%" /transfer "%jobname%" "%url%" "%filename%"

if exist "%filename%" goto :eof

:powershell

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%filename%')" <NUL

goto :eof
