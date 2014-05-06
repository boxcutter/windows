#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-vmware_desktop}
BOX_PROVIDER=${BOX_PROVIDER:-vmware_fusion}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/vmware}
BOX_SUFFIX=${BOX_SUFFIX:-$PROVISIONER.box}

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
    if [[ "${box_name}" =~ win2012 || "${box_name}" =~ win8 ]]; then
cat << EOF > $tmp_path/Vagrantfile
Vagrant.configure("2") do |config|
config.vm.box = '$box_name'
config.winrm.username = "vagrant"
config.winrm.password = "vagrant"
config.vm.guest = :windows
config.windows.halt_timeout = 15
config.vm.network :forwarded_port, guest: 3389, host: 3389
config.vm.network :forwarded_port, guest: 5985, host: 5985
    config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--memory", 768]
        v.customize ["modifyvm", :id, "--cpus", 1]
        v.customize ["modifyvm", :id, "--vram", "256"]
        v.customize ["setextradata", "global", "GUI/MaxGuestResolution", "any"]
        v.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32"]
    end

    config.vm.provider :vmware_fusion do |v, override|
        v.gui = true
        v.vmx["memsize"] = "768"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsisas1068"
    end

    config.vm.provider :vmware_workstation do |v, override|
        v.gui = true
        v.vmx["memsize"] = "768"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsisas1068"
    end
config.vm.provision :serverspec do |spec|
spec.pattern = '$src_path/test/*_spec.rb'
end
end
EOF
    elif [[ "${box_name}" =~ win ]]; then
cat << EOF > $tmp_path/Vagrantfile
Vagrant.configure('2') do |config|
config.vm.box = '$box_name'
config.winrm.username = "vagrant"
config.winrm.password = "vagrant"
config.vm.guest = :windows
config.windows.halt_timeout = 15
config.vm.network :forwarded_port, guest: 3389, host: 3389
config.vm.network :forwarded_port, guest: 5985, host: 5985
config.vm.provision :serverspec do |spec|
spec.pattern = '$src_path/test/*_spec.rb'
end
config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--memory", 768]
        v.customize ["modifyvm", :id, "--cpus", 1]
        v.customize ["modifyvm", :id, "--vram", "256"]
        v.customize ["setextradata", "global", "GUI/MaxGuestResolution", "any"]
        v.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32"]
end
config.vm.provider :vmware_fusion do |v, override|
        v.gui = true
        v.vmx["memsize"] = "768"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsilogic"
 end
config.vm.provider :vmware_workstation do |v, override|
        v.gui = true
        v.vmx["memsize"] = "768"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsilogic"
    end
config.vm.provision :serverspec do |spec|
spec.pattern = '$src_path/test/*_spec.rb'
end
end
EOF
    else
cat << EOF > $tmp_path/Vagrantfile
Vagrant.configure('2') do |config|
config.vm.box = '$box_name'

config.vm.provision :serverspec do |spec|
spec.pattern = '$src_path/test/*_spec.rb'
end
end
EOF
    fi
    #VAGRANT_LOG=debug vagrant up --provider $box_provider
    VAGRANT_LOG=warn vagrant up --provider $box_provider
    sleep 10
    VAGRANT_LOG=warn vagrant destroy -f 
    popd
   
    vagrant box remove $box_name --provider $VAGRANT_PROVIDER
}
