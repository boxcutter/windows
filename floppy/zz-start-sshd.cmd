setlocal EnableDelayedExpansion EnableExtensions

if not defined PACKER_SERVICES set PACKER_SERVICES=opensshd sshd winrm

title Starting services: %PACKER_SERVICES%. Please wait...

:: Intentionally named with zz so it runs last by 00-run-all-scripts.cmd so
:: that the Packer winrm/ssh connections is not inadvertently dropped during the
:: Sysprep run

for %%i in (%PACKER_SERVICES%) do (
  echo ==^> Checking if the %%i service is installed
  sc query %%i >nul 2>nul && (
    echo ==^> Starting the %%i service
    sc start %%i
  )
)

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
