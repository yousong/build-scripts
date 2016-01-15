#!/bin/sh -e
#
# Requires Apache Portable Runtime @apr
#
PKG_NAME=apr-util
PKG_VERSION=1.5.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.us.apache.org/dist//apr/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2202b18f269ad606d70e1864857ed93c
PKG_DEPENDS='apr'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# $3 (implicit-install-check) for APR_FIND_APR should be set to 1
	patch -p0 <<"EOF"
--- build/apu-conf.m4.config	2016-01-03 02:04:12.738405124 +0800
+++ build/apu-conf.m4	2016-01-03 02:04:16.646405270 +0800
@@ -25,7 +25,7 @@ dnl
 AC_DEFUN([APU_FIND_APR], [
 
   dnl use the find_apr.m4 script to locate APR. sets apr_found and apr_config
-  APR_FIND_APR(,,,[1])
+  APR_FIND_APR(,,[1],[1])
   if test "$apr_found" = "no"; then
     AC_MSG_ERROR(APR could not be located. Please use the --with-apr option.)
   fi
EOF
}

configure_pre() {
	cd "$PKG_BUILD_DIR"
	autoconf_fixup
}

CONFIGURE_ARGS='			\
	--enable-layout=GNU		\
'
