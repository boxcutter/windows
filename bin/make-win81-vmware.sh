#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CM=${CM:-chef}
CM_VERSION=${CM_VERSION:-11.12.4}
BUILDER_TYPE=${BUILDER_TYPE:-vmware-iso}

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-vmware_desktop}
BOX_PROVIDER=${BOX_PROVIDER:-vmware_fusion}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/vmware}
BOX_SUFFIX=${BOX_SUFFIX:-$CM$CM_VERSION}.box

source ${DIR}/make-win81.sh
