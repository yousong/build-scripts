#!/bin/sh -e
#
# The plan is to firstly add MIPS32r2 support
#
# Refs
#
# - Tiny C Compiler, http://bellard.org/tcc/
# - Tiny C Compiler Savannah project page, http://savannah.gnu.org/projects/tinycc
#
# Relevant stuff by Rob Landley
#
# - QCC, QEMU C Compiler, http://landley.net/code/tinycc/qcc/todo.txt
# - Commands to provide, http://landley.net/code/tinycc/qcc/commands.txt
# - http://landley.net/qcc/
#
PKG_NAME=tcc
PKG_VERSION=0.9.26
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/tinycc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5fb28e4abc830c46a7f54c1f637fb25d

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p1 <<"EOF"
From daec3e743fc7346c49d240b0dc0f917077012309 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Thu, 24 Dec 2015 11:25:44 +0800
Subject: [PATCH] configure: avoid ln the same file

The fix is for a clean configure exit status
---
 configure | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index 6a796f3..febea70 100755
--- a/configure
+++ b/configure
@@ -585,6 +585,12 @@ rm -f $TMPN* $CONFTEST
 # ---------------------------------------------------------------------------
 # build tree in object directory if source path is different from current one
 
+fn_sameinode() {
+	local v0="$(stat -c %i%D "$1" 2>/dev/null)"
+	local v1="$(stat -c %i%D "$2" 2>/dev/null)"
+	[ "$v0" = "$v1" ]
+}
+
 fn_makelink()
 {
     tgt=$1/$2
@@ -600,7 +606,9 @@ fn_makelink()
          esac
          ;;
     esac
-    ln -sfn $tgt $2
+    if ! fn_sameinode "$tgt" "$2"; then
+        ln -sfn $tgt $2
+    fi
 }
 
 if test "$source_path_used" = "yes" ; then
-- 
2.6.3
EOF
}

CONFIGURE_ARGS='		\
	--enable-cross		\
'
