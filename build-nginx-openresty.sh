#!/bin/sh -e

PKG_NAME=openresty
PKG_VERSION=1.9.3.1
PKG_SOURCE="ngx_openresty-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openresty.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=cde1f7127f6ba413ee257003e49d6d0a

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/ngx_openresty-$PKG_VERSION"

. "$PWD/utils-nginx.sh"
