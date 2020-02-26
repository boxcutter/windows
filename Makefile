# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
        include Makefile.local
endif

EVAL_WIN7_X64 ?= http://care.dlservice.microsoft.com/dl/download/evalx/win7/x64/EN/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
EVAL_WIN7_X64_CHECKSUM ?= 15ddabafa72071a06d5213b486a02d5b55cb7070
EVAL_WIN81_X64 ?= http://care.dlservice.microsoft.com/dl/download/B/9/9/B999286E-0A47-406D-8B3D-5B5AD7373A4A/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_ENTERPRISE_EVAL_EN-US-IR3_CENA_X64FREE_EN-US_DV9.ISO
EVAL_WIN81_X64_CHECKSUM ?= 7c7d99546077c805faae40a8864882c46f0ca141
EVAL_WIN2008R2_X64 ?= http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso
EVAL_WIN2008R2_X64_CHECKSUM ?= beed231a34e90e1dd9a04b3afabec31d62ce3889
EVAL_WIN2012R2_X64 ?= http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO
EVAL_WIN2012R2_X64_CHECKSUM ?= 849734f37346385dac2c101e4aacba4626bb141c

EVAL_WIN7_X86 ?= http://care.dlservice.microsoft.com/dl/download/evalx/win7/x86/EN/7600.16385.090713-1255_x86fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENEVAL_EN_DVD.iso
EVAL_WIN7_X86_CHECKSUM ?= 971fc00183a52c152fe924a6b99fdec011a871c2
EVAL_WIN81_X86 ?= http://care.dlservice.microsoft.com/dl/download/B/9/9/B999286E-0A47-406D-8B3D-5B5AD7373A4A/9600.17050.WINBLUE_REFRESH.140317-1640_X86FRE_ENTERPRISE_EVAL_EN-US-IR3_CENA_X86FREE_EN-US_DV9.ISO
EVAL_WIN81_X86_CHECKSUM ?= 4ddd0881779e89d197cb12c684adf47fd5d9e540
EVAL_WIN8_X64 ?= http://care.dlservice.microsoft.com/dl/download/5/3/C/53C31ED0-886C-4F81-9A38-F58CE4CE71E8/9200.16384.WIN8_RTM.120725-1247_X64FRE_ENTERPRISE_EVAL_EN-US-HRM_CENA_X64FREE_EN-US_DV5.ISO
EVAL_WIN8_X64_CHECKSUM ?= ae59e04462e4dc74e971d6e98d0cc1f2f3d63f1d

EVAL_WIN10_X64 ?= https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso
EVAL_WIN10_X64_CHECKSUM ?= a4ea45ec1282e85fc84af49acf7a8d649c31ac5c
EVAL_WIN10_X86 ?= https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x86FRE_en-us.iso
EVAL_WIN10_X86_CHECKSUM ?= ddb496534203cb98284e5484e0ad60af3c0efce7

EVAL_WIN2016_X64 ?= https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO
EVAL_WIN2016_X64_CHECKSUM ?= 772700802951b36c8cb26a61c040b9a8dc3816a3

# @todo:
EVAL_WIN2012_X64 ?= http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO
EVAL_WIN2012_X64_CHECKSUM ?= 922b365c3360ce630f6a4b4f2f3c79e66165c0fb

WIN2008R2_X64 ?= iso/en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso
WIN2008R2_X64_CHECKSUM ?= 7e7e9425041b3328ccf723a0855c2bc4f462ec57
WIN2012_X64 ?= iso/en_windows_server_2012_x64_dvd_915478.iso
WIN2012_X64_CHECKSUM ?= d09e752b1ee480bc7e93dfa7d5c3a9b8aac477ba
WIN2012R2_X64 ?= iso/en_windows_server_2012_r2_with_update_x64_dvd_6052708.iso
WIN2012R2_X64_CHECKSUM ?= 865494e969704be1c4496d8614314361d025775e
WIN2016_X64 ?= iso/en_windows_server_2016_x64_dvd_9718492.iso
WIN2016_X64_CHECKSUM ?= f185197af68fae4f0e06510a4579fc511ba27616
WIN7_X64_ENTERPRISE ?= iso/en_windows_7_enterprise_with_sp1_x64_dvd_u_677651.iso
WIN7_X64_ENTERPRISE_CHECKSUM ?= a491f985dccfb5863f31b728dddbedb2ff4df8d1
WIN7_X64_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677791.iso
WIN7_X64_PRO_CHECKSUM ?= 708e0338d4e2f094dfeb860347c84a6ed9e91d0c
WIN7_X86_ENTERPRISE ?= iso/en_windows_7_enterprise_with_sp1_x86_dvd_u_677710.iso
WIN7_X86_ENTERPRISE_CHECKSUM ?= 4e0450ac73ab6f9f755eb422990cd9c7a1f3509c
WIN7_X86_PRO ?= iso/en_windows_7_professional_with_sp1_vl_build_x86_dvd_u_677896.iso
WIN7_X86_PRO_CHECKSUM ?= d5bd65e1b326d728f4fd146878ee0d9a3da85075
WIN8_X64_ENTERPRISE ?= iso/en_windows_8_enterprise_x64_dvd_917522.iso
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

