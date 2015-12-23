#!/bin/sh -e
#
# Building python binding requires Cython
#
PKG_NAME=Cython
PKG_VERSION=0.23.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://cython.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=157df1f69bcec6b56fd97e0f2e057f6e
PKG_PYTHON_VERION="2 3"

. "$PWD/env.sh"
. "$PWD/utils-python.sh"
