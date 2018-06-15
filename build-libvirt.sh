#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Provides
#
#	- an API library
#	- libvirtd, a daemon
#	- virsh, a command line utility
#
# virt-manager, virt-install are separate different projects
#
PKG_NAME=libvirt
PKG_VERSION=4.4.0
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://libvirt.org/sources/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=07376bcb6ae1d598285137c95caff6d0
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='curl gmp gnutls nettle pcre libffi libcap-ng libiconv libnl3 libtasn1 libxml2 nghttp2 openssl p11-kit rtmpdump zlib'

. "$PWD/env.sh"

# pciaccess is required when udev is detected
#
# yajl will be required if "$QEMU -help | grep -q libvirt".  See m4/virt-yajl.m4 for details
#
# mpath storage will be default on, then device-mapper-devel/libdevmapper will be required.  See m4/virt-storage-mpath.m4 for details
CONFIGURE_ARGS+=(
	--without-udev
	--without-pciaccess
	--without-yajl
	--without-storage-mpath
)