# Possible values for CM: (nocm | chef | chefdk | chef-workstation | salt | puppet)
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
ifdef HW_VERSION
	PACKER_VARS += -var 'hw_version=$(HW_VERSION)'
endif
ifdef CM_OPTIONS
	PACKER_VARS += -var 'cm_options=$(CM_OPTIONS)'
endif
ifdef CM_VERSION
	PACKER_VARS += -var 'cm_version=$(CM_VERSION)'
endif
ON_ERROR ?= cleanup
PACKER ?= packer
ifdef PACKER_DEBUG
	PACKER := PACKER_LOG=1 $(PACKER)
else
endif
BUILDER_TYPES ?= vmware virtualbox parallels hyperv
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
HYPERV_BOX_DIR := box/hyperv
VMWARE_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VMWARE_BOX_DIR)/$(box_filename))
VIRTUALBOX_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VIRTUALBOX_BOX_DIR)/$(box_filename))
PARALLELS_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(PARALLELS_BOX_DIR)/$(box_filename))
HYPERV_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(HYPERV_BOX_DIR)/$(box_filename))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
PARALLELS_OUTPUT := output-parallels-iso
HYPERV_OUTPUT := output-hyperv-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
PARALLELS_BUILDER := parallels-iso
HYPERV_BUILDER := hyperv-iso
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

$(PREFIX)$(1): $(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

$(PREFIX)$(1)-cygwin: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

$(PREFIX)$(1)-ssh: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-$(PREFIX)$(1): test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-$(PREFIX)$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-$(PREFIX)$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

s3cp-$(PREFIX)$(1): s3cp-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) s3cp-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

else

$(PREFIX)$(1): $(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

$(PREFIX)$(1)-cygwin: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

$(PREFIX)$(1)-ssh: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-$(PREFIX)$(1): test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-$(PREFIX)$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-$(PREFIX)$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

s3cp-$(PREFIX)$(1): s3cp-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

endif

vmware/$(PREFIX)$(1): $(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

vmware/$(PREFIX)$(1)-cygwin: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

vmware/$(PREFIX)$(1)-ssh: $(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

virtualbox/$(PREFIX)$(1): $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

virtualbox/$(PREFIX)$(1)-cygwin: $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

virtualbox/$(PREFIX)$(1)-ssh: $(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

parallels/$(PREFIX)$(1): $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

parallels/$(PREFIX)$(1)-cygwin: $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

parallels/$(PREFIX)$(1)-ssh: $(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

hyperv/$(PREFIX)$(1): $(HYPERV_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

hyperv/$(PREFIX)$(1)-cygwin: $(HYPERV_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

hyperv/$(PREFIX)$(1)-ssh: $(HYPERV_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-vmware/$(PREFIX)$(1): test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-vmware/$(PREFIX)$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-vmware/$(PREFIX)$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-virtualbox/$(PREFIX)$(1): test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-virtualbox/$(PREFIX)$(1)-cygwin: test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-virtualbox/$(PREFIX)$(1)-ssh: test-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-parallels/$(PREFIX)$(1): test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-parallels/$(PREFIX)$(1)-cygwin: test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-parallels/$(PREFIX)$(1)-ssh: test-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

test-hyperv/$(PREFIX)$(1): test-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

test-hyperv/$(PREFIX)$(1)-cygwin: test-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

test-hyperv/$(PREFIX)$(1)-ssh: test-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

ssh-vmware/$(PREFIX)$(1): ssh-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

ssh-vmware/$(PREFIX)$(1)-cygwin: ssh-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

ssh-vmware/$(PREFIX)$(1)-ssh: ssh-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

ssh-virtualbox/$(PREFIX)$(1): ssh-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

ssh-virtualbox/$(PREFIX)$(1)-cygwin: ssh-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

ssh-virtualbox/$(PREFIX)$(1)-ssh: ssh-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

ssh-parallels/$(PREFIX)$(1): ssh-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

ssh-parallels/$(PREFIX)$(1)-cygwin: ssh-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

ssh-parallels/$(PREFIX)$(1)-ssh: ssh-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

ssh-hyperv/$(PREFIX)$(1): ssh-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

ssh-hyperv/$(PREFIX)$(1)-cygwin: ssh-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX)

ssh-hyperv/$(PREFIX)$(1)-ssh: ssh-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX)

s3cp-vmware/$(PREFIX)$(1): s3cp-$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

s3cp-virtualbox/$(PREFIX)$(1): s3cp-$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

s3cp-parallels/$(PREFIX)$(1): s3cp-$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)

s3cp-hyperv/$(PREFIX)$(1): s3cp-$(HYPERV_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX)
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


win2016: win2016-winrm win2016-openssh win2016-cygwin

win2016-winrm: win2016-standard

win2016-openssh: win2016-standard-ssh

win2016-cygwin: win2016-standard-cygwin


test-win2016: test-win2016-winrm test-win2016-openssh test-win2016-cygwin

test-win2016-winrm: test-win2016-standard

test-win2016-openssh: test-win2016-standard-ssh

test-win2016-cygwin: test-win2016-standard-cygwin


eval: eval-winrm eval-openssh

eval-winrm: eval-win2012r2-datacenter eval-win2008r2-datacenter eval-win81x64-enterprise eval-win7x64-enterprise eval-win10x64-enterprise

eval-openssh: eval-win2012r2-datacenter-ssh eval-win2008r2-datacenter-ssh eval-win81x64-enterprise-ssh eval-win7x64-enterprise-ssh eval-win10x64-enterprise-ssh

test-eval-openssh: test-eval-win2012r2-datacenter test-eval-win2008r2-datacenter test-eval-win81x64-enterprise test-eval-win7x64-enterprise test-eval-win10x64-enterprise

define BUILDBOX

$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX): $(PREFIX)$(1).json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1).json

$(VMWARE_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX): $(PREFIX)$(1).json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1).json

$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX): $(PREFIX)$(1).json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1).json

