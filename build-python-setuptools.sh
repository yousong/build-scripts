#!/bin/sh -e

PKG_NAME=python-setuptools
PKG_VERSION=19.1.1
PKG_SOURCE="setuptools-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://pypi.python.org/packages/source/s/setuptools/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=792297b8918afa9faf826cb5ec4a447a
PKG_PYTHON_VERION="2 3"

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/setuptools-$PKG_VERSION"

. "$PWD/utils-python.sh"
