import json
import os
import re
import shutil
import sys
import time

winrm = False
ssh = True
keep_failed_build = True
vmx_data_post = True
compression_level = 0
chocolatey = False
add_debugging = True
set_packer_debug = True
add_debug_log = True
add_unzip_vbs = False
add_shell_command = False
add_ssh_uninstaller = False
tools_upload_flavor = False

attach_provisions_iso = True
attach_windows_iso = True
attach_vboxguestadditions_iso = True

if add_ssh_uninstaller:
  add_debugging = False
  add_debug_log = False
  vmx_data_post = False

def touch(filename, mtime):
  with open(filename, 'a+'):
    pass
  os.utime(filename, (mtime, mtime))
  return 0

def touch_by_file(filename, touch_filename):
  touch(filename, os.path.getmtime(touch_filename))

if len(sys.argv) < 2:
  sys.exit('Usage: ' + sys.argv[0] + ' filename.json')

if len(sys.argv) >= 3:
  winrm = True
  keep_failed_build = True
  vmx_data_post = True

json_file_path = sys.argv[1]
orig = json_file_path + '.orig'
print('Updating ' + json_file_path)

if not os.path.isfile(orig):
  mtime = os.path.getmtime(json_file_path)
  shutil.copyfile(json_file_path, orig)
  touch(orig, mtime)

json_file = open(orig, 'rb')
json_data = json.load(json_file)

debug_cmd = 'floppy/zzz-debug-log.cmd'
save_logs_cmd = 'script/save-logs.cmd'
unzip_vbs = 'floppy/unzip.vbs'
wget_exe = '.windows/wget.exe'
download_cmd = 'floppy/_download.cmd'
packer_config_cmd = 'floppy/_packer_config.cmd'
packer_config_local_cmd = 'floppy/_packer_config_local.cmd'
shutdown_seconds = '10'
timeout_seconds = '3600'

if winrm:
  winrm_suffix = '_winrm'
else:
  winrm_suffix = ''

shutdown_comment = 'Packer_Shutdown'
shutdown_command = 'shutdown /s /t %s /f /d p:4:1 /c %s' % (shutdown_seconds, shutdown_comment)

cwd = os.getcwd()
provisions_iso = cwd + '/.windows/provisions/provisions.iso'

windows_iso = 'C:/Program Files (x86)/VMware/VMware Workstation/windows.iso'

vboxguestadditions_iso = "C:/Progra~1/Oracle/VirtualBox/VBoxGuestAdditions.iso"

for i, a in enumerate(json_data['builders']):
  if re.search('^(vmware|virtualbox)\-', a['type']):
    if keep_failed_build:
      a['keep_failed_build'] = True

    a['output_directory'] = 'output-%s_%s%s' % (a['type'], a['vm_name'], winrm_suffix)
    a['ssh_wait_timeout'] = timeout_seconds + 's'
    a['shutdown_timeout'] = timeout_seconds + 's'
    a['shutdown_command'] = shutdown_command

    if add_ssh_uninstaller:
      del a['shutdown_timeout']
      #del a['shutdown_command']
      #a['shutdown_command'] = 'choice /C Y /N /T %s /D Y /M "Waiting %s seconds"' % (timeout_seconds, timeout_seconds)

    a['http_directory'] = 'floppy'

    floppy_files = dict.fromkeys(a['floppy_files'], True)

    if add_debug_log:
      if os.path.exists(debug_cmd):
        floppy_files[debug_cmd] = True
    if os.path.exists(download_cmd):
      floppy_files[download_cmd] = True
    if os.path.exists(packer_config_cmd):
      floppy_files[packer_config_cmd] = True
    if os.path.exists(packer_config_local_cmd):
      floppy_files[packer_config_local_cmd] = True
    if os.path.exists(wget_exe):
      floppy_files[wget_exe] = True
    if add_unzip_vbs:
      if os.path.exists(unzip_vbs):
        floppy_files[unzip_vbs] = True

    if not ssh:
      if 'floppy/cygwin.bat' in floppy_files:
        del floppy_files['floppy/cygwin.bat']
      if 'floppy/openssh.bat' in floppy_files:
        del floppy_files['floppy/openssh.bat']

    a['floppy_files'] = floppy_files.keys()

    a['floppy_files'].sort()

  if re.search('^vmware\-', a['type']):
    # to turn off to see if Cygwin is failing because of this
    if winrm or add_ssh_uninstaller:
      # buggy with winrm
      if 'tools_upload_flavor' in a:
        del a['tools_upload_flavor']

    a['disk_type_id'] = "0"
    a['skip_compaction'] = compression_level == 0

    if winrm:
      a['communicator'] = 'winrm'
      a['winrm_username'] = 'vagrant'
      a['winrm_password'] = 'vagrant'
      a['winrm_timeout'] = timeout_seconds + 's'

    if not tools_upload_flavor:
      if 'tools_upload_flavor' in a:
        del a['tools_upload_flavor']

    if not 'vmx_data' in a:
      a['vmx_data'] = {}

    a['vmx_data']['sharedFolder.maxNum'] = '1'
    a['vmx_data']['sharedFolder0.enabled'] = 'TRUE'
    a['vmx_data']['sharedFolder0.expiration'] = 'never'
    a['vmx_data']['sharedFolder0.guestName'] = 'C'
    a['vmx_data']['sharedFolder0.hostPath'] = 'C:\\'
    a['vmx_data']['sharedFolder0.present'] = 'TRUE'
    a['vmx_data']['sharedFolder0.readAccess'] = 'TRUE'
    a['vmx_data']['sharedFolder0.writeAccess'] = 'TRUE'
    a['vmx_data']['hgfs.maprootshare'] = 'TRUE'

    a['vmx_data']['sound.autodetect'] = 'TRUE'
    a['vmx_data']['sound.filename'] = '-1'
    #a['vmx_data']['sound.pciSlotNumber'] = '32'
    a['vmx_data']['sound.present'] = 'TRUE'
    a['vmx_data']['sound.startconnected'] = 'TRUE'
    a['vmx_data']['sound.virtualdev'] = 'hdaudio'

    a['vmx_data']['virtualhw.version'] = '10'

    if attach_provisions_iso:
      if os.path.exists(provisions_iso):
        a['vmx_data']['ide1:1.deviceType'] = 'cdrom-image'
        a['vmx_data']['ide1:1.fileName'] = provisions_iso
        a['vmx_data']['ide1:1.present'] = 'TRUE'
        a['vmx_data']['ide1:1.startConnected'] = 'TRUE'

    if attach_windows_iso:
      if os.path.exists(windows_iso):
        a['vmx_data']['scsi0:1.present'] = 'TRUE'
        a['vmx_data']['scsi0:1.deviceType'] = 'cdrom-image'
        a['vmx_data']['scsi0:1.fileName'] = windows_iso

    if vmx_data_post:
      if not 'vmx_data_post' in a:
        a['vmx_data_post'] = {}

      a['vmx_data_post']['ethernet0.virtualDev'] = 'vmxnet3'
      a['vmx_data_post']['RemoteDisplay.vnc.enabled'] = 'false'
      a['vmx_data_post']['RemoteDisplay.vnc.port'] = '5900'
      a['vmx_data_post']['scsi0.virtualDev'] = 'lsilogic'

  if re.search('^virtualbox\-', a['type']):
    if not 'vboxmanage' in a:
      a['vboxmanage'] = []

    if attach_provisions_iso:
      if os.path.exists(provisions_iso):
        a['vboxmanage'].append([
          "storageattach",
          "{{.Name}}",
          "--storagectl",
          "IDE Controller",
          "--port",
          "1",
          "--device",
          "1",
          "--type",
          "dvddrive",
          "--medium",
          provisions_iso
        ])

    if attach_vboxguestadditions_iso:
      if os.path.exists(vboxguestadditions_iso):
        # a['guest_additions_url'] = vboxguestadditions_iso
        a['vboxmanage'].append([
          "storageattach",
          "{{.Name}}",
          "--storagectl",
          "SATA",
          "--port",
          "1",
          "--device",
          "0",
          "--type",
          "dvddrive",
          "--medium",
          vboxguestadditions_iso
        ])

