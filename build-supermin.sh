#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# supermin dependency
#
#	sudo apt-get install ocaml ocaml-findlib
#	sudo yum install ocaml ocaml-findlib glibc-static
#
PKG_NAME=supermin
PKG_VERSION=5.1.20
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://libguestfs.org/download/supermin/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=13494294a7a0599d843051817ce450cd
PKG_PLATFORM=linux
PKG_DEPENDS=e2fsprogs

. "$PWD/env.sh"
