#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=crun
PKG_VERSION=0.10.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://github.com/containers/crun/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_VERSION=3547c7691742c6eaa31f8402e0ccbb81387c1b99
PKG_DEPENDS='libcap libseccomp libyajl'
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- configure.ac.orig	2019-10-12 03:20:09.799098779 +0000
+++ configure.ac	2019-10-12 03:20:11.767098363 +0000
@@ -31,7 +31,7 @@ AC_SEARCH_LIBS(sd_listen_fds, [systemd],
 AC_DEFINE([HAVE_SELINUX], 1, [Define if SELinux is available])
 AC_DEFINE([HAVE_APPARMOR], 1, [Define if AppArmor is available])
 
-AC_SEARCH_LIBS(yajl_tree_get, [yajl], [AC_DEFINE([HAVE_YAJL], 1, [Define if libyajl is available])], [AC_MSG_ERROR([*** libyajl headers not found])])
+AC_SEARCH_LIBS(yajl_tree_get, [yajl yajl_s], [AC_DEFINE([HAVE_YAJL], 1, [Define if libyajl is available])], [AC_MSG_ERROR([*** libyajl headers not found])])
 
 
 AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
EOF
}

CONFIGURE_ARGS+=(
	--disable-silent-rules
)

configure_static_build() {
	# required to let AC_SEARCH_LIBS ignore libyajl.so and continue to libyajl_s.a
	configure_static_build_default

	CONFIGURE_VARS+=(
		CRUN_LDFLAGS="-all-static"
	)
}
