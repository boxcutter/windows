import json
import os
import re
import sys

def touch(filename, mtime):
  with open(filename, 'a+'):
    pass
  os.utime(filename, (mtime, mtime))
  return 0

if len(sys.argv) < 2:
  sys.exit('Usage: ' + sys.argv[0] + ' filename.json')

if len(sys.argv) >= 2:
  compression_level = int(sys.argv[2])
else:
  compression_level = 9

filename = sys.argv[1]

mtime = os.path.getmtime(filename)

fh = open(filename, 'r+')
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

touch(filename, mtime)
