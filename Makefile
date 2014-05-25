# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
        include Makefile.local
endif

WIN2008R2_X64 ?= iso/en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso
WIN2008R2_X64_CHECKSUM ?= 7e7e9425041b3328ccf723a0855c2bc4f462ec57
WIN2012_X64 ?= iso/win2012/en_windows_server_2012_x64_dvd_915478.iso
WIN2012_X64_CHECKSUM ?= d09e752b1ee480bc7e93dfa7d5c3a9b8aac477ba
WIN2012R2_X64 ?= iso/en_windows_server_2012_r2_with_update_x64_dvd_4065220.iso
WIN2012R2_X64_CHECKSUM ?= af9ef225a510d6d51c5520396452d4f1c1e06935
WIN7_X64_ENTERPRISE ?= http://care.dlservice.microsoft.com/dl/download/evalx/win7/x64/EN/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
WIN7_X64_ENTERPRISE_CHECKSUM ?= 15ddabafa72071a06d5213b486a02d5b55cb7070
WIN7_X64_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677791.iso
WIN7_X64_PRO_CHECKSUM ?= 708e0338d4e2f094dfeb860347c84a6ed9e91d0c
WIN7_X86_ENTERPRISE ?= iso/en_windows_7_enterprise_with_sp1_x86_dvd_u_677710.iso
WIN7_X86_ENTERPRISE_CHECKSUM ?= 4e0450ac73ab6f9f755eb422990cd9c7a1f3509c
WIN7_X86_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x86_dvd_u_677896.iso
WIN7_X86_PRO_CHECKSUM ?= d5bd65e1b326d728f4fd146878ee0d9a3da85075
WIN8_X64_ENTERPRISE ?= iso/en_windows_8.1_enterprise_with_update_x64_dvd_4065178.iso
WIN8_X64_ENTERPRISE_CHECKSUM ?= 4eadfe83e736621234c63e8465986f0af6aa3c82
WIN8_X86_ENTERPRISE ?= iso/en_windows_8_enterprise_x86_dvd_917587.iso
WIN8_X86_ENTERPRISE_CHECKSUM ?= fefce3e64fb9ec1cc7977165328890ccc9a10656
WIN8_X64_PRO ?= iso/en_windows_8_x64_dvd_915440.iso
WIN8_X64_PRO_CHECKSUM ?= 1ce53ad5f60419cf04a715cf3233f247e48beec4
WIN8_X86_PRO ?= iso/en_windows_8_x86_dvd_915417.iso
WIN8_X86_PRO_CHECKSUM ?= 22d680ec53336bee8a5b276a972ceba104787f62
WIN81_X64_ENTERPRISE ?= iso/en_windows_8.1_enterprise_with_update_x64_dvd_4065178.iso
WIN81_X64_ENTERPRISE_CHECKSUM ?= 8fb332a827998f807a1346bef55969c6519668b9
WIN81_X86_ENTERPRISE ?= iso/en_windows_8.1_enterprise_with_update_x86_dvd_4065185.iso
WIN81_X86_ENTERPRISE_CHECKSUM ?= fe43558b4708b4b786bc3286924813b0aad21106
WIN81_X64_PRO ?= iso/en_windows_8.1_professional_vl_with_update_x64_dvd_4065194.iso
WIN81_X64_PRO_CHECKSUM ?= e50a6f0f08e933f25a71fbc843827fe752ed0365
WIN81_X86_PRO ?= iso/en_windows_8.1_professional_vl_with_update_x86_dvd_4065201.iso
WIN81_X86_PRO_CHECKSUM ?= c2d6f5d06362b7cb17dfdaadfb848c760963b254

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

win7: win7-openssh win7-cygwin

win7-openssh: win7x64-enterprise win7x64-pro win7x86-enterprise win7x86-pro

win7-cygwin: win7x64-enterprise-cygwin win7x64-pro-cygwin win7x86-enterprise-cygwin win7x86-pro-cygwin

test-win7: test-win7-openssh test-win7-cygwin

