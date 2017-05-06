#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It requries several extra python packages to install or for additional
# features
#
#	pip install -r tools/pip-requires
#	pip install -r tools/optional-requires
# 
PKG_NAME=ryu
PKG_VERSION=4.13
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/osrg/ryu/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=f49f2615712c7f1cf197760fd12bfae3
PKG_PYTHON_VERSIONS=2
PKG_DEPENDS='python2'

. "$PWD/env.sh"
. "$PWD/utils-python.sh"
