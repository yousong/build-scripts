#!/bin/sh -e

PKG_NAME=tengine
PKG_VERSION=2.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://tengine.taobao.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=fb60c57c2610c6a356153613c485e4af

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"
