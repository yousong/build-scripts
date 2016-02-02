#!/bin/sh -e
#
PKG_NAME=lua5.1
PKG_VERSION=5.1.5
PKG_SOURCE="lua-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.lua.org/ftp/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2e115fe26e435e33b0d5c022e4490567
PKG_BUILD_DIR_BASENAME="lua-$PKG_VERSION"

. "$PWD/env.sh"
. "$PWD/utils-lua.sh"

lua_do_patch() {
	cd "$PKG_BUILD_DIR"
	# Use SYSCFLAGS for internal submake and reserve MYCFLAGS for command line
	# configuration.  The idea is used by lua5.2 and later versions of Lua
	patch -p0 <<"EOF"
--- src/Makefile.orig	2016-02-01 15:21:11.985000058 +0800
+++ src/Makefile	2016-02-01 15:26:44.306000059 +0800
@@ -8,13 +8,13 @@
 PLAT= none
 
 CC= gcc
-CFLAGS= -O2 -Wall $(MYCFLAGS)
+CFLAGS= -O2 -Wall $(SYSCFLAGS) $(MYCFLAGS)
 AR= ar rcu
 RANLIB= ranlib
 RM= rm -f
 LIBS= -lm $(MYLIBS)
 
-MYCFLAGS=
+SYSCFLAGS=
 MYLDFLAGS=
 MYLIBS=
 
@@ -70,7 +70,7 @@ echo:
 	@echo "AR = $(AR)"
 	@echo "RANLIB = $(RANLIB)"
 	@echo "RM = $(RM)"
-	@echo "MYCFLAGS = $(MYCFLAGS)"
+	@echo "SYSCFLAGS = $(SYSCFLAGS)"
 	@echo "MYLDFLAGS = $(MYLDFLAGS)"
 	@echo "MYLIBS = $(MYLIBS)"
 
@@ -84,36 +84,36 @@ aix:
 	$(MAKE) all CC="xlc" CFLAGS="-O2 -DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-ldl" MYLDFLAGS="-brtl -bexpall"
 
 ansi:
-	$(MAKE) all MYCFLAGS=-DLUA_ANSI
+	$(MAKE) all SYSCFLAGS=-DLUA_ANSI
 
 bsd:
-	$(MAKE) all MYCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-Wl,-E"
+	$(MAKE) all SYSCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-Wl,-E"
 
 freebsd:
-	$(MAKE) all MYCFLAGS="-DLUA_USE_LINUX" MYLIBS="-Wl,-E -lreadline"
+	$(MAKE) all SYSCFLAGS="-DLUA_USE_LINUX" MYLIBS="-Wl,-E -lreadline"
 
 generic:
-	$(MAKE) all MYCFLAGS=
+	$(MAKE) all SYSCFLAGS=
 
 linux:
-	$(MAKE) all MYCFLAGS=-DLUA_USE_LINUX MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses"
+	$(MAKE) all SYSCFLAGS=-DLUA_USE_LINUX MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses"
 
 macosx:
-	$(MAKE) all MYCFLAGS=-DLUA_USE_LINUX MYLIBS="-lreadline"
+	$(MAKE) all SYSCFLAGS=-DLUA_USE_LINUX MYLIBS="-lreadline"
 # use this on Mac OS X 10.3-
 #	$(MAKE) all MYCFLAGS=-DLUA_USE_MACOSX
 
 mingw:
 	$(MAKE) "LUA_A=lua51.dll" "LUA_T=lua.exe" \
 	"AR=$(CC) -shared -o" "RANLIB=strip --strip-unneeded" \
-	"MYCFLAGS=-DLUA_BUILD_AS_DLL" "MYLIBS=" "MYLDFLAGS=-s" lua.exe
+	"SYSCFLAGS=-DLUA_BUILD_AS_DLL" "MYLIBS=" "MYLDFLAGS=-s" lua.exe
 	$(MAKE) "LUAC_T=luac.exe" luac.exe
 
 posix:
-	$(MAKE) all MYCFLAGS=-DLUA_USE_POSIX
+	$(MAKE) all SYSCFLAGS=-DLUA_USE_POSIX
 
 solaris:
-	$(MAKE) all MYCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-ldl"
+	$(MAKE) all SYSCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-ldl"
 
 # list targets that do not create files (but not all makes understand .PHONY)
 .PHONY: all $(PLATS) default o a clean depend echo none
EOF
}
