#!/bin/bash

# exit on any failure
set -e

if [[ -n "${PACKER_DEBUG}" ]]; then
  set -vx
fi

if ! echo $PATH | /bin/grep -q /usr/bin; then
  export PATH=/usr/bin:$PATH
fi

if [[ -n "${CYGWIN}" ]]; then
  export CYGWIN="ntsecbinmode mintty nodosfilewarning"
fi

echo "==> Setting user's home directories to their windows profile directory"

ln -s "$(dirname $(cygpath -D))" "/home/${USERNAME}"

mkpasswd -l -p "$(cygpath -H)" >/etc/passwd

echo '==> Creating /etc/group (required by sshd)'
mkgroup -l >/etc/group

echo "==> Setting up host's ssh config files"

ssh-host-config -y -c "${CYGWIN}" -w $1

chmod a+w /etc/sshd_config

sed -i -e 's/StrictModes yes/StrictModes no/i' /etc/sshd_config
sed -i -e 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/i' /etc/sshd_config
sed -i -e 's/#PermitUserEnvironment no/PermitUserEnvironment yes/i' /etc/sshd_config
sed -i -e 's/#UseDNS yes/UseDNS no/i' /etc/sshd_config

chmod go-w /etc/sshd_config

echo "==> Setting up user's ssh config files"

ssh-user-config -y -p ''

echo "==> Removing TEMP and TMP overrides in /etc/profile"

sed -i.bak -e 's/^TMP/#TMP/; s/^TEMP/#TEMP/; s/^unset TMP/#unset TMP/' /etc/profile

SSHENV="${SYSTEMDRIVE}/Users/${USERNAME}/.ssh/environment"

echo "==> Adding missing environment variables to ${SSHENV}"

echo "APPDATA=${SYSTEMDRIVE}\\Users\\${USERNAME}\\AppData\\Roaming" >>"${SSHENV}"
echo "COMMONPROGRAMFILES=${SYSTEMDRIVE}\\Program Files\\Common Files" >>"${SSHENV}"
echo "LOCALAPPDATA=${SYSTEMDRIVE}\\Users\\${USERNAME}\\AppData\\Local" >>"${SSHENV}"
echo "PROGRAMDATA=${SYSTEMDRIVE}\\ProgramData" >>"${SSHENV}"
echo "PROGRAMFILES=${SYSTEMDRIVE}\\Program Files" >>"${SSHENV}"
echo "PSMODULEPATH=${SYSTEMDRIVE}\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules\\" >>"${SSHENV}"
echo "PUBLIC=${SYSTEMDRIVE}\\Users\\Public" >>"${SSHENV}"
echo "SESSIONNAME=Console" >>"${SSHENV}"
echo "TEMP=${SYSTEMDRIVE}\\Users\\${USERNAME}\\AppData\\Local\\Temp" >>"${SSHENV}"
echo "TMP=${SYSTEMDRIVE}\\Users\\${USERNAME}\\AppData\\Local\\Temp" >>"${SSHENV}"
# This fix simply masks the issue, we need to fix the underlying cause
# to override "sshd_server":
# echo "USERNAME=${USERNAME}" >>"${SSHENV}"

if [ -d "${SYSTEMDRIVE}/Program Files (x86)" ];then
  echo "COMMONPROGRAMFILES(X86)=${SYSTEMDRIVE}\\Program Files (x86)\\Common Files" >>"${SSHENV}"
  echo "COMMONPROGRAMW6432=${SYSTEMDRIVE}\\Program Files\\Common Files" >>"${SSHENV}"
  echo "PROGRAMFILES(X86)=${SYSTEMDRIVE}\\Program Files (x86)" >>"${SSHENV}"
  echo "PROGRAMW6432=${SYSTEMDRIVE}\\Program Files" >>"${SSHENV}"
fi
