#

ifneq ("$(wildcard ../urls.mk)", "")
        include ../urls.mk
endif

EVAL_WIN10_X64_NAME     ?= $(shell basename $(EVAL_WIN10_X64))
EVAL_WIN10_X86_NAME     ?= $(shell basename $(EVAL_WIN10_X86))
EVAL_WIN2008R2_X64_NAME ?= $(shell basename $(EVAL_WIN2008R2_X64))
# @todo:
#EVAL_WIN2012_X64_NAME   ?= $(shell basename $(EVAL_WIN2012_X64))
EVAL_WIN2012R2_X64_NAME ?= $(shell basename $(EVAL_WIN2012R2_X64))
EVAL_WIN2016_X64_NAME   ?= $(shell basename $(EVAL_WIN2016_X64))
EVAL_WIN7_X64_NAME      ?= $(shell basename ${EVAL_WIN7_X64})
EVAL_WIN7_X86_NAME      ?= $(shell basename $(EVAL_WIN7_X86))
EVAL_WIN81_X64_NAME     ?= $(shell basename $(EVAL_WIN81_X64))
EVAL_WIN81_X86_NAME     ?= $(shell basename $(EVAL_WIN81_X86))
EVAL_WIN8_X64_NAME      ?= $(shell basename $(EVAL_WIN8_X64))

WGET ?= wget

help:
	@echo make hashes
	@echo make help
	@echo make isos
	@echo make md5s
	@echo make sha1s
	@echo make sha256s

isos:	\
	$(EVAL_WIN10_X64_NAME) \
	$(EVAL_WIN10_X86_NAME) \
	$(EVAL_WIN2008R2_X64_NAME) \
	$(EVAL_WIN2012R2_X64_NAME) \
	$(EVAL_WIN2016_X64_NAME) \
	$(EVAL_WIN7_X64_NAME) \
	$(EVAL_WIN7_X86_NAME) \
	$(EVAL_WIN81_X64_NAME) \
	$(EVAL_WIN81_X86_NAME) \
	$(EVAL_WIN8_X64_NAME)

$(EVAL_WIN10_X64_NAME):
	$(WGET) $(EVAL_WIN10_X64)

$(EVAL_WIN10_X86_NAME):
	$(WGET) $(EVAL_WIN10_X86)

$(EVAL_WIN2008R2_X64_NAME):
	$(WGET) $(EVAL_WIN2008R2_X64)

$(EVAL_WIN2012_X64_NAME):
	$(WGET) $(EVAL_WIN2012_X64)

$(EVAL_WIN2012R2_X64_NAME):
	$(WGET) $(EVAL_WIN2012R2_X64)

$(EVAL_WIN2016_X64_NAME):
	$(WGET) $(EVAL_WIN2016_X64)

$(EVAL_WIN7_X64_NAME):
	$(WGET) $(EVAL_WIN7_X64)

$(EVAL_WIN7_X86_NAME):
	$(WGET) $(EVAL_WIN7_X86)

$(EVAL_WIN81_X64_NAME):
	$(WGET) $(EVAL_WIN81_X64)

$(EVAL_WIN81_X86_NAME):
	$(WGET) $(EVAL_WIN81_X86)

$(EVAL_WIN8_X64_NAME):
	$(WGET) $(EVAL_WIN8_X64)

sha1s:
	-rm -f sha1sums.txt.old
	-test -f sha1sums.txt && mv sha1sums.txt sha1sums.txt.old || true
	sha1sum   *.[iI][sS][oO] | tee sha1sums.txt

md5s:
	-rm -f md5sums.txt.old
	-test -f md5sums.txt && mv md5sums.txt md5sums.txt.old || true
	md5sum    *.[iI][sS][oO] | tee md5sums.txt

sha256s:
	-rm -f sha256sums.txt.old
	-test -f sha256sums.txt && mv sha256sums.txt sha256sums.txt.old || true
	sha256sum *.[iI][sS][oO] | tee sha256sums.txt

hashes: sha1s

.PHONY: hashes
.PHONY: help
.PHONY: isos
.PHONY: md5s
.PHONY: sha1s
.PHONY: sha256s
