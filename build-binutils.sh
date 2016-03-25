#!/bin/sh -e
#
# GNU ar provided by binutils is different from BSD ar (/usr/bin/ar) present in
# Mac OS X.  From the output of `/usr/bin/ar -vt lib/libncursesw.a' where
# `libncursesw.a' was generated with GNU ar, it seems that clang can only work
# with those made by /usr/bin/ar
#
# - http://stackoverflow.com/questions/22107616/static-library-built-for-archive-which-is-not-the-architecture-being-linked-x86
#
PKG_NAME=binutils
PKG_VERSION=2.26
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/binutils/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=64146a0faa3b411ba774f47d41de239f
PKG_PLATFORM=linux

. "$PWD/env.sh"
. "$PWD/utils-toolchain.sh"
toolchain_init

prepare_extra() {
	toolchain_prepare_extra
}

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

configure_pre() {
	toolchain_configure_pre
}

# --with-sysroot is needed for quashing the error message "this linker was not
# configured to use sysroots"
CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
	--with-sysroot='$TOOLCHAIN_DIR'		\\
	--build='$TRI_BUILD'				\\
	--host='$TRI_HOST'					\\
	--target='$TRI_TARGET'				\\
	--enable-plugins					\\
	--disable-multilib					\\
	--disable-werror					\\
	--disable-nls						\\
	--disable-sim						\\
	--disable-gdb						\\
"

staging_post() {
	local base="$PKG_STAGING_DIR$TOOLCHAIN_DIR"

	# ld will look for libc.so.6, etc. in $base/$TRI_TARGET/lib which will be
	# installed from glibc into $base/lib
	#
	# gcc-pass2 requires the existence of $base/usr/include
	mkdir -p "$base/usr/include"
	ln -sf 'lib' "$base/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib"
}
