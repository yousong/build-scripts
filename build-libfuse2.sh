#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libfuse2
PKG_VERSION=2.9.9
PKG_SOURCE="fuse-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/libfuse/libfuse/releases/download/fuse-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8000410aadc9231fd48495f7642f3312

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- util/Makefile.in.orig	2022-06-06 13:28:24.950391082 +0000
+++ util/Makefile.in	2022-06-06 13:28:27.277428370 +0000
@@ -736,11 +736,6 @@ mount_util.c: $(top_srcdir)/lib/mount_ut
 
 install-exec-hook:
 	-chmod u+s $(DESTDIR)$(bindir)/fusermount
-	@if test ! -e $(DESTDIR)/dev/fuse; then \
-		$(MKDIR_P) $(DESTDIR)/dev; \
-		echo "mknod $(DESTDIR)/dev/fuse -m 0666 c 10 229 || true"; \
-		mknod $(DESTDIR)/dev/fuse -m 0666 c 10 229 || true; \
-	fi
 
 install-exec-local:
 	$(MKDIR_P) $(DESTDIR)$(MOUNT_FUSE_PATH)
EOF
}

CONFIGURE_VARS+=(
	MOUNT_FUSE_PATH="$INSTALL_PREFIX/sbin"
	UDEV_RULES_PATH="$INSTALL_PREFIX/etc/udev/rules.d"
	INIT_D_PATH="$INSTALL_PREFIX/etc/init.d"
)
