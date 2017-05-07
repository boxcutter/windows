#!/usr/bin/env python

from __future__ import print_function

import os
import re
import sys

def main(file):
  print("Updating %s" % (file))

  file_tmp = file + '.tmp'
  file_bak = file + '.bak'

  f = open(file)
  lines = f.readlines()
  f.close()

  f = open(file_tmp, 'w')

  flag = 0

  for line in lines:
    if flag == 0:
      if re.search('^\s*:exit\s*$', line):
        f.write(line)
        flag = 1

    if flag == 1:
      if re.search('^\s*--->\s*$', line):
        flag = 2

    if flag != 1:
      f.write(line)

  f.close()

  if os.path.exists(file_bak):
    os.remove(file_bak)
  os.rename(file, file_bak)
  os.rename(file_tmp, file)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.cmd')

rv = main(sys.argv[1])
sys.exit(rv)
