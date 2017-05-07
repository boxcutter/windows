#!/usr/bin/env python

from __future__ import print_function

import json
import os
import re
import sys

def touch(file, mtime):
  with open(file, 'a+'):
    pass
  os.utime(file, (mtime, mtime))
  return 0

def main(file, compression_level):
  mtime = os.path.getmtime(file)

  fh = open(file, 'rb+')
  json_data = json.load(fh)

  for i, a in enumerate(json_data['builders']):
    if re.search('^vmware\-', a['type']):
      a['disk_type_id'] = "0"
      a['skip_compaction'] = compression_level == 0

  for i in json_data['post-processors']:
    if i['type'] == 'vagrant':
      i['compression_level'] = compression_level

  json_data = json.dumps(json_data, sort_keys=True, indent=2)

  fh.seek(0)
  fh.write(json_data)
  fh.close()

  touch(file, mtime)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' file.json [compression_level]')

if len(sys.argv) >= 2:
  compression_level = int(sys.argv[2])
else:
  compression_level = 9

