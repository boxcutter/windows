#!/bin/bash

PYTHON=python

if [[ "${OS}" = "Windows_NT" ]]; then
  PYTHON=py
fi

for i in *.json; do
  ${PYTHON} tweak-json.py $i
done
