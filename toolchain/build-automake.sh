#!/bin/sh -e

PKG_NAME=automake
PKG_VERSION=1.15
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/automake/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9a1ddb0e053474d9d1105cfe39b0c48d
PKG_DEPENDS='autoconf pkg-config'

. "$PWD/env.sh"
