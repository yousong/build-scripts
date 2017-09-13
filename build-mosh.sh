#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# mosh requires protobuf to build, but the version provided by Debian Wheezy might be too old
#
# - Debian provides 'protobuf-c-compiler' and 'libprotobuf-dev'
# - MacPorts on MAC OS X provides 'protobuf-c'
#
# The command `mosh` is a perl script
#
#  - It starts mosh-server on the remote with ssh command
#  - The newly-started mosh-server will listen on a UDP port and echos back
#    connection parameters
#  - Then a local mosh-client will be started to connect with it
#
# Basic usage
#
#   mosh <ip>
#   mosh <user>@<ip>
#   mosh --ssh='ssh -p <ssh_port>' <user>@<ip>
#   mosh --ssh='ssh -p <ssh_port> -i id_rsa' <user>@<ip>
#
# Drawbacks
#
#  - It syncs "screen": no local scrollback is possible
#
PKG_NAME=mosh
PKG_VERSION=1.3.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://mosh.mit.edu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5122f4d2b973ab7c38dcdac8c35cb61e
PKG_DEPENDS='openssl protobuf'

. "$PWD/env.sh"
