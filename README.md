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

### Downloads during the build process

When building any the boxes, each template will download a number of files from
the internet in order to provision the box and then optimize its disk after
the install is successful. The ability to download is managed through the work
of two scripts. These scripts are `floppy/01-install-wget.cmd` and then
the `floppy/_download.cmd` utility.

Once the download scripts have been bootstrapped, the boxes will then be used
to download and install a number of applications that will be used to prepare
the template prior to completing its build.

#### floppy/01-install-wget.cmd

The job of this script is strictly to bootstrap `wget.exe` on the box and is one
of the first things done after the operating system has been installed in the
image. The bootstrapping procedure is an attempt to download the most recent
version of `wget.exe` from the host https://eternallybored.org/misc/wget/current/wget.exe.
This way the `floppy/_download.cmd` script can use it during the provisioning
stage to download other necessary tools.

The bootstrap process is done by first checking if `floppy/_download.cmd` has
already been installed (by copying into the SystemRoot). If it has been installed,
the script will then simply use it to download the latest version of `wget.exe`
from the aforementioned URL to the SystemRoot. If it hasn't been installed, the
script will then try a number of methods in order to bootstrap the tool.

  1. Powershell - The script will first attempt to transfer the file with
     Powershell. This should work on most boxes and is the most flexible as it
     doesn't require tampering with the disk. On older systems, Powershell may
     not support some of the newer Tls protocols and thus might be unable to
     download from certain sites. In those cases, there's no choice but to
     attempt the next method.

  2. BITSAdmin - The next method the script will try to use is by creating a
     job using the "Background Intelligence Transfer Service". This is done by
     checking for the existence of and using the `BitsAdmin.exe` executable to
     create a job. If the job can be created, the service will then download the
     requested file to the that's provided. This method can be configured by
     modifying the `DISABLE_BITS` field in the `floppy/_packer_config.cmd`
     configuration. Please review that file for more information.

  3. Curl.exe - If the prior two methods have failed in bootstrapping `wget.exe`,
     the box will have no choice but to bootstrap `wget.exe` using a 3rd-party
     binary that was included on the floppy disk during the build. This binary
     is a minimalistic compile of "curl.exe" that is 32-bits and has been
     configured with minimal features in order to fall back on if all else fails.
     This binary is located at `3rdparty/curl.exe` and is built from the fork of
     curl that is found at https://github.com/arizvisa/curl-windows-nodeps/.

#### floppy/_download.cmd

Once `wget.exe` has been bootstrapped, this script can be used to download
arbitrary files from the internet in order to provision each box. This script
has a similar redundancy to the `floppy/01-install-wget.cmd` script in that
first it will attempt to download the requested file with Powershell. If it is
unable to perform this task with Powershell, it will fall back to the copy of
`wget.exe` that was bootstrapped. Afterwards, the `BitsAdmin.exe` tool will be
attempted depending on the value of the configuration variable `DISABLE_BITS`.
If `BitsAdmin.exe` fails to download the requested file or is disabled due to
the variable, the script will then fall back to using the `curl.exe` binary
which was bundled on the floppy disk by Packer.

Each of the available download methods can be influenced by changing the value
of their respective variables within the configuration. The primary `wget.exe`
downloader uses the contents of the `WGET_OPTS` variable for its parameters when
it is called. Similarly, the `curl.exe` fall-back downloader use the contents
of the `CURL_OPTS` variable as its parameters. The default parameters that are
defined in the project's configuration specify to retry a download up to 64 times,
and to repeatedly retry the download even if the connection has been refused. To
change these options, please refer to the Packer Global Configuration.

### Provisioning

Once downloading has been bootstrapped and the box is able to be connected to by
the Packer process, the templates include a number of provisioning steps that are
designed to optimize the template prior to its deployment. A number of these steps
require downloading files from the Internet and running an external tool. After
executing all of the provisioning steps, the templates will clean up followed by
completing the build.

The following tools are downloaded in order to provision each individual box.

##### Vagrant public key

The very first thing that most of the templates do is download the vagrant public
key and install them into the template. This projects is used for producing
vagrant boxes and thus the installation of the vagrant public key is required in
order for Vagrant to be able to connect to them.

The vagrant public key is downloaded directly from @mitchellh's repository for
vagrant at the https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
url. If the user wishes to change this url or specify their own public key, this
can be accomplished by changing the `VAGRANT_PUB_URL` variable.

##### Configuration Management Tools

If any configuration management tools were specified for the build, this step
will proceed to install them into the box. This projects supports a number of
configuration managers which are configurable using the `Makefile.local` override
option. Please review that section for more information on what managers are
supported and how to specify them.

##### Virtual Machine Tools (virtualbox-iso and vmware-iso)

Depending on which builder was specified for the box that is being built, this
step will download and install any tools that can be used to add additional
features to the template when it is deployed. In some cases these tools can
add significant performance or very powerful features to the virtual machine
that is built.

