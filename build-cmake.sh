#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# Checking CMakeLists.txt, it seems openssl is an optional dependency
# for ctest
#
PKG_NAME=cmake
PKG_VERSION=3.21.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://cmake.org/files/v${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a0b5bb28aef21dcf8d6554ae91bb8aa7
PKG_DEPENDS='openssl'

. "$PWD/env.sh"

# --parallel, bootstrap cmake in parallel
CONFIGURE_ARGS+=(
	--docdir="share/doc/cmake-${PKG_VERSION%.*}"
	--verbose
	--parallel=$NJOBS
)
