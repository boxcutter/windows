#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

XMLS=$(find floppy -mindepth 2 -type f -name '*.xml')

for xml in ${XMLS}; do
	tmp=${xml}.tmp
	bak=${xml}.bak
	echo Canonicalizing ${xml}...
  xml c14n ${xml} >${tmp}
	#rm -f ${bak} 2>nul
	#mv ${xml} ${bak}
	#mv ${tmp} ${xml}
done

mkdir -p tmp/xml

TMPS=$(find floppy -mindepth 2 -type f -name '*.tmp')

for tmp1 in ${TMPS}; do
	for tmp2 in ${TMPS}; do
		if [[ ! $tmp1 > $tmp2 ]]; then
			continue
		fi
		b1=$(basename $(dirname $tmp1))
		b2=$(basename $(dirname $tmp2))
		echo Comparing $b1 to $b2...
		diff -uw $tmp1 $tmp2 >tmp/xml/$b1-$b2.diff || true
	done
done
