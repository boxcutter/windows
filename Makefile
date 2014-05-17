# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
        include Makefile.local
endif

WIN2008R2_X64 ?= iso/en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso
WIN2012_X64 ?= iso/win2012/en_windows_server_2012_x64_dvd_915478.iso
WIN2012R2_X64 ?= iso/en_windows_server_2012_r2_with_update_x64_dvd_4065220.iso
WIN7_X64_ENTERPRISE ?= iso/en_windows_7_enterprise_with_sp1_x64_dvd_u_677651.iso
WIN7_X64_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677791.iso
WIN7_X86_ENTERPRISE ?= iso/en_windows_7_enterprise_with_sp1_x86_dvd_u_677710.iso
WIN7_X86_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x86_dvd_u_677896.iso
WIN8_X64_ENTERPRISE ?= iso/en_windows_8_enterprise_x64_dvd_917522.iso
WIN8_X86_ENTERPRISE ?= iso/en_windows_8_enterprise_x86_dvd_917587.iso
WIN8_X64_PRO ?= iso/en_windows_8_x64_dvd_915440.iso
WIN8_X86_PRO ?= iso/en_windows_8_x86_dvd_915417.iso
WIN81_X64_ENTERPRISE ?= iso/en_windows_8.1_enterprise_with_update_x64_dvd_4065178.iso
WIN81_X86_ENTERPRISE ?= iso/en_windows_8.1_enterprise_with_update_x86_dvd_4065185.iso
WIN81_X64_PRO ?= iso/en_windows_8.1_professional_vl_with_update_x64_dvd_4065194.iso
WIN81_X86_PRO ?= iso/en_windows_8.1_professional_vl_with_update_x86_dvd_4065201.iso

# Possible values for CM: (nocm | chef | chefdk | salt | puppet)
CM ?= nocm
# Possible values for CM_VERSION: (latest | x.y.z | x.y)
CM_VERSION ?=
ifndef CM_VERSION
	ifneq ($(CM),nocm)
		CM_VERSION = latest
	endif
endif
# Packer does not allow empty variables, so only pass variables that are defined
ifdef CM_VERSION
	PACKER_VARS := -var 'cm=$(CM)' -var 'cm_version=$(CM_VERSION)'
else
	PACKER_VARS := -var 'cm=$(CM)'
endif
ifeq ($(CM),nocm)
	BOX_SUFFIX := -$(CM).box
else
	BOX_SUFFIX := -$(CM)$(CM_VERSION).box
