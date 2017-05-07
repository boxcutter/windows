#!/usr/bin/env python

from __future__ import print_function

import json
import os
import shutil
import sys
#import time

def touch(filename, mtime):
  with open(filename, 'a+'):
    pass
  os.utime(filename, (mtime, mtime))
  return 0

def touch_by_file(filename, touch_filename):
  touch(filename, os.path.getmtime(touch_filename))

def main(file):
  orig = file + '.orig'
  print('Updating ' + file)

  if not os.path.isfile(orig):
    mtime = os.path.getmtime(file)
    shutil.copyfile(file, orig)
    touch(orig, mtime)

  json_file = open(orig, 'rb')
  json_data = json.load(json_file)

  for i, a in enumerate(json_data['builders']):
    floppy_files = dict.fromkeys(a['floppy_files'], True)
    a['floppy_files'] = floppy_files.keys()
    a['floppy_files'].sort()

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
