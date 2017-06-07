#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# If test failed
#
#	cd "$PKG_SOURCE_DIR"
#	export GOROOT="$PKG_SOURCE_DIR"
#	unset GOPATH
#	eval "$(./pkg/tool/linux_amd64/dist env -p)"
#	eval "$(go env)"
#	go test -v net/ -run TestDialTimeout
#	go test -v net/ -run 'TestDial.*'
#	go test -v net/ -run 'TestLookup.*'
#
PKG_NAME=go1.4
PKG_VERSION=1.4.3
PKG_SOURCE="go$PKG_VERSION.src.tar.gz"
PKG_SOURCE_URL="https://storage.googleapis.com/golang/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=dfb604511115dd402a77a553a5923a04
PKG_BUILD_DIR_BASENAME="go-$PKG_VERSION"

. "$PWD/env.sh"
. "$PWD/utils-go.sh"
