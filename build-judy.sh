#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Judy is a C library that provides a state-of-the-art core technology that
# implements a sparse dynamic array.
#
PKG_NAME=judy
PKG_VERSION=1.0.5
PKG_SOURCE="judy-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/judy/Judy-$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=115a0d26302676e962ae2f70ec484a54

. "$PWD/env.sh"