To install these tools, the first thing that is installed is 7-zip. 7-zip
(http://7-zip.org) is specifically used as a general tool to extract the
contents of any of the formats that any tools might be archived in. By default
7-zip is downloaded from either the http://7-zip.org/a/7z1604.msi url for
32-bit templates, or the http://7-zip.org/a/7z1604-x64.msi url when installing
a 64-bit box. This URL is configurable via either the `SEVENZIP_32_URL` variable,
or the `SEVENZIP_64_URL` variable. When a template is done with its build, the
7-zip application will then be uninstalled automatically.

One such set of tools comes with VirtualBox and is known as the VirtualBox Guest
Additions ISO. This ISO allows one to manage some of the features that a VirtualBox
guest exposes to the user. The VirtualBox Guest Additions ISO is downloaded from
the http://download.virtualbox.org/virtualbox/5.1.30/VBoxGuestAdditions_5.1.30.iso url.
Once downloaded, 7-zip will be used to extract the relevant files and then the
"Guest Additions" will be installed into the image. If the user wishes to change
this URL, they can specify an alternative location by assigning it to the variable
`VBOX_ISO_URL`.

The other major set of tools comes along with the VMWare platform and is simply
named "VMware Tools". These tools allow for features such as hardware acceleration,
mapping folders into the VM, file transfers, and copy/paste operations. These
tools are served as a .tar file from the https://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.5.5/5234757/windows/packages/tools-windows.tar
url. If the user wishes to use a different URL, this path can be changed by
setting the VMWARE_TOOLS_TAR_URL variable.

##### Defragmentation (UltraDefrag)

Depending on the filesystem, the hard disk of the template may become fragmented.
Although for later filesystems this is not of significant importance, for virtual
machines this can have large impact when the hard disk is to be compressed. This
can greatly reduce the speed that compression and decompresion of the guest's
hard disk may take.

Before defragmenting the hard disk, 7-Zip is checked to see if it's installed.
If it isn't, then it is downloaded and installed due to it being necessary for
extracting the contents of the UltraDefrag software. The default URL that 7-zip
is fetched from is http://7-zip.org/a/7z1604.msi for 32-bit systems, and then
http://7-zip.org/a/7z1604-x64.msi for 64-bit. If the user wishes to change the
path to download 7-zip from, this can be done by modifying the `SEVENZIP_32_URL`
variable or the `SEVENZIP_64_URL` variable depending on the platform's architecutre.

At this point, the UltraDefrag tool at http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.i386.zip
is then downloaded. After downloading the zip for UltraDefrag, 7-zip will be
used to extract its contents, and then the application will be run with the
task of defragmenting the hard disk. When the hard disk is done being defragmented,
compression of the hard disk should take up significantly less time. To change
the URL that UltraDefrag is downloaded from requires changing the value of the
`ULTRADEFRAG_32_URL` variable for 32-bit platforms, and similarly by changing
the `ULTRADEFRAG_64_URL` variable for 64-bit platforms.


##### Zeroing of free space (SysInternals' SDelete)

The final provisioning step consists of zeroing out all of the empty space at
the end of the template's hard disk. This is done so that none of the empty
space is included whilst compressing the hard disk belonging to the image. This
should greatly assist with reducing its size.

The process of zeroing out the empty space of the template's hard disk is done
entirely by the "SDelete" tool that was developed by SysInternals. Although this
tool is not maintained anymore, it is still valuable and fortunately is hosted
on http://web.archive.org. This provisioning step will download the "SDelete"
tool from the http://web.archive.org/web/20160404120859if_/http://live.sysinternals.com/sdelete.exe
url, and then run it with the task of only clearing out any empty space. If one
wishes to change the URL that this tool is downloaded from, they may do this by
modifying the `SDELETE_URL` variable.

### Tests

The tests are written in [Serverspec](http://serverspec.org) and require the
`vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec

The `Makefile` has individual targets for each box type with the prefix
`test-*` should you wish to run tests individually for each box.

Similarly there are targets with the prefix `ssh-*` for registering a
newly-built box with vagrant and for logging in using just one command to
do exploratory testing. For example, to do exploratory testing
on the VirtualBox training environmnet, run the following command:

    make ssh-box/virtualbox/win2008r2-standard-nocm.box

Upon logout `make ssh-*` will automatically de-register the box as well.

### Makefile.local override

You can create a `Makefile.local` file alongside the `Makefile` to override
some of the default settings. It is most commonly used to override the
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

You can add additional `floppy/_packer_config_*.cmd` files. These files will be ignored by Git.

`floppy/_packer_config*.cmd` will be executed in alpabetical order during initial install and at the beginning of each shell provisioner script if the script supports loading them.

### Acknowledgments

[Parallels](http://www.parallels.com/) provides a Business Edition license of
their software to run on the basebox build farm.

<img src="http://www.parallels.com/fileadmin/images/corporate/brand-assets/images/logo-knockout-on-red.jpg" width="80">

[SmartyStreets](http://www.smartystreets.com) is providing basebox hosting for the boxcutter project.

<img src="https://d79i1fxsrar4t.cloudfront.net/images/brand/smartystreets.65887aa3.png" width="320">
