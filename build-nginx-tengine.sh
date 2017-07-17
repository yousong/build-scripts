#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=tengine
PKG_VERSION=2.1.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://tengine.taobao.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=76af6a4969e7179c2ff4512d31d9e12d
PKG_DEPENDS='openssl pcre zlib'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

CONFIGURE_ARGS+=(
	--with-http_ssl_module
	--with-http_mp4_module
	--with-http_v2_module
)

# naxsi
#
#	http {
#		include /path/to/naxsi_config/naxsi_core.rules;
#		server {
#			set $naxsi_extensive_log 1;
#			location /foo {
#				SecRulesEnabled;
#				#LearningMode;
#				CheckRule "$SQL >= 8" BLOCK;
#				CheckRule "$CSS >= 8" BLOCK;
#				DeniedUrl "/50x.html";
#			}
#		}
#	}
#
# naxsi wiki: https://github.com/nbs-system/naxsi/wiki/naxsi-setup
#
MODS='
	0.55.3:nbs-system/naxsi:naxsi_src
'
nginx_add_modules
