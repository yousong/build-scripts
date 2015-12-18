#!/bin/sh -e
#
# openvpn on Debian requires
#
#   apt-get install liblzo2-dev libpam-dev
#
# PKCS11 requires libpkcs11-helper-1 >= 1.11, which is not available in Debian Wheezy (only 1.09 is available)
#
PKG_NAME=openvpn
PKG_VERSION="2.3.8"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://swupdate.openvpn.org/community/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="acc5ea4b08ad53173784520acbd4e9c3"

. "$PWD/env.sh"

