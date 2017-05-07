@echo off

:: Set to list of chocolatey apps for install-chocolatey-apps.cmd to install
:: Default: chocolatey*.txt
:: set CHOCOLATEY_APPS=chocolatey*.txt

:: Options to pass to 'choco install' command
:: Default: --force
:: set CHOCOLATEY_INSTALL_OPTIONS=--force --debug --verbose

:: Set the Cygwin mirror to download apps from
:: Default: http://mirrors.kernel.org/sourceware/cygwin
:: set CYGWIN_MIRROR_URL=http://mirrors.kernel.org/sourceware/cygwin

:: Set the mininum required powershell version
:: Default: 2.0
:: set MIN_POWERSHELL_VERSION=2.0

:: Set to any value to echo commands as they are run
:: 5: Debug & echo on
:: 4: Debug & echo off
:: 3: Info
:: 2: Warning
:: 1: Error
:: 0: Fatal
:: Default: 3
:: set PACKER_DEBUG=4

:: Set to any value to ignore non-zero exit codes for /script folder scripts
:: Default: (unset)
:: set PACKER_IGNORE_ERRORS=1

:: Set to the directory where scripts/save-logs.cmd will save the installation logs
:: Default: z:\c\packer_logs
:: set PACKER_LOG_DIR=z:\c\packer_logs

:: Set the pagefile size in MB for floppy/pagefile.bat
:: Default: 512
:: set PACKER_PAGEFILE_MB=512

:: Set to %USERNAME%'s password
:: Default: %USERNAME%
:: set PACKER_PASSWORD=%USERNAME%

:: Set to seconds to pause after each script is run
:: Default: (unset)
:: set PACKER_PAUSE=60

:: Set to any value to pause if a script returns a non-zero exit value
:: Default: (unset)
:: set PACKER_PAUSE_ON_ERROR=1

:: Set to name of text file containing script for _run-scripts.cmd to run
:: Default: _run-scripts.txt
:: set PACKER_RUN=_run-scripts.txt

:: Set to paths to search for files, before trying to download them
:: %USERPROFILE% is listed first, as this is where Packer uploads
:: VMWare's windows.iso, and Virtualbox's VBoxGuestAdditions.iso
:: Default: "%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
:: set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

:: Set to patterns of scripts for _run-scripts.cmd to run
:: Default: *.bat *.cmd *.ps1
:: set PACKER_SCRIPTS_TO_RUN=*.bat *.cmd *.ps1

:: Set to list of services to start by floppy/zz-start-sshd.cmd
:: Default: opensshd sshd winrm
:: set PACKER_SERVICES=opensshd sshd winrm

:: Set to any value to shutdown if a script returnes a non-zero exit value
:: Default: (unset)
:: set PACKER_SHUTDOWN_ON_ERROR=1

:: Set to list of files for _run-scripts.cmd to skip running
:: Default: (unset)
:: set PACKER_SKIP=update.*

:: Set to directory for temporary files (it will be created if it does not exist)
:: Default: %TEMP%\packer
:: set PACKER_TMP=%TEMP%\packer

    :: Set to location to log script output
    :: Default: %PACKER_TMP%\packer.log
    :: set PACKER_LOG=%PACKER_TMP%\packer.log

:: Set to timeout in seconds for scheduled tasks to complete
:: Default: 2700 (45 minutes)
:: set PACKER_TIMEOUT=2700

:: Set to list of scoop apps for install-scoop-apps.cmd to install
:: Default: scoop*.txt
:: set SCOOP_APPS=scoop*.txt

:: Set to list of scoop buckets to add
:: Default: (unset)
:: set SCOOP_BUCKETS=extras nirsoft versions nightlies rasa#https://github.com/rasa/scoops.git

:: Set to option to pass to 'scoop install' command (e.g., --global)
:: Default: (unset)
:: set SCOOP_INSTALL_OPTIONS=--global

:: Set to new password for the sshd service
:: Default: D@rj33l1ng
:: set SSHD_PASSWORD=D@rj33l1ng

:: Email variables used by floppy/_email.cmd
:: Don't forget to escape shell metacharacters with ^, and escape !s with ^^
:: set EMAIL_HOST=
:: set EMAIL_PORT=
:: set EMAIL_USER=
:: set EMAIL_PASS=
:: set EMAIL_FROM=
:: set EMAIL_TO=
:: set EMAIL_BCC=
:: set EMAIL_CC=
:: set EMAIL_SUBJECT=
:: set EMAIL_BODY=
:: set EMAIL_FILES=

:: URLs used by many of the scripts

