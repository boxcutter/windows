#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILDER_TYPE=${BUILDER_TYPE:-vmware-iso}
CM=${CM:-chef}
CM_VERSION=${CM_VERSION:-11.12.4}

if [[ -f iso_url.local.cfg ]]; then
    source ${DIR}/iso_url.local.cfg
else
    source ${DIR}/iso_url.cfg
fi

source ${DIR}/test-box.sh

cleanup()
{
    rm -rf output-$BUILDER_TYPE
    rm -f ~/.ssh/known_hosts
}

pushd ${DIR}/..

#for t in win2008r2-datacenter-cygwin win2008r2-datacenter win2008r2-enterprise-cygwin win2008r2-enterprise win2008r2-standard-cygwin win2008r2-standard win2008r2-web-cygwin win2008r2-web
for t in win2008r2-datacenter
do
    cleanup
    packer build -only=$BUILDER_TYPE -var "iso_url=$WIN2008R2_X64" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
done

cleanup

popd