test-win7-openssh: test-win7x64-enterprise test-win7x64-pro test-win7x86-enterprise test-win7x86-pro

test-win7-cygwin: test-win7x64-enterprise-cygwin test-win7x64-pro-cygwin test-win7x86-enterprise-cygwin test-win7x86-pro-cygwin

win8: win8-openssh win8-cygwin

win8-openssh: win8x64-enterprise win8x64-pro win8x86-enterprise win8x86-pro

win8-cygwin: win8x64-enterprise-cygwin win8x64-pro-cygwin win8x86-enterprise-cygwin win8x86-pro-cygwin

test-win8: test-win8-openssh test-win8-cygwin

test-win8-openssh: test-win8x64-enterprise test-win8x64-pro test-win8x86-enterprise test-win8x86-pro

test-win8-cygwin: test-win8x64-enterprise-cygwin test-win8x64-pro-cygwin test-win8x86-enterprise-cygwin test-win8x86-pro-cygwin

win81: win81-openssh win81-cygwin

win81-openssh: win81x64-enterprise win81x64-pro win81x86-enterprise win81x86-pro

win81-cygwin: win81x64-enterprise-cygwin win81x64-pro-cygwin win81x86-enterprise-cygwin win81x86-pro-cygwin

test-win81: test-win81-openssh test-win81-cygwin

test-win81-openssh: test-win81x64-enterprise test-win81x64-pro test-win81x86-enterprise test-win81x86-pro

test-win81-cygwin: test-win81x64-enterprise-cygwin test-win81x64-pro-cygwin test-win81x86-enterprise-cygwin test-win81x86-pro-cygwin


# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-vmware-iso
#       mkdir -p $(VMWARE_BOX_DIR)
#       packer build -only=vmware-iso $(PACKER_VARS) $<

