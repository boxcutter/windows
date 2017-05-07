#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
	SCRIPT_DIR="$(cygpath -m "${SCRIPT_DIR}")"
  PYTHON=py
fi

SCRIPTS=$(find floppy script -type f \( -name '*.bat' -o -name '*.cmd' \))

for script in ${SCRIPTS}; do
  ${PYTHON} "${SCRIPT_DIR}/remove-suffix.py" $script
done
