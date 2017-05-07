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

  for line in lines:
    newline = re.sub(
      'cmd\.exe /c a:\\\\00-run-all-scripts\.cmd',
      'cmd.exe /e:on /v:on /c a:\\_run-scripts.cmd 2&gt;&amp;1 | a:\\_tee.cmd "%TEMP%\\\\_run-scripts.log"',
      line)

    f.write(newline)

  f.close()

  if os.path.exists(file_bak):
    os.remove(file_bak)
  os.rename(file, file_bak)
  os.rename(file_tmp, file)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' file.xml')

rv = main(sys.argv[1])
sys.exit(rv)
