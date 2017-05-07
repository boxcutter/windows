#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
	SCRIPT_DIR="$(cygpath -m "${SCRIPT_DIR}")"
  PYTHON=py
fi

XMLS=$(find floppy -maxdepth 2 -type f -name '*.xml')

for xml in ${XMLS}; do
  ${PYTHON} "${SCRIPT_DIR}/update-xml.py" $xml
done
