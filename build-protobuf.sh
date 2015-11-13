#!/bin/sh -e

PKG_NAME=protobuf
PKG_VERSION="2.6.1"
PKG_SOURCE="protobuf-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/google/protobuf/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="f3916ce13b7fcb3072a1fa8cf02b2423"

. "$PWD/env.sh"

main
