#!/bin/bash

jsons="
eval-win10x64-enterprise.json
eval-win10x86-enterprise.json
eval-win2008r2-datacenter.json
eval-win2008r2-standard.json
eval-win2012r2-datacenter.json
eval-win2012r2-standard.json
eval-win2016-core.json
eval-win2016-datacenter.json
eval-win7x64-enterprise.json
eval-win7x86-enterprise.json
eval-win81x64-enterprise.json
eval-win81x86-enterprise.json
eval-win8x64-enterprise.json
win2008r2-datacenter.json
win2008r2-enterprise.json
win2008r2-standard.json
win2008r2-web.json
win2012-datacenter.json
win2012r2-datacenter.json
win2012r2-standard.json
win2012r2-standardcore.json
win2012-standard.json
win7x64-enterprise.json
win7x64-pro.json
win7x86-enterprise.json
win7x86-pro.json
win81x64-enterprise.json
win81x64-pro.json
win81x86-enterprise.json
win81x86-pro.json
win8x64-enterprise.json
win8x64-pro.json
win8x86-enterprise.json
win8x86-pro.json
"

template='win7x64-pro.json'

set -e

mkdir -p tmp/json

for json in $jsons; do
	if [[ ! -f $json ]]; then
		continue
	fi
	if [[ $json = $template ]]; then
		continue
	fi
	diff=$(basename $template .json)-$(basename $json .json).diff
	echo py bin/diff-json.py $template $json \>tmp/json/$diff
	py bin/diff-json.py $template $json >tmp/json/$diff
done

for template in $jsons; do
	if [[ ! -f $template ]]; then
		continue
	fi
	base=$(basename $template .json)
	json=$base-cygwin.json
	if [[ -f $json ]]; then
		diff=$(basename $template .json)-$(basename $json .json).diff
		echo py bin/diff-json.py $template $json \>tmp/json/diff
		py bin/diff-json.py $template $json >tmp/json/$diff
	fi
	json=$base-ssh.json
	if [[ -f $json ]]; then
		diff=$(basename $template .json)-$(basename $json .json).diff
		echo py bin/diff-json.py $template $json \>tmp/json/$diff
		py bin/diff-json.py $template $json >tmp/json/$diff
	fi
done

