#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# binutils-pass0 is for preparing binutils source code for later passes
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg binutils
PKG_NAME=binutils-pass0

. "$PWD/env.sh"
toolchain_init_genmake_func

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

configure() {
	true
}

compile() {
	true
}

staging() {
	true
}

install() {
	true
}
