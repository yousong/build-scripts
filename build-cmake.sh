#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# Checking CMakeLists.txt, it seems openssl is an optional dependency
# for ctest
#
PKG_NAME=cmake
PKG_VERSION=3.11.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://cmake.org/files/v${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=12a3177477e4e2c7bc514193d421dafe
PKG_DEPENDS='openssl'

. "$PWD/env.sh"

# --parallel, bootstrap cmake in parallel
CONFIGURE_ARGS+=(
	--verbose
	--parallel=$NJOBS
)
