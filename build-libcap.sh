#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libcap
PKG_VERSION=2.25
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6666b839e5d46c2ad33fc8aa2ceb5f77

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- libcap/cap_file.c.orig	2016-12-05 18:16:32.644000925 +0800
+++ libcap/cap_file.c	2016-12-05 18:17:34.067001292 +0800
@@ -9,6 +9,10 @@
 #include <sys/stat.h>
 #include <unistd.h>
 #include <linux/xattr.h>
+#ifndef XATTR_NAME_CAPS
+// linux/capability.h is the old path but will be preceded over by the copy bundled with libcap
+#define XATTR_NAME_CAPS "security." "capability"
+#endif
 
 /*
  * We hardcode the prototypes for the Linux system calls here since
EOF
}

configure() {
	true
}

# When installing setcap, set its inheritable bit to be able to place
# capabilities on files. It can be used in conjunction with pam_cap
# (associated with su and certain users say) to make it useful for
# specially blessed users. If you wish to drop this install feature,
# use this command when running install
#
#    make RAISE_SETFCAP=no install
#
MAKE_VARS+=(
	prefix="$INSTALL_PREFIX"
	RAISE_SETFCAP=no
)
