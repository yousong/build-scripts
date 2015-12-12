#!/bin/sh -e
#
# supermin dependency
#
#	sudo apt-get install ocaml ocaml-findlib ext2fs-dev
#
PKG_NAME=supermin
PKG_VERSION=5.1.13
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://libguestfs.org/download/supermin/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e39f95b07651b25d310687f4407b8466

. "$PWD/env.sh"
main
