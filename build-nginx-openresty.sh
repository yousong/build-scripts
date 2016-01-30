#!/bin/sh -e

PKG_NAME=openresty
PKG_VERSION=1.9.7.2
PKG_SOURCE="ngx_openresty-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openresty.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=78a263de11ff43c95e847f208cce0899
PKG_SOURCE_UNTAR_FIXUP=1
PKG_INSTALL_DIR_BASENAME="nginx/$PKG_NAME-$PKG_VERSION"
PKG_DEPENDS='openssl pcre'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# NOTE: NGINX version ${PKG_VERSION%.*} was bundled
	patch -p0 <<"EOF"
--- bundle/nginx-1.9.7/auto/feature.orig	2015-12-22 20:52:59.000000000 +0800
+++ bundle/nginx-1.9.7/auto/feature	2015-12-22 20:53:37.000000000 +0800
@@ -39,8 +39,8 @@ int main() {
 END
 
 
-ngx_test="$CC $CC_TEST_FLAGS $CC_AUX_FLAGS $ngx_feature_inc_path \
-          -o $NGX_AUTOTEST $NGX_AUTOTEST.c $NGX_TEST_LD_OPT $ngx_feature_libs"
+ngx_test="$CC $ngx_feature_inc_path $CC_TEST_FLAGS $CC_AUX_FLAGS \
+          -o $NGX_AUTOTEST $NGX_AUTOTEST.c $ngx_feature_libs $NGX_TEST_LD_OPT"
 
 ngx_feature_inc_path=
 
EOF
}
