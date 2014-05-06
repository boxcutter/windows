#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CM=${CM:-chef}
CM_VERSION=${CM_VERSION:-11.12.4}
BUILDER_TYPE=${BUILDER_TYPE:-virtualbox-iso}

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-virtualbox}
BOX_PROVIDER=${BOX_PROVIDER:-virtualbox}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/virtualbox}
BOX_SUFFIX=${BOX_SUFFIX:-$CM$CM_VERSION}.box

source ${DIR}/make-win2012r2.sh