endif
BUILDER_TYPES := vmware virtualbox
TEMPLATE_FILENAMES := $(wildcard *.json)
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
TEST_BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), test-box/$(builder)/$(box_filename)))
VMWARE_BOX_DIR := box/vmware
VIRTUALBOX_BOX_DIR := box/virtualbox
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
CURRENT_DIR := $(shell pwd)
SOURCES := $(wildcard script/*.bat) $(wildcard floppy/*.*)

.PHONY: all list clean test

all: $(BOX_FILES)

test: $(TEST_BOX_FILES)

###############################################################################
# Target shortcuts
define SHORTCUT

$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

vmware/$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

vmware/$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

virtualbox/$(1): $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

virtualbox/$(1)-cygwin: $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-vmware/$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-vmware/$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-virtualbox/$(1): test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-virtualbox/$(1)-cygwin: test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

endef

SHORTCUT_TARGETS := win2008r2-datacenter win2008r2-enterprise win2008r2-standard win2008r2-web win2012-datacenter win2012-standard win2012r2-datacenter win2012r2-standard win7x64-enterprise win7x64-pro win7x86-enterprise win7x86-pro win8x64-enterprise win8x64-pro win8x86-enterprise win8x86-pro win81x64-enterprise win81x64-pro win81x86-enterprise win81x86-pro
$(foreach i,$(SHORTCUT_TARGETS),$(eval $(call SHORTCUT,$(i))))

###############################################################################

# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-vmware-iso
#       mkdir -p $(VMWARE_BOX_DIR)
#       packer build -only=vmware-iso $(PACKER_VARS) $<

$(VMWARE_BOX_DIR)/win2008r2-datacenter$(BOX_SUFFIX): win2008r2-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-enterprise$(BOX_SUFFIX): win2008r2-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-standard$(BOX_SUFFIX): win2008r2-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-web$(BOX_SUFFIX): win2008r2-web.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-datacenter-cygwin$(BOX_SUFFIX): win2008r2-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-enterprise-cygwin$(BOX_SUFFIX): win2008r2-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-standard-cygwin$(BOX_SUFFIX): win2008r2-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2008r2-web-cygwin$(BOX_SUFFIX): win2008r2-web-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VMWARE_BOX_DIR)/win2012-datacenter$(BOX_SUFFIX): win2012-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VMWARE_BOX_DIR)/win2012-standard$(BOX_SUFFIX): win2012-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VMWARE_BOX_DIR)/win2012-datacenter-cygwin$(BOX_SUFFIX): win2012-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VMWARE_BOX_DIR)/win2012-standard-cygwin$(BOX_SUFFIX): win2012-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VMWARE_BOX_DIR)/win2012r2-datacenter$(BOX_SUFFIX): win2012r2-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VMWARE_BOX_DIR)/win2012r2-standard$(BOX_SUFFIX): win2012r2-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VMWARE_BOX_DIR)/win2012r2-datacenter-cygwin$(BOX_SUFFIX): win2012r2-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VMWARE_BOX_DIR)/win2012r2-standard-cygwin$(BOX_SUFFIX): win2012r2-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VMWARE_BOX_DIR)/win7x64-enterprise$(BOX_SUFFIX): win7x64-enterprise.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win7x86-enterprise$(BOX_SUFFIX): win7x86-enterprise.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win7x64-pro$(BOX_SUFFIX): win7x64-pro.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win7x86-pro$(BOX_SUFFIX): win7x86-pro.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" $<

$(VMWARE_BOX_DIR)/win7x64-enterprise-cygwin$(BOX_SUFFIX): win7x64-enterprise-cygwin.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win7x86-enterprise-cygwin$(BOX_SUFFIX): win7x86-enterprise-cygwin.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win7x64-pro-cygwin$(BOX_SUFFIX): win7x64-pro-cygwin.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win7x86-pro-cygwin$(BOX_SUFFIX): win7x86-pro-cygwin.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" $<

$(VMWARE_BOX_DIR)/win8x64-enterprise$(BOX_SUFFIX): win8x64-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win8x64-pro$(BOX_SUFFIX): win8x64-pro.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win8x86-enterprise$(BOX_SUFFIX): win8x86-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win8x86-pro$(BOX_SUFFIX): win8x86-pro.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" $<

$(VMWARE_BOX_DIR)/win8x64-enterprise-cygwin$(BOX_SUFFIX): win8x64-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win8x64-pro-cygwin$(BOX_SUFFIX): win8x64-pro-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win8x86-enterprise-cygwin$(BOX_SUFFIX): win8x64-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win8x86-pro-cygwin$(BOX_SUFFIX): win8x86-pro-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" $<

$(VMWARE_BOX_DIR)/win81x64-enterprise$(BOX_SUFFIX): win81x64-enterprise.json floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win81x86-enterprise$(BOX_SUFFIX): win81x86-enterprise.json floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win81x64-pro$(BOX_SUFFIX): win81x64-pro.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win81x86-pro$(BOX_SUFFIX): win81x86-pro.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" $<

$(VMWARE_BOX_DIR)/win81x64-enterprise-cygwin$(BOX_SUFFIX): win81x64-enterprise-cygwin.json floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win81x86-enterprise-cygwin$(BOX_SUFFIX): win81x86-enterprise-cygwin.json floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" $<

$(VMWARE_BOX_DIR)/win81x64-pro-cygwin$(BOX_SUFFIX): win81x64-pro-cygwin.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" $<

$(VMWARE_BOX_DIR)/win81x86-pro-cygwin$(BOX_SUFFIX): win81x86-pro-cygwin.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-virtualbox-iso
#       mkdir -p $(VIRTUALBOX_BOX_DIR)
#       packer build -only=virtualbox-iso $(PACKER_VARS) $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-datacenter$(BOX_SUFFIX): win2008r2-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$VIRTUALBOX_BOX_DIR)/win2008r2-enterprise$(BOX_SUFFIX): win2008r2-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-standard$(BOX_SUFFIX): win2008r2-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-web$(BOX_SUFFIX): win2008r2-web.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-datacenter-cygwin$(BOX_SUFFIX): win2008r2-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-enterprise-cygwin$(BOX_SUFFIX): win2008r2-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-standard-cygwin$(BOX_SUFFIX): win2008r2-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-web-cygwin$(BOX_SUFFIX): win2008r2-web-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-datacenter$(BOX_SUFFIX): win2012-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-standard$(BOX_SUFFIX): win2012-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-datacenter-cygwin$(BOX_SUFFIX): win2012-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-standard-cygwin$(BOX_SUFFIX): win2012-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-datacenter$(BOX_SUFFIX): win2012r2-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-standard$(BOX_SUFFIX): win2012r2-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-datacenter-cygwin$(BOX_SUFFIX): win2012r2-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-standard-cygwin$(BOX_SUFFIX): win2012r2-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-enterprise$(BOX_SUFFIX): win7x64-enterprise.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-enterprise$(BOX_SUFFIX): win7x86-enterprise.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-pro$(BOX_SUFFIX): win7x64-pro.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-pro$(BOX_SUFFIX): win7x86-pro.json $(SOURCES) floppy/win7x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-enterprise-cygwin$(BOX_SUFFIX): win7x64-enterprise-cygwin.json floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-enterprise-cygwin$(BOX_SUFFIX): win7x86-enterprise-cygwin.json floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-pro-cygwin$(BOX_SUFFIX): win7x64-pro-cygwin.json floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-pro-cygwin$(BOX_SUFFIX): win7x86-pro-cygwin.json floppy/win7x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-enterprise$(BOX_SUFFIX): win8x64-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-pro$(BOX_SUFFIX): win8x64-pro.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-enterprise$(BOX_SUFFIX): win8x86-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-pro$(BOX_SUFFIX): win8x86-pro.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-enterprise-cygwin$(BOX_SUFFIX): win8x64-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-pro-cygwin$(BOX_SUFFIX): win8x64-pro-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-enterprise-cygwin$(BOX_SUFFIX): win8x86-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-pro-cygwin$(BOX_SUFFIX): win8x86-pro-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-enterprise$(BOX_SUFFIX): win81x64-enterprise.json $(SOURCES) floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-enterprise$(BOX_SUFFIX): win81x86-enterprise.json $(SOURCES) floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-pro$(BOX_SUFFIX): win81x64-pro.json $(SOURCES) floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-pro$(BOX_SUFFIX): win81x86-pro.json $(SOURCES) floppy/win81x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-enterprise-cygwin$(BOX_SUFFIX): win81x64-enterprise-cygwin.json $(SOURCES) floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-enterprise-cygwin$(BOX_SUFFIX): win81x86-enterprise-cygwin.json $(SOURCES) floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-pro-cygwin$(BOX_SUFFIX): win81x64-pro-cygwin.json $(SOURCES) floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-pro-cygwin$(BOX_SUFFIX): win81x86-pro-cygwin.json $(SOURCES) floppy/win81x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" $<

list:
	@echo "Prepend 'vwmare/' or 'virtualbox/' to build only one target platform:"
	@echo "  make vmware/win7x64"
	@echo ""
	@echo "Targets:"
	@for shortcut_target in $(SHORTCUT_TARGETS) ; do \
		echo $$shortcut_target ; \
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
	rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb

#test-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
#	echo $@
#	echo $<

test-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb
