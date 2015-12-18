#!/bin/sh -e

# mosh requires protobuf to build, but the version provided by Debian Wheezy might be too old
#
#		protobuf-c-compiler libprotobuf-dev
#
# On Mac OS X with MacPorts
#
#		sudo port install protobuf-c
#
PKG_NAME=mosh
PKG_VERSION="1.2.5"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://mosh.mit.edu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="56d7147cf7031583ba7d8db09033e0c5"

. "$PWD/env.sh"

