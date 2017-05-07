# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
        include Makefile.local
endif

include urls.mk

# Possible values for CM: (nocm | chef | chefdk | salt | puppet)
CM ?= nocm
# Possible values for CM_VERSION: (latest | x.y.z | x.y)
CM_VERSION ?=
ifndef CM_VERSION
	ifneq ($(CM),nocm)
		CM_VERSION = latest
	endif
endif
BOX_VERSION ?= $(shell cat VERSION)
UPDATE ?= false
GENERALIZE ?= false
HEADLESS ?= false
ifndef SHUTDOWN_COMMAND
ifeq ($(GENERALIZE),true)
	SHUTDOWN_COMMAND ?= C:/Windows/System32/Sysprep/sysprep.exe /generalize /shutdown /oobe /unattend:A:/Autounattend.xml
else
	SHUTDOWN_COMMAND ?= shutdown /s /t 10 /f /d p:4:1 /c Packer_Shutdown
endif
endif
ifeq ($(CM),nocm)
	BOX_SUFFIX := -$(CM)-$(BOX_VERSION).box
else
	BOX_SUFFIX := -$(CM)$(CM_VERSION)-$(BOX_VERSION).box
endif
# Packer does not allow empty variables, so only pass variables that are defined
PACKER_VARS := -var 'cm=$(CM)' -var 'version=$(BOX_VERSION)' -var 'update=$(UPDATE)' -var 'headless=$(HEADLESS)' -var "shutdown_command=$(SHUTDOWN_COMMAND)"
ifdef CM_VERSION
	PACKER_VARS += -var 'cm_version=$(CM_VERSION)'
endif
PACKER ?= packer
ifdef PACKER_DEBUG
	PACKER := PACKER_LOG=1 $(PACKER)
else
endif
BUILDER_TYPES ?= vmware virtualbox parallels
ifeq ($(OS),Windows_NT)
	VAGRANT_PROVIDER ?= vmware_workstation
else
	VAGRANT_PROVIDER ?= vmware_fusion
endif
TEMPLATE_FILENAMES := $(wildcard *.json)
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
TEST_BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), test-box/$(builder)/$(box_filename)))
VMWARE_BOX_DIR := box/vmware
VIRTUALBOX_BOX_DIR := box/virtualbox
PARALLELS_BOX_DIR := box/parallels
VMWARE_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VMWARE_BOX_DIR)/$(box_filename))
VIRTUALBOX_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VIRTUALBOX_BOX_DIR)/$(box_filename))
PARALLELS_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(PARALLELS_BOX_DIR)/$(box_filename))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
PARALLELS_OUTPUT := output-parallels-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
PARALLELS_BUILDER := parallels-iso
CURRENT_DIR := $(shell pwd)
UNAME_O := $(shell uname -o 2> /dev/null)
UNAME_P := $(shell uname -p 2> /dev/null)
UNAME_S := $(shell uname -s 2> /dev/null)
ifeq ($(UNAME_O),Cygwin)
	CURRENT_DIR := $(shell cygpath -m $(CURRENT_DIR))
endif

