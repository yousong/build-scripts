#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=pdnsd
PKG_VERSION=1.2.9a
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-par.tar.gz"
PKG_SOURCE_URL="http://members.home.nl/p.a.rombouts/pdnsd/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2f3e705d59a0f9308ad9504b24400769
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- configure.in.orig	2016-03-11 14:45:29.283613685 +0800
+++ configure.in	2016-03-11 14:45:48.843618411 +0800
@@ -8,7 +8,7 @@ packagerelease=`cut -d - -f 2- "$srcdir"
 
 distribution="Generic"
 target="autodetect"
-cachedir="/var/cache/$package"
+cachedir="$prefix/var/cache/$package"
 ipv4_default=1
 have_ipv4="yes"
 #newrrs="yes"
@@ -64,8 +64,7 @@ esac
 esac
 
 AC_ARG_WITH(cachedir,
-[  --with-cachedir=dir         Default directory for pdnsd cache 
-                              (default=/var/cache/pdnsd)],
+[  --with-cachedir=dir         Default directory for pdnsd cache],
   cachedir=$withval)
 AC_DEFINE_UNQUOTED(CACHEDIR, "$cachedir")
 AC_SUBST(cachedir)
EOF
}
