#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
	SCRIPT_DIR="$(cygpath -m "${SCRIPT_DIR}")"
  PYTHON=py
fi

JSONS=$(find -maxdepth 1 -type f -name '*.json')

for i in ${JSONS}; do
  ${PYTHON} "${SCRIPT_DIR}/sort-json.py" $i
done