SOURCES := $(wildcard script/*.*) $(wildcard floppy/*.*)

.PHONY: list

all: $(BOX_FILES)

test: $(TEST_BOX_FILES)

###############################################################################
# Target shortcuts
define SHORTCUT

ifeq ($(UNAME_S),Darwin)

$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

else

$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

endif

vmware/$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

vmware/$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

vmware/$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

virtualbox/$(1): $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

virtualbox/$(1)-cygwin: $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

virtualbox/$(1)-ssh: $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

parallels/$(1): $(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

parallels/$(1)-cygwin: $(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

parallels/$(1)-ssh: $(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-vmware/$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-vmware/$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-vmware/$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-virtualbox/$(1): test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-virtualbox/$(1)-cygwin: test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-virtualbox/$(1)-ssh: test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-parallels/$(1): test-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-parallels/$(1)-cygwin: test-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-parallels/$(1)-ssh: test-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-vmware/$(1): ssh-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-vmware/$(1)-cygwin: ssh-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-vmware/$(1)-ssh: ssh-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-virtualbox/$(1): ssh-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-virtualbox/$(1)-cygwin: ssh-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-virtualbox/$(1)-ssh: ssh-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-parallels/$(1): ssh-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-parallels/$(1)-cygwin: ssh-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-parallels/$(1)-ssh: ssh-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-vmware/$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

s3cp-virtualbox/$(1): s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

s3cp-parallels/$(1): s3cp-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)
endef

SHORTCUT_TARGETS := $(basename $(TEMPLATE_FILENAMES))
$(foreach i,$(SHORTCUT_TARGETS),$(eval $(call SHORTCUT,$(i))))

###############################################################################

win7: win7-winrm win7-openssh win7-cygwin

win7-winrm: win7x64-enterprise win7x64-pro win7x86-enterprise win7x86-pro

win7-openssh: win7x64-enterprise-ssh win7x64-pro-ssh win7x86-enterprise-ssh win7x86-pro-ssh

win7-cygwin: win7x64-enterprise-cygwin win7x64-pro-cygwin win7x86-enterprise-cygwin win7x86-pro-cygwin


test-win7: test-win7-winrm test-win7-openssh test-win7-cygwin

test-win7-winrm: test-win7x64-enterprise test-win7x64-pro test-win7x86-enterprise test-win7x86-pro

test-win7-openssh: test-win7x64-enterprise-ssh test-win7x64-pro-ssh test-win7x86-enterprise-ssh test-win7x86-pro-ssh

test-win7-cygwin: test-win7x64-enterprise-cygwin test-win7x64-pro-cygwin test-win7x86-enterprise-cygwin test-win7x86-pro-cygwin


win8: win8-winrm win8-openssh win8-cygwin

win8-winrm: win8x64-enterprise win8x64-pro win8x86-enterprise win8x86-pro

win8-openssh: win8x64-enterprise-ssh win8x64-pro-ssh win8x86-enterprise-ssh win8x86-pro-ssh

win8-cygwin: win8x64-enterprise-cygwin win8x64-pro-cygwin win8x86-enterprise-cygwin win8x86-pro-cygwin


test-win8: test-win8-winrm test-win8-openssh test-win8-cygwin

test-win8-winrm: test-win8x64-enterprise test-win8x64-pro test-win8x86-enterprise test-win8x86-pro

test-win8-openssh: test-win8x64-enterprise-ssh test-win8x64-pro-ssh test-win8x86-enterprise-ssh test-win8x86-pro-ssh

test-win8-cygwin: test-win8x64-enterprise-cygwin test-win8x64-pro-cygwin test-win8x86-enterprise-cygwin test-win8x86-pro-cygwin


win81: win81-winrm win81-openssh win81-cygwin

win81-winrm: win81x64-enterprise win81x64-pro win81x86-enterprise win81x86-pro

win81-openssh: win81x64-enterprise-ssh win81x64-pro-ssh win81x86-enterprise-ssh win81x86-pro-ssh

win81-cygwin: win81x64-enterprise-cygwin win81x64-pro-cygwin win81x86-enterprise-cygwin win81x86-pro-cygwin


test-win81: test-win81-winrm test-win81-openssh test-win81-cygwin

test-win81-winrm: test-win81x64-enterprise test-win81x64-pro test-win81x86-enterprise test-win81x86-pro

test-win81-openssh: test-win81x64-enterprise-ssh test-win81x64-pro-ssh test-win81x86-enterprise-ssh test-win81x86-pro-ssh

test-win81-cygwin: test-win81x64-enterprise-cygwin test-win81x64-pro-cygwin test-win81x86-enterprise-cygwin test-win81x86-pro-cygwin


win2008r2: win2008r2-winrm win2008r2-openssh win2008r2-cygwin

win2008r2-winrm: win2008r2-datacenter win2008r2-enterprise win2008r2-standard win2008r2-web

win2008r2-openssh: win2008r2-datacenter-ssh win2008r2-enterprise-ssh win2008r2-standard-ssh win2008r2-web-ssh

win2008r2-cygwin: win2008r2-datacenter-cygwin win2008r2-enterprise-cygwin win2008r2-standard-cygwin win2008r2-web-cygwin


test-win2008r2: test-win2008r2-winrm test-win2008r2-openssh test-win2008r2-cygwin

test-win2008r2-winrm: test-win2008r2-datacenter test-win2008r2-enterprise test-win2008r2-standard test-win2008r2-web

test-win2008r2-openssh: test-win2008r2-datacenter-ssh test-win2008r2-enterprise-ssh test-win2008r2-standard-ssh test-win2008r2-web-ssh

test-win2008r2-cygwin: test-win2008r2-datacenter-cygwin test-win2008r2-enterprise-cygwin test-win2008r2-standard-cygwin test-win2008r2-web-cygwin


win2012: win2012-winrm win2012-openssh win2012-cygwin

win2012-winrm: win2012-datacenter win2012-standard

win2012-openssh: win2012-datacenter-ssh win2012-standard-ssh

win2012-cygwin: win2012-datacenter-cygwin win2012-standard-cygwin


test-win2012: test-win2012-winrm test-win2012-openssh test-win2012-cygwin

test-win2012-winrm: test-win2012-datacenter test-win2012-standard

test-win2012-openssh: test-win2012-datacenter-ssh test-win2012-standard-ssh

test-win2012-cygwin: test-win2012-datacenter-cygwin test-win2012-standard-cygwin


win2012r2: win2012r2-winrm win2012r2-openssh win2012r2-cygwin

win2012r2-winrm: win2012r2-datacenter win2012r2-standard

win2012r2-openssh: win2012r2-datacenter-ssh win2012r2-standard-ssh

win2012r2-cygwin: win2012r2-datacenter-cygwin win2012r2-standard-cygwin


test-win2012r2: test-win2012r2-winrm test-win2012r2-openssh test-win2012r2-cygwin

test-win2012r2-winrm: test-win2012r2-datacenter test-win2012r2-standard

test-win2012r2-openssh: test-win2012r2-datacenter-ssh test-win2012r2-standard-ssh

test-win2012r2-cygwin: test-win2012r2-datacenter-cygwin test-win2012r2-standard-cygwin


eval: eval-winrm eval-openssh

eval-winrm: eval-win2012r2-datacenter eval-win2008r2-datacenter eval-win81x64-enterprise eval-win7x64-enterprise eval-win10x64-enterprise

eval-openssh: eval-win2012r2-datacenter-ssh eval-win2008r2-datacenter-ssh eval-win81x64-enterprise-ssh eval-win7x64-enterprise-ssh eval-win10x64-enterprise-ssh

test-eval-openssh: test-eval-win2012r2-datacenter test-eval-win2008r2-datacenter test-eval-win81x64-enterprise test-eval-win7x64-enterprise test-eval-win10x64-enterprise

define BUILDBOX

$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1).json

$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1).json

$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1).json

$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

endef

$(eval $(call BUILDBOX,win2008r2-datacenter,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2008r2-datacenter,$(EVAL_WIN2008R2_X64),$(EVAL_WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2008r2-enterprise,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2008r2-standard,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2008r2-standard,$(EVAL_WIN2008R2_X64),$(EVAL_WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2008r2-web,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2012-datacenter,$(WIN2012_X64),$(WIN2012_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2012-standard,$(WIN2012_X64),$(WIN2012_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2012r2-datacenter,$(WIN2012R2_X64),$(WIN2012R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2012r2-datacenter,$(EVAL_WIN2012R2_X64),$(EVAL_WIN2012R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2012r2-standard,$(WIN2012R2_X64),$(WIN2012R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2012r2-standard,$(EVAL_WIN2012R2_X64),$(EVAL_WIN2012R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win2012r2-standardcore,$(WIN2012R2_X64),$(WIN2012R2_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win7x64-enterprise,$(WIN7_X64_ENTERPRISE),$(WIN7_X64_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win7x64-enterprise,$(EVAL_WIN7_X64),$(EVAL_WIN7_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win7x86-enterprise,$(WIN7_X86_ENTERPRISE),$(WIN7_X86_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,win7x64-pro,$(WIN7_X64_PRO),$(WIN7_X64_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win7x86-pro,$(WIN7_X86_PRO),$(WIN7_X86_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win8x64-enterprise,$(WIN8_X64_ENTERPRISE),$(WIN8_X64_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,win8x64-pro,$(WIN8_X64_PRO),$(WIN8_X64_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win8x86-enterprise,$(WIN8_X86_ENTERPRISE),$(WIN8_X86_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,win8x86-pro,$(WIN8_X86_PRO),$(WIN8_X86_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win81x64-enterprise,$(WIN81_X64_ENTERPRISE),$(WIN81_X64_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win81x64-enterprise,$(EVAL_WIN81_X64),$(EVAL_WIN81_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win81x86-enterprise,$(WIN81_X86_ENTERPRISE),$(WIN81_X86_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,win81x64-pro,$(WIN81_X64_PRO),$(WIN81_X64_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win81x86-pro,$(WIN81_X86_PRO),$(WIN81_X86_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win7x86-enterprise,$(EVAL_WIN7_X86),$(EVAL_WIN7_X86_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win81x86-enterprise,$(EVAL_WIN81_X86),$(EVAL_WIN81_X86_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win8x64-enterprise,$(EVAL_WIN8_X64),$(EVAL_WIN8_X64_CHECKSUM)))

$(eval $(call BUILDBOX,win10x64-enterprise,$(WIN10_X64_ENTERPRISE),$(WIN10_X64_ENTERPRISE_CHECKSUM)))

$(eval $(call BUILDBOX,win10x64-preview,$(WIN10_X64_PREVIEW),$(WIN10_X64_PREVIEW_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win10x64-enterprise,$(EVAL_WIN10_X64),$(EVAL_WIN10_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win10x86-enterprise,$(EVAL_WIN10_X86),$(EVAL_WIN10_X86_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2016-core,$(EVAL_WIN2016_X64),$(EVAL_WIN2016_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2016-datacenter,$(EVAL_WIN2016_X64),$(EVAL_WIN2016_X64_CHECKSUM)))

# @todo:
#$(eval $(call BUILDBOX,eval-win2012-standard,$(EVAL_WIN2012_X64),$(EVAL_WIN2012_X64_CHECKSUM)))

# can't find powershell:
#$(eval $(call BUILDBOX,win2008r2-standardcore,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))
#$(eval $(call BUILDBOX,win2008r2-standardcore-cygwin,$(WIN2008R2_X64),$(WIN2008R2_X64_CHECKSUM)))

# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-vmware-iso
#       mkdir -p $(VMWARE_BOX_DIR)
#       $(PACKER) build -only=vmware-iso $(PACKER_VARS) $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-virtualbox-iso
#       mkdir -p $(VIRTUALBOX_BOX_DIR)
#       $(PACKER) build -only=virtualbox-iso $(PACKER_VARS) $<

list:
	@echo "To build for all target platforms:"
	@echo "  make win7x64-pro"
	@echo ""
	@echo "Prepend 'vmware/' or 'virtualbox/' or 'parallels/' to build only one target platform:"
	@echo "  make vmware/win7x64-pro"
	@echo ""
	@echo "Append '-cygwin' to use Cygwin's SSH instead of OpenSSH:"
	@echo "  make win7x64-pro-cygwin"
	@echo ""
	@echo "Or to build for vmware only:"
	@echo "  make vmware/win7x64-pro-cygwin"
	@echo ""
	@echo "Targets:"
	@for shortcut_target in $(SHORTCUT_TARGETS) ; do \
		echo $$shortcut_target ; \
	done | sort

validate:
	@for template_filename in $(TEMPLATE_FILENAMES) ; do \
		echo Checking $$template_filename ; \
		$(PACKER) validate $$template_filename ; \
	done

clean: clean-builders clean-output clean-packer-cache

clean-builders:
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done

clean-output:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-$$builder-iso ; \
		echo rm -rf output-$$builder-iso ; \
	done

clean-packer-cache:
	echo Deleting packer_cache
	rm -rf packer_cache

test-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< vmware_desktop $(VAGRANT_PROVIDER) $(CURRENT_DIR)/test/*_spec.rb

test-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

test-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< vmware_desktop $(VAGRANT_PROVIDER) $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

ssh-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb

S3_STORAGE_CLASS ?= REDUCED_REDUNDANCY
S3_ALLUSERS_ID ?= uri=http://acs.amazonaws.com/groups/global/AllUsers

s3cp-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VMWARE_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VIRTUALBOX_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(PARALLELS_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-vmware: $(addprefix s3cp-,$(VMWARE_BOX_FILES))
s3cp-virtualbox: $(addprefix s3cp-,$(VIRTUALBOX_BOX_FILES))
s3cp-parallels: $(addprefix s3cp-,$(PARALLELS_BOX_FILES))
