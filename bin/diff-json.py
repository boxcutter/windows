#!/usr/bin/env python

from __future__ import print_function

import json
import os
import re
import sys
import pprint

keys_to_ignore = {
  'communicator': '',
  'guest_os_type': '',
  'iso_checksum': '',
  'iso_url': '',
  'ssh_password': '',
  'ssh_username': '',
  'ssh_wait_timeout': '',
  'winrm_password': '',
  'winrm_timeout': '',
  'winrm_username': '',
}

def p(v):
  v = pprint.pformat(v)
  v = re.sub('[ \r\n]+', ' ', v)
  v = re.sub(", ", ",", v)
  v = re.sub("u'", "'", v)
  return v

def q(v):
  t = type(v).__name__
  if t == 'bool':
    return 'true' if v else 'false'
  if t == 'int':
    return str(v)
  if t == 'str':
    return "'" + v + "'"
  if t == 'unicode':
    return "'" + v + "'"
  if t == 'dict':
    return p(v)
  if t == 'list':
    return p(v)
  print('Unknown type: %s' % t)
  sys.exit(1)

def head(emit, prefix):
  if emit:
    print("\n" + prefix)
  return False

def diffDict(prefix, l1, l2, f1, f2):
  _diffDict(prefix, l1, l2, f1, f2, False)
  _diffDict(prefix, l1, l2, f1, f2, True)

def _diffDict(prefix, l1, l2, f1, f2, lists):
  emit = True
  keys = l1.keys()
  for k in l2.keys():
    if not k in keys:
      keys.append(k)
  #for k in keys_to_ignore:
  #  if k in keys:
  #    keys.remove(k)
  keys = sorted(keys)
  for k1 in keys:
    if k1 in keys_to_ignore:
      continue
    if k1 in l1:
      v1 = l1[k1]
      t1 = type(v1).__name__
      if not k1 in l2:
        if lists:
          continue
        emit = line(prefix, k1, q(v1), '', emit)
        continue

      v2 = l2[k1]
      if t1 == 'dict':
        if not lists:
          continue
        if diffDict(prefix + '/' + str(k1), v1, v2, f1, f2):
            print("")
        continue
      elif t1 == 'list':
        if not lists:
          continue
        if k1 == 'floppy_files':
          if diffListValues(prefix + '/' + str(k1), v1, v2, f1, f2):
            print("")
        else:
          if diffList(prefix + '/' + str(k1), v1, v2, f1, f2):
            print("")
        continue
      else:
        if v1 == v2:
          continue

        if re.sub(f1, '', v1) == re.sub(f2, '', v2):
          continue

        if lists:
          continue
        emit = line(prefix, k1, q(v1), q(v2), emit)

    else:
      v2 = l2[k1]
      if lists:
        continue
      emit = line(prefix, k1, '', q(v2), emit)

  return not emit

def diffList(prefix, l1, l2, f1, f2):
  mask = getMask()

  emit = True
  for k1, v1 in enumerate(l1):
    t1 = type(v1).__name__
    if k1 >= len(l2):
      emit = head(emit, prefix)
      print(mask % (k1, q(v1), ''))
      continue

    v2 = l2[k1]
    if t1 == 'dict':
      diffDict(prefix + '/' + str(k1), v1, v2, f1, f2)
      continue
    elif t1 == 'list':
      diffList(prefix + '/' + str(k1), v1, v2, f1, f2)
      continue
    elif v1 == v2:
      continue
    if re.sub(f1, '', v1) == re.sub(f2, '', v2):
      continue

    emit = head(emit, prefix)
    print(mask % (k1, q(v1), q(v2)))

  for k2, v2 in enumerate(l2):
    if k2 >= len(l1):
      emit = head(emit, prefix)
      print(mask % (k2, '', q(v2)))

  return not emit

def arrayToDict(l):
  d = {}
  for k, v in enumerate(l):
    d[v] = v
  return d

def diffListValues(prefix, l1, l2, f1, f2):
  l1 = arrayToDict(l1)
  l2 = arrayToDict(l2)
  return diffDict(prefix, l1, l2, f1, f2)

def getMask():
  return '  %-25s %-35s %-35s'

def line(prefix, k, q1, q2, emit):
  mask = getMask()
  emit = head(emit, prefix)
  print(mask % (k, q1, q2))
  return emit

def main(file1, file2):
  mask = getMask()

  d1 = json.load(open(file1, 'rb'))
  d2 = json.load(open(file2, 'rb'))

  f1 = os.path.basename(file1)
  f2 = os.path.basename(file2)

  f1 = f1[:-5]
  f2 = f2[:-5]

  builders1 = d1['builders']
  builders2 = d2['builders']

  for i1, builder1 in enumerate(builders1):
    builder2 = builders2[i1]
    #if not builder1['type'] == builder2['type']:
    #  print("\nbuilder/type: %s != %s\n" % (builder1['type'], builder2['type']))
    #  continue

    diffDict('builders/' + builder1['type'], builder1, builder2, f1, f2)

  processors1 = d1['post-processors']
  processors2 = d2['post-processors']

  for i1, processor1 in enumerate(processors1):
    processor2 = processors2[i1]
    #if not processor1['type'] == processor2['type']:
    #  print("\nprocessor/type: %s != %s\n" % (processor1['type'], processor2['type']))
    #  continue

    diffDict('post-processors/' + processor1['type'], processor1, processor2, f1, f2)

  provisioners1 = d1['provisioners']
  provisioners2 = d2['provisioners']

  for i1, provisioner1 in enumerate(provisioners1):
    provisioner2 = provisioners2[i1]
    #if not provisioner1['type'] == provisioner2['type']:
    #  print("\nprovisioner/type: %s != %s\n" % (provisioner1['type'], provisioner2['type']))
    #  continue

    diffDict('provisioners/' + provisioner1['type'], provisioner1, provisioner2, f1, f2)

  diffDict('variables', d1['variables'], d2['variables'], f1, f2)
  return 0

if len(sys.argv) < 3:
  sys.exit('Usage: ' + os.path.basename(sys.argv[0]) + ' filename1.json filename2.json')

rv = main(sys.argv[1], sys.argv[2])
sys.exit(rv)
