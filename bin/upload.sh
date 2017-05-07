#!/bin/bash -eux

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

VBOX_VERSION=$(vboxmanage --version)
# vboxmanage returns string in the form of 4.3.12r93733, just get x.y.z part
VBOX_GUEST_ADDITIONS_VERSION="${VBOX_VERSION%%r*}"

# TODO: Parse vmware-vmx output
#VMWARE_FUSION_APP_PATH="/Applications/VMware Fusion.app"
#VMWARE_VMX="${VMWARE_FUSION_APP_PATH}/Contents/Library/vmware-vmx"
#cmd=("${VMWARE_VMX}" -v)
#VMWARE_VMX_VERSION=$(("${cmd[@]}") 2>&1)
VMWARE_TOOLS_VERSION="9.6.2"

S3_GRANTS="--grants full=id=${S3_CANONICAL_ID} read=uri=http://acs.amazonaws.com/groups/global/AllUsers"
S3_BUCKET_PATH_VMWARE="s3://box-cutter-us-east-1-cloudtrail/windows/vmware${VMWARE_TOOLS_VERSION}/"
cmd="aws s3 sync ${DIR}/box/vmware/ ${S3_BUCKET_PATH_VMWARE} ${S3_GRANTS}"
echo ${cmd}
${cmd}
S3_BUCKET_PATH_VIRTUALBOX="s3://box-cutter-us-east-1-cloudtrail/windows/virtualbox${VBOX_GUEST_ADDITIONS_VERSION}/"
cmd="aws s3 sync ${DIR}/box/virtualbox/ ${S3_BUCKET_PATH_VIRTUALBOX} ${S3_GRANTS}"
echo ${cmd}
${cmd}


S3_BUCKET_PATH_VMWARE="s3://box-cutter-us-west-2-cloudtrail/windows/vmware${VMWARE_TOOLS_VERSION}/"
cmd="aws s3 sync ${DIR}/box/vmware/ ${S3_BUCKET_PATH_VMWARE} ${S3_GRANTS}"
echo ${cmd}
${cmd}
S3_BUCKET_PATH_VIRTUALBOX="s3://box-cutter-us-west-2-cloudtrail/windows/virtualbox${VBOX_GUEST_ADDITIONS_VERSION}/"
cmd="aws s3 sync ${DIR}/box/virtualbox/ ${S3_BUCKET_PATH_VIRTUALBOX} ${S3_GRANTS}"
echo ${cmd}
${cmd}
