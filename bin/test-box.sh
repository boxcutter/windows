#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-vmware_desktop}
BOX_PROVIDER=${BOX_PROVIDER:-vmware_fusion}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/vmware}
BOX_SUFFIX=${BOX_SUFFIX:-$CM.box}

#set VAGRANT_LOG=debug

test_box() {
    box_path=$1
    box_filename=$(basename "$box_path")
    box_name=${box_filename%.*}
    box_provider=$2
    tmp_path=/tmp/boxtest
    src_path=$(pwd)

    rm -rf $tmp_path

    vagrant box remove $box_name --provider $VAGRANT_PROVIDER || true
    vagrant box add $box_name $box_path
    mkdir -p $tmp_path
    
    pushd $tmp_path
cat << EOF > $tmp_path/Vagrantfile
Vagrant.configure('2') do |config|
config.vm.box = '$box_name'

config.vm.provision :serverspec do |spec|
spec.pattern = '$src_path/test/*_spec.rb'
end
end
EOF
    #VAGRANT_LOG=debug vagrant up --provider $box_provider
    VAGRANT_LOG=warn vagrant up --provider $box_provider
    sleep 10
    VAGRANT_LOG=warn vagrant destroy -f 
    popd
   
    vagrant box remove $box_name --provider $VAGRANT_PROVIDER
}
