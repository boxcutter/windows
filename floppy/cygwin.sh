#!/bin/bash

export CYGWIN="ntsecbinmode mintty nodosfilewarning"

echo '==> Make user home directories default to their windows profile directory'

ln -s "$(dirname $(cygpath -D))" /home/$USERNAME

mkpasswd -l -p "$(cygpath -H)" >/etc/passwd

echo '==> Creating /etc/group (required by sshd)'
mkgroup -l >/etc/group

echo "==> set up host's ssh config files"

ssh-host-config -y -c "$CYGWIN" -w $1

chmod a+w /etc/sshd_config

sed -i -e 's/StrictModes yes/StrictModes no/i' /etc/sshd_config
sed -i -e 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/i' /etc/sshd_config
sed -i -e 's/#PermitUserEnvironment no/PermitUserEnvironment yes/i' /etc/sshd_config
sed -i -e 's/#UseDNS yes/UseDNS no/i' /etc/sshd_config

chmod go-w /etc/sshd_config

echo "==> set up user's ssh config files"

ssh-user-config -y -p ''

sed -i.bak -e 's/^TMP/#TMP/; s/^TEMP/#TEMP/; s/^unset TMP/#unset TMP/' /etc/profile

SSHENV=$SYSTEMDRIVE/Users/$USERNAME/.ssh/environment

echo "APPDATA=$SYSTEMDRIVE\\Users\\$USERNAME\\AppData\\Roaming" >>$SSHENV
echo "CommonProgramFiles=$SYSTEMDRIVE\\Program Files\\Common Files" >>$SSHENV
echo "LOCALAPPDATA=$SYSTEMDRIVE\\Users\\$USERNAME\\AppData\\Local" >>$SSHENV
echo "ProgramData=$SYSTEMDRIVE\\ProgramData" >>$SSHENV
echo "ProgramFiles=$SYSTEMDRIVE\\Program Files" >>$SSHENV
echo "PSModulePath=$SYSTEMDRIVE\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules\\" >>$SSHENV
echo "PUBLIC=$SYSTEMDRIVE\\Users\\Public" >>$SSHENV
echo "SESSIONNAME=Console" >>$SSHENV
echo "TEMP=$SYSTEMDRIVE\\Users\\$USERNAME\\AppData\\Local\\Temp" >>$SSHENV
echo "TMP=$SYSTEMDRIVE\\Users\\$USERNAME\\AppData\\Local\\Temp" >>$SSHENV
# to override "cyg_server":
echo "USERNAME=$USERNAME" >>$SSHENV

if [ -d "$SYSTEMDRIVE/Program Files (x86)" ];then
  echo "CommonProgramFiles(x86)=$SYSTEMDRIVE\\Program Files (x86)\\Common Files" >>$SSHENV
  echo "CommonProgramW6432=$SYSTEMDRIVE\\Program Files\\Common Files" >>$SSHENV
  echo "ProgramFiles(x86)=$SYSTEMDRIVE\\Program Files (x86)" >>$SSHENV
  echo "ProgramW6432=$SYSTEMDRIVE\\Program Files" >>$SSHENV
fi
