#!/usr/bin/env python

from __future__ import print_function

import json
import os
import pprint
import re
import shutil
import sys
import time

LOG_LEVEL_ALERT = 1
LOG_LEVEL_INFO  = 6
LOG_LEVEL_DEBUG = 7

# strings -n 5 vmnat.exe | findstr "win" | sort

vmware_guest_os_types = {
  'win7x86':  'windows7',
  'win7x64':  'windows7-64',
  'win2008':  'windows7srv-64',
  'win8x86':  'windows8',
  'win8x64':  'windows8-64',
  'win81x86': 'windows8',
  'win81x64': 'windows8-64',
  'win2012':  'windows8srv-64',
  'win10x86': 'windows9',
  'win10x64': 'windows9-64',
  'win2016':  'windows9srv-64',
}

# VBoxManage list ostypes | findstr "^ID:" | findstr "Win" | sort

vbox_guest_os_types = {
  'win2008':  'Windows2008_64',
  'win7x86':  'Windows7',
  'win7x64':  'Windows7_64',
  'win8x86':  'Windows8',
  'win8x64':  'Windows8_64',
  'win81x86': 'Windows81',
  'win81x64': 'Windows81_64',
  'win2012':  'Windows2012_64',
  'win2016':  'Windows2012_64', # @TODO FIXME
  'win10x86': 'Windows10',
  'win10x64': 'Windows10_64',
}

user_vars = {
  'builders': {
    'disk_size': '{{ user `disk_size` }}',
    'headless': '{{ user `headless` }}',
    'iso_checksum': '{{ user `iso_checksum` }}',
    'iso_checksum_type': '{{ user `iso_checksum_type` }}',
    'iso_url': '{{ user `iso_url` }}',
    'shutdown_command': '{{ user `shutdown_command` }}',
    'vm_name': '{{ user `vm_name` }}',
    'winrm_password': '{{ user `winrm_password` }}',
    'winrm_timeout': '{{ user `winrm_timeout` }}',
    'winrm_username': '{{ user `winrm_username` }}',
  },
  'post-processors': {
    'compression_level': '{{ user `compression_level` }}',
    'output': 'box/{{.Provider}}/{{ user `vm_name` }}-{{ user `cm` }}{{ user `cm_version` }}-{{ user `version` }}.box',
    'vagrantfile_template': 'tpl/vagrantfile-{{ user `vm_name` }}.tpl',
  },
  'provisioners': {
    'environment_vars': [
      'CM={{ user `cm` }}',
      'CM_VERSION={{ user `cm_version` }}',
      'PACKER_PASSWORD={{ user `winrm_password` }}',
      'PACKER_UPDATE={{ user `update` }}',
      'PACKER_VERSION={{ user `version` }}',
      'PACKER_VM_NAME={{ user `vm_name` }}',
    ],
  },
}

parallels_vars = {
  'prlctl': [
    [
      'set',
      '{{.Name}}',
      '--memsize',
      '{{ user `memsize` }}'
    ],
    [
      'set',
      '{{.Name}}',
      '--cpus',
      '{{ user `cpus` }}'
    ]
  ]
}

virtualbox_vars = {
  'vboxmanage': [
    [
      'modifyvm',
      '{{.Name}}',
      '--memory',
      '{{ user `memsize` }}'
    ],
    [
      'modifyvm',
      '{{.Name}}',
      '--cpus',
      '{{ user `cpus` }}'
    ],
    [
      "setextradata",
      "{{.Name}}",
      "VBoxInternal/CPUM/CMPXCHG16B",
      "1"
    ]
  ]
}

vmware_vars = {
  #'guest_os_type': 'windows9-64',
  'skip_compaction': '{{ user `skip_compaction` }}',
  'vmx_data': {
    'cpuid.coresPerSocket': '{{ user `cores` }}',
    'memsize': '{{ user `memsize` }}',
    'numvcpus': '{{ user `cpus` }}',
  }
}

def remove(a, v):
  if v in a:
    a.remove(v)
  return a

def append(a, v):
  if not v in a:
    a.append(v)
  return a

def appendFile(a, v):
  if not os.path.isfile(v):
    print("File not found: '%s'" % v)
    return a
  return append(a, v)

