#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Or you can use the binary package provided by upstream NGINX project.
#
# - Info on how the pre-built packages are configured, http://nginx.org/en/linux_packages.html
# - Repo setup info for CentOS, RHEL, Ubuntu, Debian, http://nginx.org/en/linux_packages.html
#
# NGINX does not support autotools configure style of out tree build, it's
# already out of src/ tree...
#
# To use "reuseport" in "listen" directive, Linux kernel version of at least
# 3.9 is required.
#
# With Debian we can use kernel 3.16 backports repository
#
#	# linux-libc-dev is required for definition of SO_REUSEPORT
#	sudo apt-get install -t wheezy-backports linux-image-amd64 linux-libc-dev
#
# On CentOS 6, the feature has been backported since kernel version "2.6.32-417.el6"
#
# - Benchmark results across accept_mutex, reuseport, https://www.nginx.com/blog/socket-sharding-nginx-release-1-9-1/
#
PKG_NAME=nginx
PKG_VERSION=1.17.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://nginx.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=476a6d0bea58fbeefb5f6d0a81824a43
PKG_DEPENDS='openssl pcre zlib'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

CONFIGURE_ARGS+=(
	--with-http_realip_module
	--with-http_ssl_module
	--with-http_mp4_module
	--with-stream
	--with-stream_ssl_module
	--with-http_v2_module
)

# nginx-lua depends on LuaJIT or Lua 5.1
nginx_init_lua_conf() {
	local lua_lib="$(pkg-config --libs-only-L luajit 2>/dev/null | sed 's/-L//')"
	local lua_inc="$(pkg-config --cflags-only-I luajit 2>/dev/null | sed 's/-I//')"

	CONFIGURE_VARS+=(
		LUAJIT_LIB="$lua_lib"
		LUAJIT_INC="$lua_inc"
	)
	PKG_DEPENDS="$PKG_DEPENDS LuaJIT"
}
nginx_init_lua_conf

# master:agentzh/dns-nginx-module cannot build with NGINX 1.9.6 because of API change
#
# Module list
#
#	v1.1.8:arut/nginx-rtmp-module
#	master:nbs-system/naxsi:naxsi_src
#
# Try the following command to re-download master tarballs
#
#	rm -v dl/*master*
#
MODS=(
	master:openresty/lua-nginx-module
	master:simpl/ngx_devel_kit
	master:agentzh/array-var-nginx-module
	master:agentzh/echo-nginx-module
	master:agentzh/headers-more-nginx-module
	master:agentzh/memc-nginx-module
	master:agentzh/rds-csv-nginx-module
	master:agentzh/rds-json-nginx-module
	master:agentzh/redis2-nginx-module
	master:agentzh/set-misc-nginx-module
	master:agentzh/xss-nginx-module
)

if true; then
	# nginx-dav-ext-module requires data structures only available when
	# http_dav_module is enabled
	CONFIGURE_ARGS+=(
		--with-http_dav_module
	)
	MODS+=(
		v3.0.0:arut/nginx-dav-ext-module
	)
	do_patch_arut_nginx_dav_ext_module() {
		patch -p1 <<"EOF"
--- a/config	2018-12-17 08:45:12.000000000 +0000
+++ b/config	2019-10-11 13:49:41.446919258 +0000
@@ -8,9 +8,10 @@ ngx_module_name=ngx_http_dav_ext_module
 # building nginx with the xslt module, in which case libxslt will
 # be linked anyway.  In other cases libxslt is just redundant.
 # If that's a big deal, libxml2 can be linked directly:
-# ngx_module_libs=-lxml2
+ngx_module_libs=-lxml2
+ngx_module_incs=$(pkg-config --cflags-only-I libxml-2.0 | sed 's/^-I//')
 
-ngx_module_libs=LIBXSLT
+#ngx_module_libs=LIBXSLT
 
 ngx_module_srcs="$ngx_addon_dir/ngx_http_dav_ext_module.c"
 
EOF
	}
fi

#
# master njs requires master nginx
#
#MODS += (
#	master:nginx/njs:nginx
#)

nginx_add_modules
