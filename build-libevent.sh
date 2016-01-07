#!/bin/sh -e
#
# This is mainly for tmux-2.x on CentOS 6.6

PKG_NAME=libevent
PKG_VERSION="2.0.22"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-stable.tar.gz"
PKG_SOURCE_URL="https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="c4c56f986aa985677ca1db89630a2e11"
PKG_DEPENDS='openssl'

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME-$PKG_VERSION-stable"

