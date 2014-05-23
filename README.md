# Packer templates for Windows
[![Build Status](https://box-cutter.ci.cloudbees.com/buildStatus/icon?job=windows-core-nocm)](https://box-cutter.ci.cloudbees.com/job/windows-core-nocm)

### Overview

This repository contains templates for Windows that can create
Vagrant boxes using Packer.

## Current Boxes

64-bit boxes:

* win8x64-enterprise, VMware 3.6GB/VirtualBox 3.3GB
* win8x64-enterprise-cygwin, VMWare 3.5GB/VirtualBox 3.3GB
* win8x64-pro, VMWare 3.6GB/VirtualBox 3.4GB
* win8x64-pro-cygwin, VMWare 3.6GB/VirtualBox 3.4GB
* win7x64-enterprise, VMWare 3.5GB/VirtualBox 3.2GB
* win7x64-enterprise-cygwin, VMWare 3.5GB/VirtualBox 3.3GB
* win7x64-pro, VMware 3.5GB/VirtualBox 3.2GB
* win7x64-pro-cygwin, VMware 3.5GB/VirtualBox 3.3GB


32-bit boxes:

* win8x86-enterprise, VMware 2.6GB/VirtualBox 2.4GB
* win8x86-enterprise-cygwin, VMware 2.6GB/VirtualBox  2.4GB
* win8x86-pro, VMware 2.6GB/VirtualBox 2.4GB
* win8x86-pro-cygwin, VMware 2.6GB/VirtualBox 2.4GB
* win7x86-enterprise, VMWare 2.5GB/VirtualBox 2.4GB
* win7x86-enterprise-cygwin, VMWare 2.5GB/VirtualBox 2.4GB
* win7x86-pro, VMware 2.5GB/VirtualBox 2.4GB
* win7x86-pro-cygwin, VMware 2.6GB/VirtualBox 2.4GB
 

## Building the Vagrant boxes

To build all the boxes, you will need both VirtualBox and VMware Fusion installed.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all the box types (VirtualBox & VMware)
    make test   # Run tests against all the boxes
    make list   # Print out individual targets
    make clean  # Clean up build detritus
    
### Tests

The tests are written in [Serverspec](http://serverspec.org) and require the
`vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec
    
The `Makefile` has individual targets for each box type with the prefix
`test-*` should you wish to run tests individually for each box.

Similarly there are targets with the prefix `ssh-*` for registering a
newly-built box with vagrant and for logging in using just one command to
do exploratory testing.  For example, to do exploratory testing
on the VirtualBox training environmnet, run the following command:

    make ssh-box/virtualbox/win2008r2-standard-nocm.box
    
Upon logout `make ssh-*` will automatically de-register the box as well.

### Makefile.local override

You can create a `Makefile.local` file alongside the `Makefile` to override
some of the default settings.  It is most commonly used to override the
default configuration management tool, for example with Chef:

    # Makefile.local
    CM := chef

Changing the value of the `CM` variable changes the target suffixes for
the output of `make list` accordingly.

Possible values for the CM variable are:

* `nocm` - No configuration management tool
* `chef` - Install Chef
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 11.12.4`

Another use for `Makefile.local` is to override the default locations
for the Windows install ISO files.

For Windows, the ISO path variables are:

* `WIN2008R2_X64`
* `WIN2012_X64`
* `WIN2012R2_X64`
* `WIN7_X64_ENTERPRISE`
* `WIN7_X64_PRO`
* `WIN7_X86_ENTERPRISE`
* `WIN7_X86_PRO`
* `WIN8_X64_ENTERPRISE`
* `WIN8_X86_ENTERPRISE`
* `WIN8_X64_PRO`
* `WIN8_X86_PRO`
* `WIN81_X64_ENTERPRISE`
* `WIN81_X64_PRO`

You can also override these setting, such as with
`WIN81_X64_PRO := file:///Volumes/MSDN/en_windows_8.1_professional_vl_with_update_x64_dvd_4065194.iso

### Acknowledgments

[CloudBees](http://www.cloudbees.com) is providing a hosted [Jenkins master](http://box-cutter.ci.cloudbees.com/) through their CloudBees FOSS program. Their [On-Premise Executor](https://developer.cloudbees.com/bin/view/DEV/On-Premise+Executors) feature is used to connect physical machines as build slaves running VirtualBox, VMware Fusion, VMware Workstation, VMware ESXi/vSphere and Hyper-V.

![Powered By CloudBees](http://www.cloudbees.com/sites/default/files/Button-Powered-by-CB.png "Powered By CloudBees")![Built On DEV@Cloud](http://www.cloudbees.com/sites/default/files/Button-Built-on-CB-1.png "Built On DEV@Cloud")

