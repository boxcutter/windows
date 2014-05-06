#!/bin/bash

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

for t in win81x64-enterprise-cygwin win81x64-enterprise
do
    cleanup
    packer build -only=$BUILDER_TYPE -var "iso_url=$WIN81_X64_ENTERPRISE" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
   test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
done

#for t in win81x86-enterprise-cygwin win81x86-enterprise
#do
#    cleanup
#    packer build -only=$BUILDER_TYPE -var "iso_url=$WIN81_X86_ENTERPRISE" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
#    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
#done

for t in win81x64-pro-cygwin win81x64-pro
do
    cleanup
    packer build -only=$BUILDER_TYPE -var "iso_url=$WIN81_X64_PRO" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
done

#for t in win81x86-pro-cygwin win81x86-pro
#do
#    cleanup
#    packer build -only=$BUILDER_TYPE -var "iso_url=$WIN81_X86_PRO" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
#    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
#done

cleanup

popd
