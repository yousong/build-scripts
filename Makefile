TOPDIR:=${CURDIR}
TMP_DIR?=$(TOPDIR)/tmp
TESTS_DIR:=$(TOPDIR)/tests_dir

genmake: $(TMP_DIR)/Makefile

# TODO
# 1. track Makefile.$name individually
# 2. track utils-.sh
$(TMP_DIR)/Makefile: env.sh $(wildcard $(TOPDIR)/build-*.sh)
$(TMP_DIR)/Makefile:
	rm -f $(TMP_DIR)/Makefile
	rm -rf $(TMP_DIR)/include
	mkdir -p $(TMP_DIR)/include
	for b in $(wildcard $(TOPDIR)/build-*.sh); do				\
		name=`basename $$b`;						\
		name=$${name#*-};						\
		name=$${name%.sh};						\
		$$b genmake >$(TMP_DIR)/include/Makefile.$$name.mk;		\
		echo "include $(TMP_DIR)/include/Makefile.$$name.mk" >>$(TMP_DIR)/Makefile;	\
	done

%/test:
	TMP_DIR="$(TESTS_DIR)/tmp" \
	STAMP_DIR="$(TESTS_DIR)/tmp/stamp" \
	INSTALL_PREFIX="$(TESTS_DIR)/install" \
	BASE_DESTDIR="$(TESTS_DIR)/dest_dir" \
	BASE_BUILD_DIR="$(TESTS_DIR)/build_dir" \
	PATH="$(TESTS_DIR)/install/bin:$(TESTS_DIR)/install/sbin:$(PATH)" \
	$(MAKE) $*

-include $(TMP_DIR)/Makefile

.PHONY: genmake
.PHONY: test
.PHONY: download staging archive install
