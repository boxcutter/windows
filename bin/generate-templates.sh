#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
	SCRIPT_DIR="$(cygpath -m "${SCRIPT_DIR}")"
  PYTHON=py
fi

JSONS=$(find ${SCRIPT_DIR}/.. -maxdepth 1 -type f -name '*.json')

for json in ${JSONS}; do
  ${PYTHON} "${SCRIPT_DIR}/generate-template.py" ${json}
done
