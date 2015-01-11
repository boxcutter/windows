@echo off

:: Uncomment the following to set a different Cygwin mirror
:: Default: http://mirrors.kernel.org/sourceware/cygwin
:: set CYGWIN_MIRROR_URL=http://mirrors.kernel.org/sourceware/cygwin

:: Uncomment the following to echo commands as they are run
:: Default: (unset)
:: set PACKER_DEBUG=1

:: Uncomment the following to define the directory where scripts/save-logs.cmd
:: will save the installation logs
:: Default: z:\c\packer_logs
:: set PACKER_LOG_DIR=z:\c\packer_logs

:: Uncomment the following to pause PACKER_PAUSE seconds after each script is
:: run by floppy/00-run-all-scripts.cmd (unless you press Y)
:: Default: (unset)
:: set PACKER_PAUSE=60

:: Uncomment the following to pause if a script run by
:: floppy/00-run-all-scripts.cmd returns a non-zero exit value
:: Default: (unset)
:: set PACKER_PAUSE_ON_ERROR=1

:: Uncomment the following to shutdown if a script run by
:: floppy/00-run-all-scripts.cmd returns a non-zero exit value
:: Default: (unset)
:: set PACKER_SHUTDOWN_ON_ERROR=1

:: Locations to search to find files locally, before trying to download them
:: %USERPROFILE% is listed first, as this is where Packer uploads
:: VMWare's windows.iso, and Virtualbox's VBoxGuestAdditions.iso
:: Default: "%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

:: List of services to start by floppy/zz-start-sshd.cmd
:: Default: opensshd sshd BvSshServer winrm
set PACKER_SERVICES=opensshd sshd BvSshServer winrm

:: Uncomment the following to define a new password for the sshd service
:: Default: D@rj33l1ng
:: set SSHD_PASSWORD=D@rj33l1ng
