PREDOWNLOADED_FILES=$(wildcard vshell*.*)

# always 301's to latest installer:
CHEF_URL?=https://www.opscode.com/chef/install.msi
CHOCOLATEY_URL?=https://chocolatey.org/install.ps1
COREUTILS_URL?=http://downloads.sourceforge.net/gnuwin32/coreutils-5.3.0-bin.zip
CYGWIN_URL?=http://cygwin.com/setup-x86.exe
DOTNET_URL?=http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe
LESSMSI_URL?=https://github.com/activescott/lessmsi/releases/download/v1.2.0/lessmsi-v1.2.0.zip
MLSSSH_32_URL?=http://www.mls-software.com/files/setupssh-6.7p1-1-v1.exe
#MLSSSH_64_URL?=http://www.mls-software.com/files/setupssh-6.7p1-1-v1.exe
NUGET_URL?=http://nuget.org/nuget.exe
PUPPET_URL?=https://downloads.puppetlabs.com/windows/puppet-3.7.3.msi
SALT_32_URL?=https://docs.saltstack.com/downloads/Salt-Minion-2014.7.0-x86-Setup.exe
SALT_64_URL?=https://docs.saltstack.com/downloads/Salt-Minion-2014.7.0-AMD64-Setup.exe
SDELETE_URL?=http://live.sysinternals.com/sdelete.exe
SEVENZIP_32_URL?=http://downloads.sourceforge.net/sevenzip/7z922.msi
SEVENZIP_64_URL?=http://downloads.sourceforge.net/sevenzip/7z922-x64.msi
UNXTUTILS_URL?=http://downloads.sourceforge.net/unxutils/UnxUtils.zip
ULTRADEFRAG_32_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.0.4.bin.i386.zip
ULTRADEFRAG_64_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.0.4.bin.amd64.zip
VAGRANT_PUB_URL?=https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
VBOX_ISO_URL?=http://download.virtualbox.org/virtualbox/4.3.20/VBoxGuestAdditions_4.3.20.iso
VMWARE_TOOLS_TAR_URL=https://softwareupdate.vmware.com/cds/vmw-desktop/ws/10.0.4/2249910/windows/packages/tools-windows-9.6.2.exe.tar
WGET_URL?=http://users.ugent.be/~bpuype/wget/wget.exe

CHEF:=chef-client-latest.msi
CHOCOLATEY:=$(shell basename $(CHOCOLATEY_URL))
COREUTILS:=$(shell basename $(COREUTILS_URL))
CYGWIN:=$(shell basename $(CYGWIN_URL))
DOTNET:=$(shell basename $(DOTNET_URL))
LESSMSI:=$(shell basename $(LESSMSI_URL))
MLSSSH_32:=$(shell basename $(MLSSSH_32_URL))
#MLSSSH_64:=$(shell basename "$(MLSSSH_64_URL)")
NUGET:=$(shell basename $(NUGET_URL))
PUPPET:=$(shell basename $(PUPPET_URL))
SDELETE:=$(shell basename $(SDELETE_URL))
SALT_32:=$(shell basename $(SALT_32_URL))
SALT_64:=$(shell basename $(SALT_64_URL))
SEVENZIP_32:=$(shell basename $(SEVENZIP_32_URL))
SEVENZIP_64:=$(shell basename $(SEVENZIP_64_URL))
ULTRADEFRAG_32:=$(shell basename $(ULTRADEFRAG_32_URL))
ULTRADEFRAG_64:=$(shell basename $(ULTRADEFRAG_64_URL))
UNXTUTILS:=$(shell basename $(UNXTUTILS_URL))
VAGRANT_PUB:=$(shell basename $(VAGRANT_PUB_URL))
VBOX_ISO=$(shell basename $(VBOX_ISO_URL))
VMWARE_TOOLS_TAR=$(shell basename $(VMWARE_TOOLS_TAR_URL))

TEE_EXE=tee.exe
WGET_EXE=$(shell basename $(WGET_URL))

# "$(MLSSSH_64)"

# $(shell find . -type f \( -name '*.exe' -o -name '*.msi' -o -name '*.pub' \) -printf '%P ')
FILES:=\
$(CHEF) \
$(CHOCOLATEY) \
$(COREUTILS) \
$(CYGWIN) \
$(DOTNET) \
$(LESSMSI) \
$(MLSSSH_32) \
$(NUGET) \
$(PUPPET) \
$(SDELETE) \
$(SALT_32) \
$(SALT_64) \
$(SEVENZIP_32) \
$(SEVENZIP_64) \
$(TEE_EXE) \
$(ULTRADEFRAG_32) \
$(ULTRADEFRAG_64) \
unzip.vbs \
$(VAGRANT_PUB) \
VBoxGuestAdditions.iso \
$(VBOX_ISO) \
$(VMWARE_TOOLS_TAR) \
$(WGET_EXE) \
windows.iso \

WGET:=wget --no-check-certificate

provisions.iso: $(FILES)
	-rm -f $@
	mkisofs -J -r -l -udf -o $@ $^ $(PREDOWNLOADED_FILES)

windows.iso:
	-test -f "$$SYSTEMDRIVE/Program Files/VMware/VMware Workstation/windows.iso" && \
	     cp "$$SYSTEMDRIVE/Program Files/VMware/VMware Workstation/windows.iso" $@
	test $@ || \
	test -f "$$SYSTEMDRIVE/Program Files (x86)/VMware/VMware Workstation/windows.iso" && \
	     cp "$$SYSTEMDRIVE/Program Files (x86)/VMware/VMware Workstation/windows.iso" $@

VBoxGuestAdditions.iso:
	cp -p "$$SYSTEMDRIVE/Program Files/Oracle/VirtualBox/VBoxGuestAdditions.iso" $@

