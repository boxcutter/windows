#!/bin/bash -eux

box_path=$1
box_provider=$2
vagrant_provider=$3

box_filename=$(basename "${box_path}")
box_name=${box_filename%.*}
tmp_path=/tmp/boxtest

rm -rf ${tmp_path}

vagrant box remove ${box_name} --provider ${box_provider} || true
vagrant box add ${box_name} ${box_path}
mkdir -p ${tmp_path}

pushd ${tmp_path}
vagrant init ${box_name}
VAGRANT_LOG=warn vagrant up --provider ${vagrant_provider}
vagrant ssh
vagrant destroy -f
popd

vagrant box remove ${box_name} --provider ${box_provider}
