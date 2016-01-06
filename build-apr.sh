#!/bin/sh -e
#
# APR for Apache Portable Runtime
#
PKG_NAME=apr
PKG_VERSION=1.5.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.us.apache.org/dist//apr/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4e9769f3349fe11fc0a5e1b224c236aa

. "$PWD/env.sh"

CONFIGURE_ARGS='			\
	--enable-layout=GNU		\
'
