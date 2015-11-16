#!/bin/sh -e

# libubox on CentOS requires package json-c-devel
#
#	sudo yum install -y json-c-devel
#
# It's libjson0-dev on Debian Wheezy
#
PKG_NAME=libubox
PKG_VERSION="2015-11-09"
PKG_SOURCE_VERSION="10429bccd0dc5d204635e110a7a8fae7b80d16cb"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/libubox.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_MD5SUM=""
PKG_CMAKE=1

. "$PWD/env.sh"

prepare_source() {
	local dir="$(basename $PKG_BUILD_DIR)"
	untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "s:^[^/]\\+:$dir:"
}

do_patch() {
    cd "$PKG_BUILD_DIR"

	if ! os_is_darwin; then
		return 0
	fi
	patch -p1 <<"EOF"
From b1ace03730b456fe890bd35ddb61f10990f9ebfe Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Tue, 11 Nov 2014 08:03:07 +0800
Subject: [PATCH] cmake: fix build with MacPorts.

Signed-off-by: Yousong Zhou <yszhou4tech@gmail.com>
---
 lua/CMakeLists.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lua/CMakeLists.txt b/lua/CMakeLists.txt
index 10c6dc1..bd8164b 100644
--- a/lua/CMakeLists.txt
+++ b/lua/CMakeLists.txt
@@ -8,7 +8,7 @@ IF(NOT LUA_CFLAGS)
 	FIND_PROGRAM(PKG_CONFIG pkg-config)
 	IF(PKG_CONFIG)
 		EXECUTE_PROCESS(
-			COMMAND pkg-config --silence-errors --cflags lua5.1
+			COMMAND pkg-config --silence-errors --cflags lua-5.1
 			OUTPUT_VARIABLE LUA_CFLAGS
 			OUTPUT_STRIP_TRAILING_WHITESPACE
 		)
-- 
2.2.1
EOF
}

# XXX: on Debian Wheezy, json.h is in directory /usr/include/json/ and cannot
# be found by examples code
CMAKE_ARGS="-DBUILD_EXAMPLES=no"
# XXX: MacPorts currently installs header files of lua-5.3 to /opt/local/include
# directory instead of a subdirectory 5.3/ there like the 5.1/ does.  In this
# case the incompatible 5.3 headers will be used and compilation error happens
if os_is_darwin; then
	CMAKE_ARGS="$CMAKE_ARGS -DBUILD_LUA=no"
fi

main