set CHOCOLATEY_URL=https://chocolatey.org/install.ps1
set CYGWIN_URL=http://cygwin.com/setup-x86.exe
set DOTNET4_URL=https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe
set HANDLE_URL=http://live.sysinternals.com/handle.exe
set KB2842230_32_URL=http://hotfixv4.microsoft.com/Windows%%207/Windows%%20Server2008%%20R2%%20SP1/sp2/Fix467402/7600/free/463983_intl_i386_zip.exe
set KB2842230_64_URL=http://hotfixv4.microsoft.com/Windows%%207/Windows%%20Server2008%%20R2%%20SP1/sp2/Fix467402/7600/free/463984_intl_x64_zip.exe
set NUGET_URL=http://nuget.org/nuget.exe
set OPENSSH_URL=https://www.mls-software.com/files/setupssh-7.5p1-1.exe
set POWERSHELL_32_URL=https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu
set POWERSHELL_64_URL=https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu
set SCOOP_URL=https://get.scoop.sh#/scoop.ps1
:: http://live.sysinternals.com/sdelete.exe is version 2.0.0 and buggy
:: Here's version 1.6.1 which works:
set SDELETE_URL=http://web.archive.org/web/20160404120859/http://live.sysinternals.com/sdelete.exe
set SEVENZIP_32_URL=http://www.7-zip.org/a/7z1604.msi
set SEVENZIP_64_URL=http://www.7-zip.org/a/7z1604-x64.msi
set ULTRADEFRAG_32_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.i386.zip
set ULTRADEFRAG_64_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.amd64.zip
set VAGRANT_PUB_URL=https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
set VBOX_ISO_URL=http://download.virtualbox.org/virtualbox/5.1.22/VBoxGuestAdditions_5.1.22.iso
set VMWARE_TOOLS_TAR_URL=https://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.5.5/5234757/windows/packages/tools-windows.tar
set WGET_URL=https://eternallybored.org/misc/wget/current/wget.exe
set WUA_32_URL=http://download.windowsupdate.com/windowsupdate/redist/standalone/7.6.7600.320/WindowsUpdateAgent-7.6-x86.exe
set WUA_64_URL=http://download.windowsupdate.com/windowsupdate/redist/standalone/7.6.7600.320/WindowsUpdateAgent-7.6-x64.exe

:: see https://downloads.chef.io/chef
set     CHEF_VERSION=13.0.118
set CHEF_SUB_VERSION=13.0.118-1
:: see https://downloads.chef.io/chefdk
set     CHEFDK_VERSION=1.3.43
set CHEFDK_SUB_VERSION=1.3.43-1
:: see https://downloads.puppetlabs.com/windows/
set PUPPET_VERSION=latest
:: see https://docs.saltstack.com/en/latest/topics/installation/windows.html
set SALT_VERSION=2016.11.4

if defined CM_VERSION (
    if /i not "%CM_VERSION%" == "latest" (
        set CHEF_VERSION=%CM_VERSION%
        set CHEFDK_VERSION=%CM_VERSION%
        set PUPPET_VERSION=%CM_VERSION%
        set SALT_VERSION=%CM_VERSION%
    )
)

set CHEF_32_URL=https://packages.chef.io/files/stable/chef/%CHEF_VERSION%/windows/2008r2/chef-client-%CHEF_SUB_VERSION%-x86.msi
set CHEF_64_URL=https://packages.chef.io/files/stable/chef/%CHEF_VERSION%/windows/2008r2/chef-client-%CHEF_SUB_VERSION%-x64.msi
set CHEFDK_32_URL=https://packages.chef.io/files/stable/chefdk/%CHEFDK_VERSION%/windows/2008r2/chefdk-%CHEFDK_SUB_VERSION%-x86.msi
:: x64 is 404:
set CHEFDK_64_URL=https://packages.chef.io/files/stable/chefdk/%CHEFDK_VERSION%/windows/2008r2/chefdk-%CHEFDK_SUB_VERSION%-x86.msi
set PUPPET_32_URL=https://downloads.puppetlabs.com/windows/puppet-%PUPPET_VERSION%.msi
set PUPPET_64_URL=https://downloads.puppetlabs.com/windows/puppet-x64-%PUPPET_VERSION%.msi
set SALT_32_URL=https://repo.saltstack.com/windows/Salt-Minion-%SALT_VERSION%-x86-Setup.exe
set SALT_64_URL=https://repo.saltstack.com/windows/Salt-Minion-%SALT_VERSION%-AMD64-Setup.exe

set OSArchitecture=
if /i "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    set OSArchitecture=64-bit
)
if /i "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
    set OSArchitecture=64-bit
)
if not defined OSArchitecture (
    for /f "tokens=*" %%i in ('wmic os get OSArchitecture /value ^| find "="') do (
        set %%i
    )
)

if /i "%OSArchitecture%" == "32-bit" (
    set CHEF_URL=%CHEF_32_URL%
    set CHEFDK_URL=%CHEFDK_32_URL%
    set KB2842230_URL=%KB2842230_32_URL%
    set POWERSHELL_URL=%POWERSHELL_32_URL%
    set PUPPET_URL=%PUPPET_32_URL%
    set SALT_URL=%SALT_32_URL%
    set SEVENZIP_URL=%SEVENZIP_32_URL%
    set ULTRADEFRAG_URL=%ULTRADEFRAG_32_URL%
    set WUA_URL=%WUA_32_URL%
) else (
    set CHEF_URL=%CHEF_64_URL%
    set CHEFDK_URL=%CHEFDK_64_URL%
    set KB2842230_URL=%KB2842230_64_URL%
    set POWERSHELL_URL=%POWERSHELL_64_URL%
    set PUPPET_URL=%PUPPET_64_URL%
    set SALT_URL=%SALT_64_URL%
    set SEVENZIP_URL=%SEVENZIP_64_URL%
    set ULTRADEFRAG_URL=%ULTRADEFRAG_64_URL%
    set WUA_URL=%WUA_64_URL%
)

set CHEF_VERSION=
set CHEFDK_VERSION=
set PUPPET_VERSION=
set SALT_VERSION=

set CHEF_32_URL=
set CHEF_64_URL=
set CHEFDK_32_URL=
set CHEFDK_64_URL=
set KB2842230_32_URL=
set KB2842230_64_URL=
set POWERSHELL_32_URL=
set POWERSHELL_64_URL=
set PUPPET_32_URL=
set PUPPET_64_URL=
set SALT_32_URL=
set SALT_64_URL=
set SEVENZIP_32_URL=
set SEVENZIP_64_URL=
set ULTRADEFRAG_32_URL=
set ULTRADEFRAG_64_URL=
set WUA_32_URL=
set WUA_64_URL=

ver >nul
