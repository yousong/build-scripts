#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
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
PKG_VERSION=1.10.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://nginx.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=088292d9caf6059ef328aa7dda332e44
PKG_DEPENDS='openssl pcre zlib'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--with-http_realip_module		\\
	--with-http_ssl_module			\\
	--with-http_mp4_module			\\
	--with-stream					\\
	--with-stream_ssl_module		\\
	--with-http_v2_module			\\
"

# nginx-lua depends on LuaJIT or Lua 5.1
nginx_init_lua_conf() {
	local lua_lib="$(pkg-config --libs-only-L luajit 2>/dev/null | sed 's/-L//')"
	local lua_inc="$(pkg-config --cflags-only-I luajit 2>/dev/null | sed 's/-I//')"

	CONFIGURE_VARS="$CONFIGURE_VARS		\\
		LUAJIT_LIB='$lua_lib'			\\
		LUAJIT_INC='$lua_inc'			\\
	"
	PKG_DEPENDS="$PKG_DEPENDS LuaJIT"
}
nginx_init_lua_conf

# master:agentzh/dns-nginx-module cannot build with NGINX 1.9.6 because of API change
#
# Module list
#
#	v1.1.8:arut/nginx-rtmp-module
#
MODS='
	v0.10.2:openresty/lua-nginx-module
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
'
nginx_add_modules