def touch(filename, mtime):
  with open(filename, 'a+'):
    pass
  os.utime(filename, (mtime, mtime))
  return 0

def touchViaReference(filename, touch_filename):
  return touch(filename, os.path.getmtime(touch_filename))

def getProvision(file, relative = False):
  rv = 'provisions/' + file
  if not os.path.isfile(rv):
    print("File not found: '%s'" % rv)
  if not relative:
    cwd = os.getcwd()
    cwd = re.sub('\\\\', '/', cwd) + '/'
    rv = cwd + rv
  return rv

def getVboxGuestAdditionsISO():
  vboxguestadditions_iso = ''
  for dir in ['Program Files (x86)', 'Program Files']:
    s = 'C:/%s/Oracle/VirtualBox/VBoxGuestAdditions.iso' % (dir)
    if os.path.isfile(s):
      return s
  print("File not found: '%s'" % s)
  return ''

def vboxStorageAttach(iso, device):
  return [
    "storageattach",
    "{{.Name}}",
    "--storagectl",
    "IDE Controller",
    "--port",
    "1",
    "--device",
    device,
    "--type",
    "dvddrive",
    "--medium",
    iso
  ]

def main(file):
  print('Updating ' + file)

  orig = file + '.orig'

  if not os.path.isfile(orig):
    mtime = os.path.getmtime(file)
    shutil.copyfile(file, orig)
    touch(orig, mtime)

  json_file = open(orig, 'rb')
  json_data = json.load(json_file)

  remove_floppies = [
    #'enable-windows-updates.cmd',
    #'oracle-cert.cer',
    #'passwordchange.bat',
    #'powerconfig.bat',
    #'update.bat',
  ]

  add_floppies = [
    'folderoptions.bat',
  ]

  remove_scripts = [
    'clean.bat',
    'defrag.cmd',
    'freeze.cmd',
    'sdelete.bat',
    #'ultradefrag.bat',
    'uninstall-7zip.bat',
    #'vagrant.bat',
    #'cmtool.bat',
    #'vmtool.bat', # @TODO
  ]

  add_scripts = [
    #'uninstall-7zip.bat',
    #'save-logs.cmd',
    #'save-temp-dirs.cmd',
    'clean.bat',
    #'ultradefrag.bat',
    'defrag.cmd',
    'sdelete.bat',
    #'zero.cmd',
  ]

  copy_scripts = [
    #'01-install-handle.cmd',
    'chocolatey.cmd',
    #'clean.bat',
    # requires CM to be set:
    #'cmtool.bat',
    'defrag.cmd',
    'dotnet4.cmd',
    #'dump-logs.cmd',
    'enable-rdp.cmd',
    #'freeze.cmd',
    'install-packages.cmd',
    #'nuget.cmd',
    #'reboot.cmd',
    #'regenerate-dotnet-cache.cmd',
    #'save-logs.cmd',
    #'save-temp-dirs.cmd',
    #'sdelete.bat',
    #'ultradefrag.bat',
    #'uninstall-7zip.bat',
    #'uninstall-cygwin.cmd',
    #'uninstall-openssh.cmd',
    'vagrant.bat',
    'vmtool.bat',
    #'wait.cmd',
    #'zero.cmd',
  ]

  if not test_everything:
    copy_scripts = []

  copy__scripts = [
    #'01-install-handle.cmd',
    #'chocolatey.cmd',
    #'clean.bat',
    #'cmtool.bat',
    #'defrag.cmd',
    #'dotnet4.cmd',
    'dump-logs.cmd',
    #'enable-rdp.cmd',
    #'freeze.cmd',
    #'install-packages.cmd',
    'nuget.cmd',
    #'reboot.cmd',
    #'regenerate-dotnet-cache.cmd',
    'save-logs.cmd',
    'save-temp-dirs.cmd',
    #'sdelete.bat',
    #'ultradefrag.bat',
    #'uninstall-7zip.bat',
    #'uninstall-cygwin.cmd',
    #'uninstall-openssh.cmd',
    #'vagrant.bat',
    'vmtool.bat',
    #'wait.cmd',
    #'zero.cmd',
  ]

  if not test_everything:
    copy__scripts = []

  ######################
  # meta flags
  ######################

  test_everything = False

  log_level = LOG_LEVEL_INFO

  if test_everything:
    log_level = LOG_LEVEL_DEBUG

  optimize_for_speed = test_everything

  copy_all_scripts = test_everything

  test_all_scripts = test_everything

  test_all_files = test_everything

  ######################
  # individual flags
  ######################

  chocolatey = True

  clean = True

  freeze = False
  wait = not test_everything

  add_shutdown_command = True

  timeout_seconds = 0 # 86400

  update_bat = not test_everything

  # see https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1003746
  vmware_version = 0 # 12

  ######################
  # constants
  ######################

  compression_level = 0 # 1 # 0

  cpus = '1'

  disk_size = '128000'

  guest_additions_mode = 'attach'

  memsize = '2048' # 1536

  shutdown_seconds = 0 # 10
  shutdown_comment = 'Packer_Shutdown'
  shutdown_command = 'shutdown /s /t %d /f /d p:4:1 /c %s' % (shutdown_seconds, shutdown_comment)

  winrm_password = 'vagrant'
  winrm_timeout = '10000s'
  winrm_username = 'vagrant'

  ######################
  # @TODO cleanup these flags
  ######################

  #keep_failed_build = False
  vmx_data_post = False

  # add dump-logs.cmd, save-logs.cmd, save-temp-dirs.cmd to scripts/
  add_debugging    = (log_level >= LOG_LEVEL_DEBUG)

  add_debugging = True

  # set PACKER_DEBUG=1 in environment
  set_packer_debug = (log_level >= LOG_LEVEL_INFO)

  # add zzz-debug-log.cmd to floppy/
  add_debug_log    = (log_level >= LOG_LEVEL_DEBUG)

  #add_wget_exe = optimize_for_speed
  #add_tee_exe = optimize_for_speed

  add_packer_config_local = test_everything
  add_shell_command = False
  add_ssh_uninstaller = False

  # Windows 8 is buggy:
  remove_tools_upload_flavor = True

  add_keep_input_artifact = False
  add_binary = False
  add_disk_type_id = False
  add_http_directory = True
  add_output_directory = False

  add_skip_compaction = optimize_for_speed

  add_shared_folders = test_everything
  add_sound_drivers = False

  attach_provisions_iso = test_everything
  attach_vmware_tools_iso = test_everything
  attach_vboxguestadditions_iso = test_everything

  cygwin = re.search('-cygwin', file, re.I)
  openssh = re.search('-ssh', file, re.I)
  ssh = cygwin or openssh
  winrm = not ssh

  ######################
  # generated flags
  ######################

  add_vmx_data = \
    add_shared_folders or \
    add_sound_drivers or \
    attach_provisions_iso or \
    attach_vmware_tools_iso

  add_vboxmanage = \
    add_shared_folders or \
    add_sound_drivers or \
    attach_provisions_iso or \
    attach_vboxguestadditions_iso

  if add_ssh_uninstaller:
    add_debugging = False
    add_debug_log = False
    vmx_data_post = False


  ######################
  # generated flags
  ######################

  remove_floppies = remove(remove_floppies, 'unzip.vbs')

  add_floppies = appendFile(add_floppies, '_run-scripts.cmd')
  # used by autounattend.xml:
  add_floppies = appendFile(add_floppies, '_tee.cmd')

  remove_floppies = remove(remove_floppies, '00-run-all-scripts.cmd')
  ff = appendFile(ff, 'floppy/01-install-wget.cmd')

  if add_packer_config_local:
    add_floppies = appendFile(add_floppies, '_packer_config_local.cmd')

  if add_debug_log:
    add_floppies = appendFile(add_floppies, 'zzz-debug-log.cmd')

  if not update_bat:
    remove_floppies = remove(remove_floppies, 'update.bat')

  if not cygwin:
    remove_floppies = remove(remove_floppies, 'cygwin.bat')
    remove_floppies = remove(remove_floppies, 'cygwin.sh')

  if not openssh:
    remove_floppies = remove(remove_floppies, 'openssh.bat')

  if chocolatey:
    add_floppies = appendFile(add_floppies, '_schtask.cmd')
    add_floppies = appendFile(add_floppies, 'chocolatey.txt')

  remove_floppies = remove(remove_floppies, 'disablewinupdate.bat')
  # replaced by:
  add_floppies = appendFile(add_floppies, 'disable-windows-updates.cmd')

  #ff = appendFile(ff, 'floppy/enable-windows-updates.cmd')

  add_floppies = appendFile(add_floppies, 'disable-hibernation.cmd')
  add_floppies = appendFile(add_floppies, 'enable-quick-edit-mode.cmd')
  add_floppies = appendFile(add_floppies, 'enable-show-run-command.cmd')
  add_floppies = appendFile(add_floppies, 'enable-show-admin-tools.cmd')
  add_floppies = appendFile(add_floppies, 'disable-screen-saver.cmd')

  if test_everything:
    add_floppies = appendFile(add_floppies, 'enable-file-sharing.cmd')

  if test_all_scripts:
    # misleadingly named, actually enables updates
    add_floppies = appendFile(add_floppies, '01-install-unzip.cmd')
    add_floppies = appendFile(add_floppies, '01-install-powershell.cmd')
    add_floppies = appendFile(add_floppies, '01-install-7zip.cmd')
    add_floppies = appendFile(add_floppies, '01-install-tee.cmd')
    add_floppies = appendFile(add_floppies, 'folderoptions.bat')
    add_floppies = appendFile(add_floppies, 'networkprompt.bat')
    add_floppies = appendFile(add_floppies, 'passwordchange.bat')
    add_floppies = appendFile(add_floppies, 'powerconfig.bat')
    add_floppies = appendFile(add_floppies, 'disable-autologin.cmd')
    add_floppies = appendFile(add_floppies, 'upgrade-wua.bat')
    add_floppies = appendFile(add_floppies, 'floppy/uac-enable.bat')
    add_floppies = appendFile(add_floppies, 'floppy/uac-disable.bat')
    add_floppies = appendFile(add_floppies, 'floppy/time12h.bat')
    add_floppies = appendFile(add_floppies, 'floppy/time24h.bat')
    add_floppies = appendFile(add_floppies, 'floppy/pagefile.bat')
    add_floppies = appendFile(add_floppies, 'floppy/disable-tasks.cmd')
    add_floppies = appendFile(add_floppies, 'floppy/_wget.cmd')
    add_floppies = appendFile(add_floppies, 'floppy/_unzip.cmd')

  if copy_all_scripts:
    for script in copy__scripts:
      script = 'script/' + script
      dest = os.path.dirname(script) + '/_' + os.path.basename(script)
      shutil.copyfile(script, dest)
      ff = appendFile(ff, dest)

    for script in copy_scripts:
      script = 'script/' + script
      ff = appendFile(ff, script)

    if test_all_scripts:
      ff = appendFile(ff, 'floppy/_email.cmd') # @TODO

  if test_all_files:
    wget_exe = getProvision('wget.exe', True)
    ff = appendFile(ff, wget_exe)
    tee_exe = getProvision('tee.exe', True)
    ff = appendFile(ff, tee_exe)

  ######################
  # generated flags
  ######################

  if chocolatey:
    add_scripts = append(add_scripts, 'dotnet4.cmd')
    add_scripts = append(add_scripts, 'chocolatey.cmd')
    add_scripts = append(add_scripts, 'install-chocolatey-apps.cmd')

  if test_all_scripts:
    #add_scripts.insert(0, 'enable-rdp.cmd')
    #add_scripts.insert(0, 'regenerate-dotnet-cache.cmd')
    pass

  #if add_debug_log:
  #  scripts.append(debug_cmd)

  if add_ssh_uninstaller:
    if cygwin:
      add_scripts = append(add_scripts, 'uninstall-cygwin.cmd')
    if openssh:
      add_scripts = append(add_scripts, 'uninstall-openssh.cmd')

  if add_debugging:
    add_scripts = append(add_scripts, 'dump-logs.cmd')
    add_scripts = append(add_scripts, 'save-logs.cmd')
    add_scripts = append(add_scripts, 'save-temp-dirs.cmd')

  if clean:
    add_scripts = append(add_scripts, 'clean.bat')
  if freeze:
    add_scripts = append(add_scripts, 'freeze.cmd')
  if wait:
    add_scripts = append(add_scripts, 'wait.cmd')





  basename = os.path.basename(file)
  basename = basename[:-5]

  vm_name = ''
  for i, a in enumerate(json_data['builders']):
    if basename != a['vm_name']:
      print("vm_name mismatch!: found %s, expecting %s (filename)" % (basename, a['vm_name']))
      sys.exit(1)
    if vm_name == '':
      vm_name = a['vm_name']
      continue
    if vm_name != a['vm_name']:
      print("vm_name mismatch!: found %s, expecting %s (builder %s)" % (vm_name, a['vm_name'], a['type']))
      sys.exit(1)
    json_data['variables']['vm_name'] = vm_name # @TODO FIXME

  for key, d in user_vars.items():
    for i, old_value in enumerate(json_data[key]):
      for k, v in d.items():
        json_data[key][i][k] = v

  for i, d in enumerate(json_data['builders']):
    if re.search('parallels', d['type']):
      for k, v in parallels_vars.items():
        json_data['builders'][i][k] = v

    if re.search('virtualbox', d['type']):
      for k, v in virtualbox_vars.items():
        json_data['builders'][i][k] = v

    if re.search('vmware', d['type']):
      for k, v in vmware_vars.items():
        if type(v).__name__ == 'dict':
          d2 = dict(json_data['builders'][i][k])
          d2.update(v)
          json_data['builders'][i][k] = d2
        else:
          json_data['builders'][i][k] = v

  for i, a in enumerate(json_data['builders']):
    if re.search('^(parallels|virtualbox|vmware)\-', a['type']):
      #if keep_failed_build:
      #  a['keep_failed_build'] = True

      if add_output_directory:
        a['output_directory'] = 'output-%s_%s' % (a['type'], a['vm_name'])
      if shutdown_seconds > 0:
        a['shutdown_timeout'] = '%ds' % shutdown_seconds
        if cygwin or openssh:
          a['ssh_wait_timeout'] = '%ds' % timeout_seconds
      #if add_shutdown_command:
      #  a['shutdown_command'] = shutdown_command

      if add_ssh_uninstaller:
        del a['shutdown_timeout']
        #del a['shutdown_command']
        #a['shutdown_command'] = 'choice /C Y /N /T %d /D Y /M "Waiting %s seconds"' % (shutdown_seconds, shutdown_seconds)

      if add_http_directory:
        a['http_directory'] = 'floppy'

      #ff = dict.fromkeys(a['floppy_files'], True)

      ff = a['floppy_files']

      autounattend = ''

      for j, f in enumerate(ff):
        if re.search('Autounattend\.xml', f, re.I):
          if autounattend == '':
            autounattend = f
            json_data['variables']['autounattend'] = f
            ff[j] = '{{ user `autounattend` }}'
            continue
          if autounattend != f:
            print('autounattend mismatch! found %s, expected %s, builder %d' % (f, autounattend, i))
            sys.exit(1)

      for script in remove_floppies:
        for j, f in enumerate(ff):
          if re.search('/' + script, f, re.I):
            ff = remove(ff, f)

      for script in add_floppies:
        ff = appendFile(ff, 'floppy/' + script)

      #ff = ff.keys()

      ff = sorted(ff)

      a['floppy_files'] = ff

    if re.search('^vmware\-', a['type']):
      for regex, guest_os_type in vmware_guest_os_types.items():
        if re.search(regex, file, re.I):
          #a['guest_os_type'] = guest_os_type
          json_data['variables']['guest_os_type_vmware'] = guest_os_type
          a['guest_os_type'] = '{{ user `guest_os_type_vmware` }}'
          break

      # to turn off to see if Cygwin is failing because of this
      if winrm or add_ssh_uninstaller:
        # buggy with winrm
        if remove_tools_upload_flavor:
          if 'tools_upload_flavor' in a:
            del a['tools_upload_flavor']

      if add_disk_type_id:
        a['disk_type_id'] = "0"
      if add_skip_compaction:
        a['skip_compaction'] = optimize_for_speed

      if winrm:
        a['communicator'] = 'winrm'
        #a['winrm_username'] = 'vagrant'
        #a['winrm_password'] = 'vagrant'
        #if timeout_seconds > 0:
        #  a['winrm_timeout'] = '%ds' % timeout_seconds

      if remove_tools_upload_flavor:
        if 'tools_upload_flavor' in a:
          del a['tools_upload_flavor']

      if add_vmx_data:
        if not 'vmx_data' in a:
          a['vmx_data'] = {}

      if vmware_version > 0:
        a['version'] = str(vmware_version)

      if add_shared_folders:
        a['vmx_data']['sharedFolder.maxNum'] = '1'
        a['vmx_data']['sharedFolder0.enabled'] = 'TRUE'
        a['vmx_data']['sharedFolder0.expiration'] = 'never'
        a['vmx_data']['sharedFolder0.guestName'] = 'C'
        a['vmx_data']['sharedFolder0.hostPath'] = 'C:\\'
        a['vmx_data']['sharedFolder0.present'] = 'TRUE'
        a['vmx_data']['sharedFolder0.readAccess'] = 'TRUE'
        a['vmx_data']['sharedFolder0.writeAccess'] = 'TRUE'
        a['vmx_data']['hgfs.maprootshare'] = 'TRUE'

      if add_sound_drivers:
        a['vmx_data']['sound.autodetect'] = 'TRUE'
        a['vmx_data']['sound.filename'] = '-1'
        #a['vmx_data']['sound.pciSlotNumber'] = '32'
        a['vmx_data']['sound.present'] = 'TRUE'
        a['vmx_data']['sound.startconnected'] = 'TRUE'
        a['vmx_data']['sound.virtualdev'] = 'hdaudio'

      if attach_provisions_iso:
        provisions_iso = getProvision('provisions.iso')
        if not os.path.exists(provisions_iso):
          print("File not found: %s" % provisions_iso)

        a['vmx_data']['ide1:1.deviceType'] = 'cdrom-image'
        a['vmx_data']['ide1:1.fileName'] = provisions_iso
        a['vmx_data']['ide1:1.present'] = 'TRUE'
        a['vmx_data']['ide1:1.startConnected'] = 'TRUE'

      if attach_vmware_tools_iso:
        windows_iso = ''

        for dir in ['Program Files (x86)', 'Program Files']:
          s = 'C:/%s/VMware/VMware Workstation/windows.iso' % (dir)
          if os.path.isfile(s):
            windows_iso = s

        if not os.path.exists(windows_iso):
          print("File not found: '%s' (windows.iso)" % windows_iso)
        a['vmx_data']['scsi0:1.present'] = 'TRUE'
        a['vmx_data']['scsi0:1.deviceType'] = 'cdrom-image'
        a['vmx_data']['scsi0:1.fileName'] = windows_iso

      if vmx_data_post:
        if not 'vmx_data_post' in a:
          a['vmx_data_post'] = {}

        a['vmx_data_post']['ethernet0.virtualDev'] = 'vmxnet3'
        a['vmx_data_post']['RemoteDisplay.vnc.enabled'] = 'false'
        a['vmx_data_post']['RemoteDisplay.vnc.port'] = '5900'
        a['vmx_data_post']['scsi0.virtualDev'] = 'lsisas1068'

    if re.search('^virtualbox\-', a['type']):
      if guest_additions_mode > '':
        a['guest_additions_mode'] = guest_additions_mode

      for regex, guest_os_type in vbox_guest_os_types.items():
        if re.search(regex, file, re.I):
          #a['guest_os_type'] = guest_os_type
          json_data['variables']['guest_os_type_virtualbox'] = guest_os_type
          a['guest_os_type'] = '{{ user `guest_os_type_virtualbox` }}'
          break

      if add_vboxmanage:
        if not 'vboxmanage' in a:
          a['vboxmanage'] = []

      if attach_provisions_iso:
        provisions_iso = getProvision('provisions.iso')

        if not os.path.exists(provisions_iso):
          print("File not found: '%s'" % provisions_iso)

        a['vboxmanage'].append(vboxStorageAttach(provisions_iso, "1"))

      if attach_vboxguestadditions_iso:
        vboxguestadditions_iso = getVboxGuestAdditionsISO()

        if not os.path.exists(vboxguestadditions_iso):
          print("File not found: '%s'" % vboxguestadditions_iso)

        # a['guest_additions_url'] = vboxguestadditions_iso
        a['vboxmanage'].append(vboxStorageAttach(vboxguestadditions_iso, "0"))

    if re.search('^parallels\-', a['type']):
      json_data['variables']['guest_os_type_parallels'] = a['guest_os_type']
      a['guest_os_type'] = '{{ user `guest_os_type_parallels` }}'

  #for i, a in enumerate(json_data['builders']):
  #  if not 'name' in a:
  #    a['name'] = vm_name + '-' + a['type']

  for i in json_data['post-processors']:
    if i['type'] == 'vagrant':
      if add_keep_input_artifact:
        i['keep_input_artifact'] = True
      i['compression_level'] = compression_level
      #if winrm:
      #  i['output'] = 'winrm-' + i['output']

  packer_debug_env = 'PACKER_DEBUG=1'

  if add_shell_command:
    env_vars = [
      "CM={{ user `cm` }}",
      "CM_VERSION={{ user `cm_version` }}",
    ]

    if set_packer_debug:
      env_vars.append(packer_debug_env)

    debug_step = {
      "environment_vars": env_vars,
      "script": 'floppy/zzz-debug-log.cmd',
      "type": "shell",
    }

    json_data['provisioners'].insert(0, debug_step)

  for i, a in enumerate(json_data['provisioners']):
    if not a['type'] in ['shell', 'windows-shell']:
      continue

    if winrm:
      # use winrm defaults
      if 'remote_path' in a:
        del a['remote_path']
      if 'execute_command' in a:
        del a['execute_command']

      if a['type'] != 'windows-shell':
        a['guest_os_type'] = 'windows'

    if 'inline' in a:
      if winrm or add_ssh_uninstaller:
        if re.search('^rm ', a['inline'][0]):
          del json_data['provisioners'][i]
      continue

    #if winrm:
    if add_binary:
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
    for j in a['scripts']:
      for script in remove_scripts:
        if re.search('/' + script, j, re.I):
          j = ''
          break

      for script in add_scripts:
        if re.search('/' + script, j, re.I):
          j = ''
          break

      if j:
        scripts.append(j)

    for script in add_scripts:
      scripts = appendFile(scripts, 'script/' + script)

    a['scripts'] = scripts

  if add_shutdown_command:
    if 'variables' in json_data:
      json_data['variables']['shutdown_command'] = shutdown_command

  if 'variables' in json_data:
    json_data['variables']['cm'] = 'nocm'
    json_data['variables']['disk_size'] = str(disk_size)
    json_data['variables']['version'] = '1.0.5'

    #if 'update' in json_data['variables']:
    #  del(json_data['variables']['update'])

    json_data['variables']['compression_level'] = str(compression_level)
    json_data['variables']['cores'] = '1'
    json_data['variables']['cpus'] = str(cpus)
    #json_data['variables']['guest_os_type_parallels'] = 'win-8.1' # @TODO FIXME
    #json_data['variables']['guest_os_type_virtualbox'] = 'Windows10_64' # @TODO FIXME
    #json_data['variables']['guest_os_type_vmware'] = 'windows9-64' # @TODO FIXME
    json_data['variables']['iso_checksum_type'] = 'sha1'
    #json_data['variables']['keep_input_artifact'] = False
    json_data['variables']['memsize'] = str(memsize)
    json_data['variables']['skip_compaction'] = 'True'
    json_data['variables']['winrm_password'] = winrm_password
    json_data['variables']['winrm_timeout'] = winrm_timeout
    json_data['variables']['winrm_username'] = winrm_username

  new_data = json_data

  mtime = os.path.getmtime(file)

  new_data  = json.dumps(new_data, sort_keys=True, indent=2, separators=(',', ': '))

  json_file.close()

  json_file = open(file, 'wb')
  json_file.write(new_data)
  json_file.close()

  touch(file, mtime)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.json')

rv = main(sys.argv[1])
sys.exit(rv)