for i in json_data['post-processors']:
  if i['type'] == 'vagrant':
    i['keep_input_artifact'] = True
    i['compression_level'] = compression_level
    #if winrm:
    #  i['output'] = 'winrm-' + i['output']

packer_debug_env = 'PACKER_DEBUG=1'

if add_shell_command:
  env_vars = [
    "CM={{user `cm`}}",
    "CM_VERSION={{user `cm_version`}}",
  ]

  if set_packer_debug:
    env_vars.append(packer_debug_env)

  debug_step = {
    "environment_vars": env_vars,
    "script": debug_cmd,
    "type": "shell",
  }

  json_data['provisioners'].insert(0, debug_step)

for i, a in enumerate(json_data['provisioners']):
  if a['type'] != 'shell':
    continue

  if winrm:
    # use winrm defaults
    if 'remote_path' in a:
      del a['remote_path']
    if 'execute_command' in a:
      del a['execute_command']

    a['guest_os_type'] = 'windows'

  if 'inline' in a:
    if winrm or add_ssh_uninstaller:
      if re.search('^rm ', a['inline'][0]):
        del json_data['provisioners'][i]
    continue

  #if winrm:
  a['binary'] = 'true'

  if 'script' in a:
    continue

  if not 'scripts' in a:
    continue

  #if 'execute_command' in a:
  #  a['execute_command'] = re.sub(' /c ', ' /q /c ', a['execute_command'])

  if set_packer_debug:
    if 'environment_vars' in a:
      packer_debug = False

      for j in a['environment_vars']:
        if j == packer_debug_env:
          packer_debug = True
          break

      if not packer_debug:
        a['environment_vars'].append(packer_debug_env)

  scripts = []
  if add_debugging:
    if os.path.exists('script/dump-logs.cmd'):
      scripts.append('script/dump-logs.cmd')
  # don't need any more:
  #scripts.append('script/01-install-handle.cmd')
  for j in a['scripts']:
    if j == 'script/clean.bat':
      if add_debugging:
          scripts.append('script/save-logs.cmd')
          scripts.append('script/save-temp-dirs.cmd')
      if chocolatey:
          scripts.append('script/nuget.cmd')
          #scripts.append('script/reboot.cmd')
          scripts.append('script/chocolatey.cmd')
    if compression_level == 0:
      if j == 'script/clean.bat':
        continue
      if j == "script/ultradefrag.bat":
        continue
      if j == "script/uninstall-7zip.bat":
        continue
      if j == "script/sdelete.bat":
        continue

    #if not add_ssh_uninstaller:
    scripts.append(j)

  if add_debug_log:
    scripts.append(debug_cmd)

  if add_ssh_uninstaller:
    if re.search('cygwin', json_file_path):
      scripts.append('script/uninstall-cygwin.cmd')
    else:
      scripts.append('script/uninstall-openssh.cmd')

  a['scripts'] = scripts

if 'variables' in json_data:
  json_data['variables']['shutdown_command'] = shutdown_command

new_data = json_data

mtime = os.path.getmtime(json_file_path)

new_data  = json.dumps(new_data, sort_keys=True, indent=2, separators=(',', ': '))
json_file.close()

json_file = open(json_file_path, 'wb')
json_file.write(new_data)
json_file.close()

touch(json_file_path, mtime)
