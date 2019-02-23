#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libosinfo
PKG_VERSION=1.2.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://releases.pagure.org/libosinfo/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d5e7117f9c7af7995d0e8b52e2e3031e
PKG_DEPENDS='pcre libffi libiconv libxml2 libxslt util-linux xz zlib'

. "$PWD/env.sh"

libosinfo_try() {
	osinfo-query os			# osx, fedora, debian
	osinfo-query os vendor='CentOS' --fields "short-id,name,version,family,codename,eol-date"
	osinfo-query platform		# qemu, xen
	osinfo-query device
	osinfo-query deployment
}
