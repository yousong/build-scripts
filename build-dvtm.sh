#!/bin/sh -e

PKG_NAME=dvtm
PKG_VERSION=0.15
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.brain-dump.org/projects/dvtm/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=887e162a3abe2ad8e86caefab20cdd63
PKG_DEPENDS=ncurses

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# fix for parallel build
	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-26 21:45:49.282609180 +0800
+++ Makefile	2016-01-26 21:46:06.022614368 +0800
@@ -3,7 +3,7 @@ include config.mk
 SRC = dvtm.c vt.c
 OBJ = ${SRC:.c=.o}
 
-all: clean options dvtm
+all: options dvtm
 
 options:
 	@echo dvtm build options:
EOF
}

MAKE_VARS="PREFIX='$INSTALL_PREFIX'"
