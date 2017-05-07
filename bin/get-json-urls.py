#!/usr/bin/env python

from __future__ import print_function

import json
import os
import sys

def main(file):
  d = json.load(open(file, 'rb'))

  url = ''
  checksum = ''
  if 'iso_url' in d['variables']:
    url = d['variables']['iso_url']
  if 'iso_checksum' in d['variables']:
    checksum = d['variables']['iso_checksum']

  print("%s\t%s\t%s", sys.argv[1], url, checksum)
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.json')

rv = main(sys.argv[1])
sys.exit(rv)
