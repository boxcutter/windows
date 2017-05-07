#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
	SCRIPT_DIR="$(cygpath -m "${SCRIPT_DIR}")"
  PYTHON=py
fi

FLOPPYS=$(find floppy -type f \( -name '*.bat' -o -name '*.cmd' \))
SCRIPTS=$(find script -type f \( -name '*.bat' -o -name '*.cmd' \))

for script in ${FLOPPYS} ${SCRIPTS}; do
  ${PYTHON} "${SCRIPT_DIR}/update-suffix.py" $script
done
