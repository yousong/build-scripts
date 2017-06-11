#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Poppler is a PDF rendering library based on the xpdf-3.0 code base
#
# This package requires fontconfig>=2.0
#
#	# extract images
#	pdfimages -j a.pdf imgs/
#
PKG_NAME=poppler
PKG_VERSION=0.55.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://poppler.freedesktop.org/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f7a8230626b6d2061acfdc852930b7dd
PKG_DEPENDS='freetype openjpeg libjpeg-turbo libpng zlib'

. "$PWD/env.sh"
