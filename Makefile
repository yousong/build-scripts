TOPDIR:=${CURDIR}
TMP_DIR?=$(TOPDIR)/tmp
TESTS_DIR:=$(TOPDIR)/tests_dir

genmake: $(TMP_DIR)/Makefile

names:=$(patsubst $(TOPDIR)/build-%.sh,%,$(wildcard $(TOPDIR)/build-*.sh))
$(TMP_DIR)/Makefile: $(patsubst %,$(TMP_DIR)/include/Makefile.%.mk,$(names))
	rm -f $(TMP_DIR)/Makefile
	for mk in $^; do	\
		echo "include $$mk" >>$(TMP_DIR)/Makefile;		\
	done

$(TMP_DIR)/include/Makefile.%.mk: $(TOPDIR)/build-%.sh
	mkdir -p $(TMP_DIR)/include
	b="$(TOPDIR)/build-$*.sh";					\
	name=`basename $$b`;						\
	name=$${name#*-};						\
	name=$${name%.sh};						\
	$$b genmake >$(TMP_DIR)/include/Makefile.$$name.mk;		\

%/test:
	TMP_DIR="$(TESTS_DIR)/tmp" \
	STAMP_DIR="$(TESTS_DIR)/tmp/stamp" \
	INSTALL_PREFIX="$(TESTS_DIR)/install" \
	BASE_DESTDIR="$(TESTS_DIR)/dest_dir" \
	BASE_BUILD_DIR="$(TESTS_DIR)/build_dir" \
	PATH="$(TESTS_DIR)/install/bin:$(TESTS_DIR)/install/sbin:$(PATH)" \
	$(MAKE) $*

ifeq ($(filter genmake %/test,$(MAKECMDGOALS)),)
  -include $(TMP_DIR)/Makefile
endif

.PHONY: genmake
.PHONY: download staging archive install
