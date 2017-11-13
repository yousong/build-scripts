#!/bin/bash -e
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
# The tarballs at storage.googleapis.com are lagging behind that's why we are
# using github tarballs, https://golang.org/doc/install/source
#
PKG_NAME=go1.4
PKG_VERSION=1.4.20170926
PKG_SOURCE_VERSION=4d5426a570c2820c5894a61b52e3dc147e4e7925
PKG_SOURCE="go$PKG_VERSION-$PKG_SOURCE_VERSION.src.tar.gz"
PKG_SOURCE_URL="https://github.com/golang/go/archive/$PKG_SOURCE_VERSION.tar.gz"

. "$PWD/env.sh"
. "$PWD/utils-go.sh"
