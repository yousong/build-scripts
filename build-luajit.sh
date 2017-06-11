#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=LuaJIT
PKG_VERSION=2.0.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://luajit.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=dd9c38307f2223a504cbfb96e477eca0

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# Despite the code comments there, /usr/local still should not be in
	# package.cpath when PREFIX is something like $HOME/.usr.
	patch -p0 <<"EOF"
--- src/luaconf.h.orig	2016-01-24 00:26:03.124492382 +0800
+++ src/luaconf.h	2016-01-24 00:28:20.640532518 +0800
@@ -35,31 +35,23 @@
 #ifndef LUA_LMULTILIB
 #define LUA_LMULTILIB	"lib"
 #endif
-#define LUA_LROOT	"/usr/local"
-#define LUA_LUADIR	"/lua/5.1/"
-#define LUA_LJDIR	"/luajit-2.0.4/"
-
 #ifdef LUA_ROOT
-#define LUA_JROOT	LUA_ROOT
-#define LUA_RLDIR	LUA_ROOT "/share" LUA_LUADIR
-#define LUA_RCDIR	LUA_ROOT "/" LUA_MULTILIB LUA_LUADIR
-#define LUA_RLPATH	";" LUA_RLDIR "?.lua;" LUA_RLDIR "?/init.lua"
-#define LUA_RCPATH	";" LUA_RCDIR "?.so"
+#define LUA_LROOT	LUA_ROOT
 #else
-#define LUA_JROOT	LUA_LROOT
-#define LUA_RLPATH
-#define LUA_RCPATH
+#define LUA_LROOT	"/usr/local"
 #endif
+#define LUA_LUADIR	"/lua/5.1/"
+#define LUA_LJDIR	"/luajit-2.0.4/"
 
-#define LUA_JPATH	";" LUA_JROOT "/share" LUA_LJDIR "?.lua"
+#define LUA_JPATH	";" LUA_LROOT "/share" LUA_LJDIR "?.lua"
 #define LUA_LLDIR	LUA_LROOT "/share" LUA_LUADIR
 #define LUA_LCDIR	LUA_LROOT "/" LUA_LMULTILIB LUA_LUADIR
 #define LUA_LLPATH	";" LUA_LLDIR "?.lua;" LUA_LLDIR "?/init.lua"
 #define LUA_LCPATH1	";" LUA_LCDIR "?.so"
 #define LUA_LCPATH2	";" LUA_LCDIR "loadall.so"
 
-#define LUA_PATH_DEFAULT	"./?.lua" LUA_JPATH LUA_LLPATH LUA_RLPATH
-#define LUA_CPATH_DEFAULT	"./?.so" LUA_LCPATH1 LUA_RCPATH LUA_LCPATH2
+#define LUA_PATH_DEFAULT	"./?.lua" LUA_JPATH LUA_LLPATH
+#define LUA_CPATH_DEFAULT	"./?.so" LUA_LCPATH1 LUA_LCPATH2
 #endif
 
 /* Environment variable names for path overrides and initialization code. */
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
