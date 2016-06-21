#
# Copyright 2015-2016 (c) Yousong Zhou
#
TOPDIR:=${CURDIR}
TMP_DIR?=$(TOPDIR)/tmp
STAMP_DIR?=$(TMP_DIR)/stamp
LOG_DIR?=$(TMP_DIR)/log
TESTS_DIR:=$(TOPDIR)/tests_dir

genmake: $(TMP_DIR)/Makefile

names:=$(patsubst $(TOPDIR)/build-%.sh,%,$(wildcard $(TOPDIR)/build-*.sh))
$(TMP_DIR)/Makefile: $(patsubst %,$(TMP_DIR)/include/Makefile.%.mk,$(names))
	rm -f $(TMP_DIR)/Makefile
	for mk in $^; do	\
		echo "include $$mk" >>$(TMP_DIR)/Makefile;		\
	done

$(TMP_DIR)/include/Makefile.%.mk: $(TOPDIR)/build-%.sh | $(TMP_DIR)/include
	"$(TOPDIR)/build-$*.sh" genmake >"$@.tmp"
	mv "$@.tmp" "$@"

$(TMP_DIR)/include:
	mkdir -p "$@"

%/test:
	TMP_DIR="$(TESTS_DIR)/tmp" \
	STAMP_DIR="$(TESTS_DIR)/tmp/stamp" \
	LOG_DIR="$(TESTS_DIR)/tmp/log" \
	INSTALL_PREFIX="$(TESTS_DIR)/install" \
	BASE_DESTDIR="$(TESTS_DIR)/dest_dir" \
	BASE_BUILD_DIR="$(TESTS_DIR)/build_dir" \
	PATH="$(TESTS_DIR)/install/bin:$(TESTS_DIR)/install/sbin:$(PATH)" \
	$(MAKE) $*

ifeq ($(filter genmake %/test,$(MAKECMDGOALS)),)
$(STAMP_DIR) $(LOG_DIR):
	mkdir -p $@

-include $(TMP_DIR)/Makefile
endif

.PHONY: genmake
.PHONY: download staging archive install