$(CHEF):
	-$(WGET) -O $@ $(CHEF_URL)
	-rm -f provisions.iso

$(CHOCOLATEY):
	-$(WGET) -O $@ $(CHOCOLATEY_URL)
	-rm -f provisions.iso

$(COREUTILS):
	-$(WGET) -O $@ $(COREUTILS_URL)
	-rm -f provisions.iso

$(TEE_EXE): $(UNXTUTILS)
	unzip -o -j $< usr/local/wbin/$@
	-upx -9 $@
	touch --reference $@ $<
	-rm -f provisions.iso

$(CYGWIN):
	-$(WGET) -O $@ $(CYGWIN_URL)
	-rm -f provisions.iso

$(DOTNET):
	-$(WGET) -O $@ $(DOTNET_URL)
	-rm -f provisions.iso

$(LESSMSI):
	-$(WGET) -O $@ $(LESSMSI_URL)
	-rm -f provisions.iso

$(MLSSSH_32):
	-$(WGET) -O $@ $(MLSSSH_32_URL)
	-rm -f provisions.iso

#"$(MLSSSH_64)":
#	-$(WGET) -O $@ "$(MLSSSH_64_URL)"
#	touch --reference $@ "\"$(MLSSSH_64)\""
#	-rm -f provisions.iso

$(NUGET):
	-$(WGET) -O $@ $(NUGET_URL)
	-rm -f provisions.iso

$(PUPPET):
	-$(WGET) -O $@ $(PUPPET_URL)
	-rm -f provisions.iso

$(SDELETE):
	-$(WGET) -O $@ $(SDELETE_URL)
	-rm -f provisions.iso

$(SALT_32):
	-$(WGET) -O $@ $(SALT_32_URL)
	-rm -f provisions.iso

$(SALT_64):
	-$(WGET) -O $@ $(SALT_64_URL)
	-rm -f provisions.iso

$(SEVENZIP_32):
	-$(WGET) -O $@ $(SEVENZIP_32_URL)
	-rm -f provisions.iso

$(SEVENZIP_64):
	-$(WGET) -O $@ $(SEVENZIP_64_URL)
	-rm -f provisions.iso

$(ULTRADEFRAG_32):
	-$(WGET) -O $@ $(ULTRADEFRAG_32_URL)
	-rm -f provisions.iso

$(ULTRADEFRAG_64):
	-$(WGET) -O $@ $(ULTRADEFRAG_64_URL)
	-rm -f provisions.iso

unzip.vbs:
	echo 'Set fso = CreateObject("Scripting.FileSystemObject")'>$@
	echo 'ZipFile=fso.GetAbsolutePathName(Wscript.Arguments(0))'>>$@
	echo 'ExtractTo=fso.GetAbsolutePathName(Wscript.Arguments(1))'>>$@
	echo 'If NOT fso.FolderExists(ExtractTo) Then'>>$@
	echo '  fso.CreateFolder(ExtractTo)'>>$@
	echo 'End If'>>$@
	echo 'set objShell = CreateObject("Shell.Application")'>>$@
	echo 'set FilesInZip=objShell.NameSpace(ZipFile).items'>>$@
	echo 'objShell.NameSpace(ExtractTo).CopyHere(FilesInZip)'>>$@
	echo 'Set fso = Nothing'>>$@
	echo 'Set objShell = Nothing'>>$@

$(UNXTUTILS):
	-$(WGET) -O $@ $(UNXTUTILS_URL)
	-rm -f provisions.iso

$(VAGRANT_PUB):
	-$(WGET) -O $@ $(VAGRANT_PUB_URL)
	-rm -f provisions.iso

$(VBOX_ISO):
	-$(WGET) -O $@ $(VBOX_ISO_URL)
	-rm -f provisions.iso

$(VMWARE_TOOLS_TAR):
	-$(WGET) -O $@ $(VMWARE_TOOLS_TAR_URL)
	-rm -f provisions.iso

$(WGET_EXE):
	-$(WGET) -O $@ $(WGET_URL)
	touch --reference $@ .$@
	-upx -9 $@
	touch --reference .$@ $@
	-rm -f .$@
	-rm -f provisions.iso

.PHONY: clean
clean:
	rm -f provisions.iso

.PHONY: realclean
realclean:	clean
	rm -f $(FILES) "\"$(MLSSSH_64)\""

.PHONY: debug
debug:
	@echo CHEF=$(CHEF)
	@echo CHOCOLATEY=$(CHOCOLATEY)
	@echo CYGWIN=$(CYGWIN)
	@echo DOTNET=$(DOTNET)
	@echo LESSMSI=$(LESSMSI)
	@echo MLSSSH_32=$(MLSSSH_32)
	@echo MLSSSH_64="$(MLSSSH_64)"
	#@echo MLSSSH_64_URL="$(MLSSSH_64_URL)"
	@echo NUGET=$(NUGET)
	@echo PUPPET=$(PUPPET)
	@echo SDELETE=$(SDELETE)
	@echo SALT_32=$(SALT_32)
	@echo SALT_64=$(SALT_64)
	@echo SEVENZIP_32=$(SEVENZIP_32)
	@echo SEVENZIP_64=$(SEVENZIP_64)
	@echo ULTRADEFRAG_32=$(ULTRADEFRAG_32)
	@echo ULTRADEFRAG_64=$(ULTRADEFRAG_64)
	@echo VAGRANT_PUB=$(VAGRANT_PUB)
	@echo VBOX_ISO=$(VBOX_ISO)
	@echo VMWARE_TOOLS_TAR=$(VMWARE_TOOLS_TAR)
	@echo WGET_EXE=$(WGET_EXE)
