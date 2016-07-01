#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=binutils-native
PKG_VERSION=2.26
PKG_SOURCE="binutils-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/binutils/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=64146a0faa3b411ba774f47d41de239f
PKG_DEPENDS="glibc-native"

. "$PWD/env.sh"

if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
	PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME"
fi

EXTRA_LDFLAGS="$EXTRA_LDFLAGS  -Wl,--dynamic-linker=$INSTALL_PREFIX/lib/ld-linux-x86-64.so.2"
CONFIGURE_PATH="$PKG_BUILD_DIR"
CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# patch from OpenWrt to install $tgt/lib/ldscripts to lib/ldscripts so that
	# we can link from $tgt/lib to ../lib to take in startfiles of libc
	patch -p1 <<"EOF"
--- a/ld/Makefile.am
+++ b/ld/Makefile.am
@@ -54,7 +54,7 @@ endif
 # We put the scripts in the directory $(scriptdir)/ldscripts.
 # We can't put the scripts in $(datadir) because the SEARCH_DIR
 # directives need to be different for native and cross linkers.
-scriptdir = $(tooldir)/lib
+scriptdir = $(libdir)
 
 EMUL = @EMUL@
 EMULATION_OFILES = @EMULATION_OFILES@
--- a/ld/Makefile.in
+++ b/ld/Makefile.in
@@ -386,7 +386,7 @@ AM_CFLAGS = $(WARN_CFLAGS)
 # We put the scripts in the directory $(scriptdir)/ldscripts.
 # We can't put the scripts in $(datadir) because the SEARCH_DIR
 # directives need to be different for native and cross linkers.
-scriptdir = $(tooldir)/lib
+scriptdir = $(libdir)
 BASEDIR = $(srcdir)/..
 BFDDIR = $(BASEDIR)/bfd
 INCDIR = $(BASEDIR)/include
EOF
}

clean() {
	rm -rf "$PKG_BUILD_DIR"
}


configure_pre() {
	mkdir -p "$PKG_BUILD_DIR"
}

# --with-sysroot is needed for quashing the error message "this linker was not
# configured to use sysroots"
CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
	--enable-plugins					\\
	--disable-multilib					\\
	--disable-werror					\\
	--disable-nls						\\
	--disable-sim						\\
	--disable-gdb						\\
"

staging_post() {
	local base="$PKG_STAGING_DIR$INSTALL_PREFIX"

	mkdir -p "$base/usr/include"
	ln -sf 'lib' "$base/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib"
}