$(HYPERV_BOX_DIR)/$(PREFIX)$(1)$(BOX_SUFFIX): $(PREFIX)$(1).json
	rm -rf $(HYPERV_OUTPUT)
	mkdir -p $(HYPERV_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(HYPERV_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1).json

$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX): $(PREFIX)$(1)-ssh.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-ssh.json

$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX): $(PREFIX)$(1)-ssh.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-ssh.json

$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX): $(PREFIX)$(1)-ssh.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-ssh.json

$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-ssh$(BOX_SUFFIX): $(PREFIX)$(1)-ssh.json
	rm -rf $(HYPERV_OUTPUT)
	mkdir -p $(HYPERV_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(HYPERV_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-ssh.json

$(VIRTUALBOX_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX): $(PREFIX)$(1)-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-cygwin.json

$(VMWARE_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX): $(PREFIX)$(1)-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-cygwin.json

$(PARALLELS_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX): $(PREFIX)$(1)-cygwin.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-cygwin.json

$(HYPERV_BOX_DIR)/$(PREFIX)$(1)-cygwin$(BOX_SUFFIX): $(PREFIX)$(1)-cygwin.json
	rm -rf $(HYPERV_OUTPUT)
	mkdir -p $(HYPERV_BOX_DIR)
	$(PACKER) build -on-error=$(ON_ERROR) --only=$(HYPERV_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(PREFIX)$(1)-cygwin.json
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

$(eval $(call BUILDBOX,win2016-standard,$(WIN2016_X64),$(WIN2016_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win2016-standard,$(EVAL_WIN2016_X64),$(EVAL_WIN2016_X64_CHECKSUM)))

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

$(eval $(call BUILDBOX,eval-win10x64-enterprise,$(EVAL_WIN10_X64),$(EVAL_WIN10_X64_CHECKSUM)))

$(eval $(call BUILDBOX,eval-win10x86-enterprise,$(EVAL_WIN10_X86),$(EVAL_WIN10_X86_CHECKSUM)))

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
	@echo "Prepend 'vmware/' or 'virtualbox/' or 'parallels/' or 'hyperv/' to build only one target platform:"
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

test-$(HYPERV_BOX_DIR)/%$(BOX_SUFFIX): $(HYPERV_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< hyperv hyperv $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< vmware_desktop $(VAGRANT_PROVIDER) $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

ssh-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb

ssh-$(HYPERV_BOX_DIR)/%$(BOX_SUFFIX): $(HYPERV_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< hyperv hyperv $(CURRENT_DIR)/test/*_spec.rb

S3_STORAGE_CLASS ?= REDUCED_REDUNDANCY
S3_ALLUSERS_ID ?= uri=http://acs.amazonaws.com/groups/global/AllUsers

s3cp-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VMWARE_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VIRTUALBOX_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(PARALLELS_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(HYPERV_BOX_DIR)/%$(BOX_SUFFIX): $(HYPERV_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(HYPERV_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-vmware: $(addprefix s3cp-,$(VMWARE_BOX_FILES))
s3cp-virtualbox: $(addprefix s3cp-,$(VIRTUALBOX_BOX_FILES))
s3cp-parallels: $(addprefix s3cp-,$(PARALLELS_BOX_FILES))
s3cp-hyperv: $(addprefix s3cp-,$(HYPERV_BOX_FILES))
