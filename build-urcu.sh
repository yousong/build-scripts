#!/bin/sh -e
#
# Building on MacOS X (Darwin) requires a work-around for processor detection:
#
#	./configure --build=i686-apple-darwin11
#	./configure --build=x86_64-apple-darwin11
#
PKG_NAME=liburcu
PKG_VERSION=0.9.1
PKG_SOURCE="userspace-rcu-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.lttng.org/files/urcu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=124eaeea06863271c0bdf2a0cc1d8e4b
PKG_BUILD_DIR_BASENAME="userspace-rcu-$PKG_VERSION"

. "$PWD/env.sh"

if os_is_darwin; then
	CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
		--build=x86_64-apple-darwin11	\\
	"
fi
