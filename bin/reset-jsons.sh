#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ORIG_JSONS=$(find ${SCRIPT_DIR}/.. -maxdepth 1 -type f -name '*.json.orig')

if [[ -n "${ORIG_JSONS}" ]]; then
	for orig in ${ORIG_JSONS}; do
		cp -p $orig $(basename $orig .orig)
	done
fi
