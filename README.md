
# Packer templates for Windows

### Overview

This repository contains templates for Windows that can create
Vagrant boxes using Packer.

## Core Boxes

64-bit boxes:

* win2012r2-datacenter-nocm, VMware 4.3GB/VirtualBox 4.2GB
* win2012-datacenter-nocm, VMware 3.7GB/VirtualBox 3.5GB
* win2008r2-datacenter-nocm, VMware 3.0GB/VirtualBox 2.8GB
* win81x64-enterprise-nocm, VMware 4.0GB/VirtualBox 3.6GB
* win8x64-enterprise-nocm, VMware 3.6GB/VirtualBox 3.3GB
* win7x64-enterprise-nocm, VMware 3.5GB/VirtualBox 3.2GB

## Building the Vagrant boxes

To build all the boxes, you will need both VirtualBox and VMware Fusion or Workstation installed.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all the box types (VirtualBox & VMware)
    make test   # Run tests against all the boxes
    make list   # Print out individual targets
    make clean  # Clean up build detritus

To build one particular box, e.g. `eval-win7x86-enterprise`, for just one provider, e.g. VirtualBox, first run `make list` subcommand:
```
make list
```

This command prints the list of available boxes. Then you can build one particular box for choosen provider:
```
make virtualbox/eval-win7x86-enterprise
```

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
* `chef` - Install Chef Client
* `chefdk` - Install Chef Development Kit
* `chef-workstation` - Install Chef Workstation
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION` for all configuration management
tools to override the default of `latest`. The value of `CM_VERSION` should
have the form `x.y` or `x.y.z`, such as `CM_VERSION := 11.12.4`

When changing the value of the `CM` variable to one of the chef-based
configuration management tools, it is relevant to note that recent versions of
chef require a license in order to use. Due to this, specifying the default
version of "latest" for the `CM_VERSION` field will result in using the most
recent "free" version that doesn't require a license. If the user wishes to use
the most recent version that DOES requires licensing, however, the user will
need to explicitly specify "licensed" for `CM_VERSION`. Specifying "licensed"
for `CM_VERSION` will then result in using the most recently available licensed
version. More information on how to accept the chef-client license via
configuration after building a template can be found at
[Accepting the Chef License](https://docs.chef.io/chef_license_accept.html).

It is also possible to specify a `HW_VERSION` if a specific hardware
version is to be used for a build. This is commonly used to provide
compatibility with newer versions of VMware Workstation. For example,
you may indicate version 14 of Workstation: `HW_VERSION := 14`.

For configuration management tools (such as Salt), you can specify a
variable `CM_OPTIONS`. This variable will be passed to the installer for
the configuration management tool. For information on possible values
please read the documentation for the respective configuration management
tool.

Another use for `Makefile.local` is to override the default locations
for the Windows install ISO files.

For Windows, the ISO path variables are:

* `EVAL_WIN10_X64`
* `EVAL_WIN10_X86`
* `EVAL_WIN2008R2_X64`
* `EVAL_WIN2012R2_X64`
* `EVAL_WIN7_X64`
* `EVAL_WIN7_X86`
* `EVAL_WIN81_X64`
* `EVAL_WIN81_X86`
* `EVAL_WIN8_X64`
* `WIN2008R2_X64`
* `WIN2012_X64`
* `WIN2012R2_X64`
* `WIN7_X64_ENTERPRISE`
* `WIN7_X64_PRO`
* `WIN7_X86_ENTERPRISE`
* `WIN7_X86_PRO`
* `WIN81_X64_ENTERPRISE`
* `WIN81_X64_PRO`
* `WIN81_X86_ENTERPRISE`
* `WIN81_X86_PRO`
* `WIN8_X64_ENTERPRISE`
* `WIN8_X64_PRO`
* `WIN8_X86_ENTERPRISE`
* `WIN8_X86_PRO`

You can also override these setting, such as with

    WIN81_X64_PRO := file:///Volumes/MSDN/en_windows_8.1_professional_vl_with_update_x64_dvd_4065194.iso

### Packer Global Configuration

`floppy/_packer_config.cmd` can set configuration globally for initial install and each shell provisioner. See [floppy/_packer_config.cmd](./floppy/_packer_config.cmd) for additional details.

You can add additional `floppy/_packer_config_*.cmd` files.  Thes files will be ignored by Git.

`floppy/_packer_config*.cmd` will be executed in alpabetical order during initial install and at the beginning of each shell provisioner script if the script supports loading them.

#### Proxy Configuration using `floppy/_packer_config_proxy.cmd`

Create a file called `floppy/_packer_config_proxy.cmd` with the below contents:

```
set http_proxy_user=[proxy_user]
set http_proxy_password=[proxy_password]
set ftp_proxy=http://[proxy_host]:[proxy_port]
set http_proxy=http://[proxy_host]:[proxy_port]
set https_proxy=http://[proxy_host]:[proxy_port]
set no_proxy=127.0.0.1,localhost,[no_proxy_hosts]
```

### Acknowledgments

[Parallels](http://www.parallels.com/) provides a Business Edition license of
their software to run on the basebox build farm.

<img src="http://www.parallels.com/fileadmin/images/corporate/brand-assets/images/logo-knockout-on-red.jpg" width="80">

[SmartyStreets](http://www.smartystreets.com) is providing basebox hosting for the boxcutter project.

<img src="https://d79i1fxsrar4t.cloudfront.net/images/brand/smartystreets.65887aa3.png" width="320">
