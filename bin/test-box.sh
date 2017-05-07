#!/bin/bash -eux

create_vagrantfile_linux() {
vagrant plugin list | grep vagrant-serverspec && echo "vagrant-serverspec installed" || vagrant plugin install vagrant-serverspec
cat << EOF > $tmp_path/Vagrantfile
Vagrant.configure('2') do |config|
config.vm.box = '$box_name'

config.vm.provision :serverspec do |spec|
spec.pattern = '$test_src_path'
end
end
EOF
}

box_path=$1
box_provider=$2
vagrant_provider=$3
test_src_path=$4

box_filename=$(basename "${box_path}")
box_name=${box_filename%.*}
tmp_path=/tmp/boxtest

rm -rf ${tmp_path}

vagrant box remove ${box_name} --provider ${box_provider} 2>/dev/null || true
vagrant box add ${box_name} ${box_path}
mkdir -p ${tmp_path}

pushd ${tmp_path}
create_vagrantfile_linux
VAGRANT_LOG=warn vagrant up --provider ${vagrant_provider}
sleep 10
vagrant destroy -f
popd

vagrant box remove ${box_name} --provider ${box_provider}
