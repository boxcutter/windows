:: zz-start-sshd.cmd
:: Intentionally named with zz so it runs last by 00-run-all-scripts.cmd so
:: that the Packer ssh connection is not inadvertently dropped during the
:: Sysprep run

setlocal EnableDelayedExpansion
setlocal EnableExtensions

set SSH_SERVICE=

echo ==^> Determining installed SSH_SERVICE
sc query sshd >nul 2>nul && set SSH_SERVICE=sshd
sc query opensshd >nul 2>nul && set SSH_SERVICE=opensshd

echo ==^> Starting the %SSH_SERVICE% service
sc start %SSH_SERVICE%
