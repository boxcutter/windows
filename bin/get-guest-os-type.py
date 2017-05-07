#!/usr/bin/env python

from __future__ import print_function

import json
import os
import sys

def main(file):
  with open(file, 'rb') as f:
    json_data = json.load(f)

    for k, a in json_data.items():
      if k == 'builders':
        for i, d in enumerate(a):
          print("%-40s\t%-15s\t%s" % (os.path.basename(file), d['type'], d['guest_os_type']))

  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename.json')

rv = main(sys.argv[1])
sys.exit(rv)
