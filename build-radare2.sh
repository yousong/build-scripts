#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# When there already exists a radare2 installation and we pass that path
# to linker with LDFLAGS, since build system of radare2 will append (instead of
# prepend) its local relative library search path to LDFLAGS or LINK variables,
# the linker will see libraries of old installation instead of current build
# first and the build may fail.  The same can also happen with header files.
#
# To resolve this, we have such choices as
#
#  - Removing previous installation with package manager
#  - Delete those libraries with the pattern `libr_xxx`
#  - Remove those pathes from CPPFLAGS, CFLAGS and LDFLAGS
#
PKG_NAME=radare2
PKG_VERSION=0.10.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://www.radare.org/get/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1f70f6735c13c6d34888c452a189ba5b

. "$PWD/env.sh"
