#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=python-setuptools
PKG_VERSION=19.1.1
PKG_SOURCE="setuptools-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://pypi.python.org/packages/source/s/setuptools/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=792297b8918afa9faf826cb5ec4a447a
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PYTHON_VERSIONS="2 3"

. "$PWD/env.sh"
. "$PWD/utils-python-package.sh"
