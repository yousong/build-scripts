#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Install figlet font for cacaclock
#
#	CACA_DRIVER=raw cacaclock -f /usr/share/figlet/lean.flf | cacaserver
#	CACA_DRIVER=raw cacafire | cacaserver
#
#	# view captcha pic on terminal
#	cacaview /tmp/tmpocrws_v5.png
#
# Links
#
# - homepage, http://caca.zoy.org/wiki/libcaca
# - Libcaca study: the science behind colour ASCII art, http://caca.zoy.org/study/index.html
#
PKG_NAME=libcaca
PKG_VERSION=0.99.beta19
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://caca.zoy.org/files/libcaca/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a3d4441cdef488099f4a92f4c6c1da00
PKG_DEPENDS='imlib2 ncurses zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--enable-ncurses			\\
	--disable-x11				\\
	--disable-java				\\
	--disable-cocoa				\\
	--disable-csharp			\\
	--disable-cxx				\\
	--disable-python			\\
	--disable-ruby				\\
"
