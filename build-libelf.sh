#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libelf
PKG_VERSION=0.8.13
PKG_SOURCE="libelf-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.mr511.de/software/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4136d7b4c04df68b686570afa26988ac

. "$PWD/env.sh"

MAKE_VARS+=(
	instroot="$PKG_STAGING_DIR"
)

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
Fixes "make install" between curdir and curdir/lib/

	mkdir: cannot create directory `/home/yousong/git-repo/build-scripts/tests_dir/dest_dir/libelf-0.8.13-install/home/yousong': File exists

--- mkinstalldirs.orig	2017-06-08 12:53:44.353084356 +0800
+++ mkinstalldirs	2017-06-08 12:53:52.041086760 +0800
@@ -23,7 +23,7 @@ for file in ${1+"$@"} ; do
 
      if test ! -d "${pathcomp}"; then
         echo "mkdir $pathcomp" 1>&2
-        mkdir "${pathcomp}" || errstatus=$?
+        mkdir -p "${pathcomp}" || errstatus=$?
      fi
 
      pathcomp="${pathcomp}/"
EOF
}
