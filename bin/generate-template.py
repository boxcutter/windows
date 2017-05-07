#!/usr/bin/env python

from __future__ import print_function

import datetime
import os
import re
import sys

def main(file):
  suffix = open('suffix.cmd').readlines()

  basename = os.path.basename(file)
  basename = basename[:-5]

  template = 'tpl/template.tpl'

  filename = 'tpl/vagrantfile-' + basename + '.tpl'
  filename_tmp = filename + '.tmp'
  filename_bak = filename + '.bak'

  print("Updating %s" % (filename))

  f = open(template, 'rb')
  lines = f.readlines()
  f.close()

  f = open(filename_tmp, 'wb')

  yyyymmdd = datetime.datetime.strftime(datetime.datetime.today(), '%Y-%m-%d')
  hhmmss = datetime.datetime.strftime(datetime.datetime.today(), '%H:%M:%S')

  f.write("#Generated from %s on %s %s.\n#If you edit this file, your changes may be overwritten.\n" % (template, yyyymmdd, hhmmss))

  sshforward = "# Port forward SSH\n  config.vm.network :forwarded_port, guest: 22, host: 2222, id: \"ssh\", auto_correct:true"
  nosshforward = "# Port forward SSH\n  #config.vm.network :forwarded_port, guest: 22, host: 2222, id: \"ssh\", auto_correct:true"

  for line in lines:
    if re.search('\$name', line):
      line = re.sub('\$name', basename, line)

    if re.search('\$sshforward', line):
      if re.search('(cygwin|ssh)', basename):
        line = re.sub('\$sshforward', sshforward, line)
      else:
        line = re.sub('\$sshforward', nosshforward, line)

    f.write(line)

  f.close()

  if os.path.exists(filename_bak):
    os.remove(filename_bak)
  if os.path.exists(filename):
    os.rename(filename, filename_bak)
  os.rename(filename_tmp, filename)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.json')

rv = main(sys.argv[1])
sys.exit(rv)
