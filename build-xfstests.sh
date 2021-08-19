#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Dependencies
#
# 	util-linux: libuuid
#
# Check README file in the source code for additional devel packages to install
# for building it
#
PKG_NAME=xfstests
PKG_VERSION=2021-08-16
PKG_SOURCE_VERSION=ae8c30c34c51b5a5c5dd1639ec83ef901a40b3ad
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git/snapshot/xfstests-dev-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux
PKG_DEPENDS='util-linux xfsprogs'

. "$PWD/env.sh"

# set but with null value so that install-sh do not prepend DESTDIR again
MAKE_ENVS+=(
	DIST_ROOT=
)

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
PKG_LIB_DIR and others in include/builddefs already have DESTDIR prepended.
Install-sh should not prepend DESTDIR again.

--- include/install-sh.orig	2021-08-19 11:40:45.931130046 +0000
+++ include/install-sh	2021-08-19 11:41:03.376406859 +0000
@@ -86,7 +86,7 @@ REAL_UID=$OWNER
 INSTALL=true
 MANIFEST=:
 
-: ${DIST_ROOT:=${DESTDIR}}
+: ${DIST_ROOT=${DESTDIR}}
 
 [ -n "$DIST_MANIFEST" -a -z "$DIST_ROOT" ] && INSTALL=false
 [ -n "$DIST_MANIFEST" ] && MANIFEST="_manifest"
EOF
}

configure_pre() {
	# Generate configure script from configure.ac, etc.  Let Makefile of
	# the package itself handle this.  It does copying of
	# include/install-sh to the right place among other things
	cd "$PKG_BUILD_DIR"
	"${MAKEJ[@]}" configure
}
