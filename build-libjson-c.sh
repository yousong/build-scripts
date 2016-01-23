#!/bin/sh -e

PKG_NAME=json-c
PKG_VERSION=0.12
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://s3.amazonaws.com/json-c_releases/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3ca4bbb881dfc4017e8021b5e0a8c491

. "$PWD/env.sh"
