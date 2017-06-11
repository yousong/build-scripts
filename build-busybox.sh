#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Install a statically linked busybox binary to $INSTALL_PREFIX/bin
#
# Static busybox needs static library dependencies and on CentOS6 we need
#
#	yum install -y glibc-static
#
# In case those applets are installed accidentally as symbolic links
#
#	for f in $(find . -type l) ; do i="$(readlink -f "$f")"; i="$(basename "$i")"; [ "$i" = busybox ] && rm -vf $f; done
#
PKG_NAME=busybox
PKG_VERSION=1.26.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://busybox.net/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bb59d25ee2643db20f212eec539429f1
PKG_PLATFORM=linux

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"

EXTRA_CFLAGS=()
EXTRA_CPPFLAGS=()
EXTRA_LDFLAGS=()

do_patch() {

	cd "$PKG_SOURCE_DIR"

	# the bug can be worked around by enabling undo feature
	patch -p1 <<"EOF"
From 5f7421e48f49245bcc542b64db32d7edfbc8b27f Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Mon, 13 Feb 2017 10:36:41 +0800
Subject: [PATCH] vi: avoid touching a new file with ZZ when no editing has
 been done

This is the behaviour observed with standard vim and busybox vi of at
least 1.22.1.  It was changed with commit "32afd3a vi: some
simplifications" which happened before 1.23.0.

Mistyping filename on command line happens fairly often and it's better
we restore the old behaviour to avoid a few unnecessary flash writes and
sometimes efforts of debugging bugs caused by those unneeded stray
files...

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 editors/vi.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/editors/vi.c b/editors/vi.c
index bbaac50..4b5b7cd 100644
--- a/editors/vi.c
+++ b/editors/vi.c
@@ -715,14 +715,6 @@ static int init_text_buffer(char *fn)
 {
 	int rc;
 
-	flush_undo_data();
-	modified_count = 0;
-	last_modified_count = -1;
-#if ENABLE_FEATURE_VI_YANKMARK
-	/* init the marks */
-	memset(mark, 0, sizeof(mark));
-#endif
-
 	/* allocate/reallocate text buffer */
 	free(text);
 	text_size = 10240;
@@ -737,6 +729,14 @@ static int init_text_buffer(char *fn)
 		// file doesnt exist. Start empty buf with dummy line
 		char_insert(text, '\n', NO_UNDO);
 	}
+
+	flush_undo_data();
+	modified_count = 0;
+	last_modified_count = -1;
+#if ENABLE_FEATURE_VI_YANKMARK
+	/* init the marks */
+	memset(mark, 0, sizeof(mark));
+#endif
 	return rc;
 }
 
EOF
}

configure() {
	cd "$PKG_BUILD_DIR"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	# 1. link statically
	# 2. syncfs() for fancy sync is not available in debian wheezy 3.2.0 kernel, so disable it
	make defconfig
	kconfig_set_option CONFIG_STATIC y
	kconfig_set_option CONFIG_FEATURE_SYNC_FANCY n
	kconfig_set_option CONFIG_INSTALL_APPLET_SYMLINKS n
	kconfig_set_option CONFIG_INSTALL_APPLET_DONT y
	kconfig_set_option CONFIG_PREFIX "\"$PKG_STAGING_DIR/$INSTALL_PREFIX\""
	#
	# The setns() system call first appeared in Linux in kernel 3.0;
	# library support was added to glibc in version 2.14.
	kconfig_set_option CONFIG_NSENTER n
}

#MAKE_VARS+=(
#	V=1
#)