$(VMWARE_BOX_DIR)/win2008r2-datacenter$(BOX_SUFFIX): win2008r2-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-enterprise$(BOX_SUFFIX): win2008r2-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-standard$(BOX_SUFFIX): win2008r2-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-web$(BOX_SUFFIX): win2008r2-web.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-datacenter-cygwin$(BOX_SUFFIX): win2008r2-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-enterprise-cygwin$(BOX_SUFFIX): win2008r2-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-standard-cygwin$(BOX_SUFFIX): win2008r2-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2008r2-web-cygwin$(BOX_SUFFIX): win2008r2-web-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012-datacenter$(BOX_SUFFIX): win2012-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012-standard$(BOX_SUFFIX): win2012-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012-datacenter-cygwin$(BOX_SUFFIX): win2012-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012-standard-cygwin$(BOX_SUFFIX): win2012-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012r2-datacenter$(BOX_SUFFIX): win2012r2-datacenter.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012r2-standard$(BOX_SUFFIX): win2012r2-standard.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012r2-datacenter-cygwin$(BOX_SUFFIX): win2012r2-datacenter-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win2012r2-standard-cygwin$(BOX_SUFFIX): win2012r2-standard-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x64-enterprise$(BOX_SUFFIX): win7x64-enterprise.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" -var "iso_checksum=$(WIN7_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x86-enterprise$(BOX_SUFFIX): win7x86-enterprise.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" -var "iso_checksum=$(WIN7_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x64-pro$(BOX_SUFFIX): win7x64-pro.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" -var "iso_checksum=$(WIN7_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x86-pro$(BOX_SUFFIX): win7x86-pro.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" -var "iso_checksum=$(WIN7_X86_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x64-enterprise-cygwin$(BOX_SUFFIX): win7x64-enterprise-cygwin.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" -var "iso_checksum=$(WIN7_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x86-enterprise-cygwin$(BOX_SUFFIX): win7x86-enterprise-cygwin.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" -var "iso_checksum=$(WIN7_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x64-pro-cygwin$(BOX_SUFFIX): win7x64-pro-cygwin.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" -var "iso_checksum=$(WIN7_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win7x86-pro-cygwin$(BOX_SUFFIX): win7x86-pro-cygwin.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" -var "iso_checksum=$(WIN7_X86_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x64-enterprise$(BOX_SUFFIX): win8x64-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" -var "iso_checksum=$(WIN8_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x64-pro$(BOX_SUFFIX): win8x64-pro.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" -var "iso_checksum=$(WIN8_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x86-enterprise$(BOX_SUFFIX): win8x86-enterprise.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" -var "iso_checksum=$(WIN8_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x86-pro$(BOX_SUFFIX): win8x86-pro.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" -var "iso_checksum=$(WIN8_X86_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x64-enterprise-cygwin$(BOX_SUFFIX): win8x64-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" -var "iso_checksum=$(WIN8_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x64-pro-cygwin$(BOX_SUFFIX): win8x64-pro-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" -var "iso_checksum=$(WIN8_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x86-enterprise-cygwin$(BOX_SUFFIX): win8x86-enterprise-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" -var "iso_checksum=$(WIN8_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win8x86-pro-cygwin$(BOX_SUFFIX): win8x86-pro-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" -var "iso_checksum=$(WIN8_X86_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x64-enterprise$(BOX_SUFFIX): win81x64-enterprise.json floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" -var "iso_checksum=$(WIN81_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x86-enterprise$(BOX_SUFFIX): win81x86-enterprise.json floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" -var "iso_checksum=$(WIN81_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x64-pro$(BOX_SUFFIX): win81x64-pro.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" -var "iso_checksum=$(WIN81_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x86-pro$(BOX_SUFFIX): win81x86-pro.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" -var "iso_checksum=$(WIN81_X86_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x64-enterprise-cygwin$(BOX_SUFFIX): win81x64-enterprise-cygwin.json floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" -var "iso_checksum=$(WIN81_X64_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x86-enterprise-cygwin$(BOX_SUFFIX): win81x86-enterprise-cygwin.json floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" -var "iso_checksum=$(WIN81_X86_ENTERPRISE_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x64-pro-cygwin$(BOX_SUFFIX): win81x64-pro-cygwin.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" -var "iso_checksum=$(WIN81_X64_PRO_CHECKSUM)" $<

$(VMWARE_BOX_DIR)/win81x86-pro-cygwin$(BOX_SUFFIX): win81x86-pro-cygwin.json floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	packer build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" -var "iso_checksum=$(WIN81_X86_PRO_CHECKSUM)" $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-virtualbox-iso
#       mkdir -p $(VIRTUALBOX_BOX_DIR)
#       packer build -only=virtualbox-iso $(PACKER_VARS) $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-datacenter$(BOX_SUFFIX): win2008r2-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$VIRTUALBOX_BOX_DIR)/win2008r2-enterprise$(BOX_SUFFIX): win2008r2-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-standard$(BOX_SUFFIX): win2008r2-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-web$(BOX_SUFFIX): win2008r2-web.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-datacenter-cygwin$(BOX_SUFFIX): win2008r2-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-enterprise-cygwin$(BOX_SUFFIX): win2008r2-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-standard-cygwin$(BOX_SUFFIX): win2008r2-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2008r2-web-cygwin$(BOX_SUFFIX): win2008r2-web-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2008R2_X64)" -var "iso_checksum=$(WIN2008R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-datacenter$(BOX_SUFFIX): win2012-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-standard$(BOX_SUFFIX): win2012-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-datacenter-cygwin$(BOX_SUFFIX): win2012-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012-standard-cygwin$(BOX_SUFFIX): win2012-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012_X64)" -var "iso_checksum=$(WIN2012_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-datacenter$(BOX_SUFFIX): win2012r2-datacenter.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-standard$(BOX_SUFFIX): win2012r2-standard.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-datacenter-cygwin$(BOX_SUFFIX): win2012r2-datacenter-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win2012r2-standard-cygwin$(BOX_SUFFIX): win2012r2-standard-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN2012R2_X64)" -var "iso_checksum=$(WIN2012R2_X64_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-enterprise$(BOX_SUFFIX): win7x64-enterprise.json $(SOURCES) floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" -var "iso_checksum=$(WIN7_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-enterprise$(BOX_SUFFIX): win7x86-enterprise.json $(SOURCES) floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" -var "iso_checksum=$(WIN7_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-pro$(BOX_SUFFIX): win7x64-pro.json $(SOURCES) floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" -var "iso_checksum=$(WIN7_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-pro$(BOX_SUFFIX): win7x86-pro.json $(SOURCES) floppy/win7x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" -var "iso_checksum=$(WIN7_X86_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-enterprise-cygwin$(BOX_SUFFIX): win7x64-enterprise-cygwin.json floppy/win7x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_ENTERPRISE)" -var "iso_checksum=$(WIN7_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-enterprise-cygwin$(BOX_SUFFIX): win7x86-enterprise-cygwin.json floppy/win7x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_ENTERPRISE)" -var "iso_checksum=$(WIN7_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x64-pro-cygwin$(BOX_SUFFIX): win7x64-pro-cygwin.json floppy/win7x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X64_PRO)" -var "iso_checksum=$(WIN7_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win7x86-pro-cygwin$(BOX_SUFFIX): win7x86-pro-cygwin.json floppy/win7x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN7_X86_PRO)" -var "iso_checksum=$(WIN7_X86_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-enterprise$(BOX_SUFFIX): win8x64-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" -var "iso_checksum=$(WIN8_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-pro$(BOX_SUFFIX): win8x64-pro.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" -var "iso_checksum=$(WIN8_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-enterprise$(BOX_SUFFIX): win8x86-enterprise.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" -var "iso_checksum=$(WIN8_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-pro$(BOX_SUFFIX): win8x86-pro.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" -var "iso_checksum=$(WIN8_X86_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-enterprise-cygwin$(BOX_SUFFIX): win8x64-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_ENTERPRISE)" -var "iso_checksum=$(WIN8_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x64-pro-cygwin$(BOX_SUFFIX): win8x64-pro-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X64_PRO)" -var "iso_checksum=$(WIN8_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-enterprise-cygwin$(BOX_SUFFIX): win8x86-enterprise-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_ENTERPRISE)" -var "iso_checksum=$(WIN8_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win8x86-pro-cygwin$(BOX_SUFFIX): win8x86-pro-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN8_X86_PRO)" -var "iso_checksum=$(WIN8_X86_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-enterprise$(BOX_SUFFIX): win81x64-enterprise.json $(SOURCES) floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" -var "iso_checksum=$(WIN81_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-enterprise$(BOX_SUFFIX): win81x86-enterprise.json $(SOURCES) floppy/win81x86-enterprise/Autounattend.xml

	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" -var "iso_checksum=$(WIN81_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-pro$(BOX_SUFFIX): win81x64-pro.json $(SOURCES) floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" -var "iso_checksum=$(WIN81_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-pro$(BOX_SUFFIX): win81x86-pro.json $(SOURCES) floppy/win81x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" -var "iso_checksum=$(WIN81_X86_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-enterprise-cygwin$(BOX_SUFFIX): win81x64-enterprise-cygwin.json $(SOURCES) floppy/win81x64-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_ENTERPRISE)" -var "iso_checksum=$(WIN81_X64_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-enterprise-cygwin$(BOX_SUFFIX): win81x86-enterprise-cygwin.json $(SOURCES) floppy/win81x86-enterprise/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_ENTERPRISE)" -var "iso_checksum=$(WIN81_X86_ENTERPRISE_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x64-pro-cygwin$(BOX_SUFFIX): win81x64-pro-cygwin.json $(SOURCES) floppy/win81x64-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X64_PRO)" -var "iso_checksum=$(WIN81_X64_PRO_CHECKSUM)" $<

$(VIRTUALBOX_BOX_DIR)/win81x86-pro-cygwin$(BOX_SUFFIX): win81x86-pro-cygwin.json $(SOURCES) floppy/win81x86-pro/Autounattend.xml
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	packer build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(WIN81_X86_PRO)" -var "iso_checksum=$(WIN81_X86_PRO_CHECKSUM)" $<

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
