#!/usr/bin/env python

from __future__ import print_function

import json
import os
import sys

def touch(filename, mtime):
  with open(filename, 'ab+'):
    pass
  os.utime(filename, (mtime, mtime))
  return 0

def main(file):
  print('Updating', file)

  mtime = os.path.getmtime(file)

  with open(file, 'rb') as f:
    json_data = json.load(f)

  new_data = json.dumps(json_data, sort_keys=True, indent=2)
  with open(file, 'wb') as f:
    f.write(new_data)

  touch(file, mtime)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.json')

rv = main(sys.argv[1])
sys.exit(rv)
