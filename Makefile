#
# Copyright 2015-2016 (c) Yousong Zhou
#
TOPDIR:=${CURDIR}
TMP_DIR?=$(TOPDIR)/tmp
STAMP_DIR?=$(TMP_DIR)/stamp
LOG_DIR?=$(TMP_DIR)/log
TESTS_DIR:=$(TOPDIR)/tests_dir

NO_TRACE_MAKE=$(MAKE) --no-print-directory

genmake: $(TMP_DIR)/Makefile

names:=$(patsubst $(TOPDIR)/build-%.sh,%,$(wildcard $(TOPDIR)/build-*.sh))
$(TMP_DIR)/Makefile: $(patsubst %,$(TMP_DIR)/include/Makefile.%.mk,$(names))
	@rm -f $(TMP_DIR)/Makefile
	@for mk in $^; do	\
		echo "include $$mk" >>$(TMP_DIR)/Makefile;		\
	done

$(TMP_DIR)/include/Makefile.%.mk: $(TOPDIR)/build-%.sh | $(TMP_DIR)/include
	@"$(TOPDIR)/build-$*.sh" genmake >"$@.tmp"
	@mv "$@.tmp" "$@"

$(TMP_DIR)/include:
	@mkdir -p "$@"

%/test: export TMP_DIR=$(TESTS_DIR)/tmp
%/test: export LOG_DIR=$(TMP_DIR)/log
%/test: export STAMP_DIR=$(TMP_DIR)/stamp
%/test:
	+@INSTALL_PREFIX="$(TESTS_DIR)/install" \
	BASE_DESTDIR="$(TESTS_DIR)/dest_dir" \
	BASE_BUILD_DIR="$(TESTS_DIR)/build_dir" \
	OLDPATH="$(PATH)" \
	PATH="$(TESTS_DIR)/install/bin:$(TESTS_DIR)/install/sbin:$(PATH)" \
	$(NO_TRACE_MAKE) $*

toolchain/test:
	+@for arch in	i686 x86_64 \
			mips mipsel mips64 mips64el \
			aarch64 aarch64_be \
			; do \
		echo "> $$arch linux-gnu" >&2; \
		TRI_ARCH=$$arch TRI_OPSYS=linux-gnu $(NO_TRACE_MAKE) gcc-cross-pass2/install/test; \
	done; \
	for arch in arm armeb; do \
		for opsys in linux-gnueabi linux-gnueabihf; do \
			echo "> $$arch $$opsys" >&2; \
			TRI_ARCH=$$arch TRI_OPSYS=$$opsys $(NO_TRACE_MAKE) gcc-cross-pass2/install/test; \
		done \
	done

.PHONY: genmake
.PHONY: download staging archive install

bs_DIRS :=
define rule_mkdir
  ifeq ($(filter $(bs_DIRS),$(1)),)
    $(1):
	@mkdir -p $(1)
    bs_DIRS += $(1)
  endif
endef

ifeq ($(filter genmake %/test,$(MAKECMDGOALS)),)
-include $(TMP_DIR)/Makefile
endif
