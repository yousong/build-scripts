#!/bin/bash -e
#
# Copyright 2015-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Building go1.5 and newer versions requires go1.4 to bootstrap
#
# The ports for Snow Leopard (Apple OS X 10.6) are no longer released as a
# download or maintained since Apple no longer maintains that version of the
# operating system.
#
# - Release History, https://golang.org/doc/devel/release.html
# - Go 1.5 Release Notes, https://golang.org/doc/go1.5
#
# Additional tools
#
#	go get golang.org/x/tour/gotour
#	go get golang.org/x/tools/cmd/godoc
#
PKG_NAME=go
PKG_VERSION=1.10
PKG_SOURCE="$PKG_NAME$PKG_VERSION.src.tar.gz"
PKG_SOURCE_URL="https://storage.googleapis.com/golang/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=07cbb9d0091b846c6aea40bf5bc0cea7
PKG_DEPENDS=go1.4

. "$PWD/env.sh"
. "$PWD/utils-go.sh"

GOROOT_BOOTSTRAP="$INSTALL_PREFIX/go/goroot-1.4.20170926"

godisttest() {
	# We want it use dist tool in the build dir: ./pkg/tool/linux_amd64/dist
	export GOROOT="$PKG_BUILD_DIR"
	eval "$(go tool dist env -p)"

	# -v, verbose
	# -c, compile binary syscall.test
	#
	# go test -v syscall
	# go test -v -c syscall
	# ./syscall.test -test.list .
	# ./syscall.test -test.run TestName
	# ./syscall.test -test.bench BenchmarkName

	cd "$PKG_BUILD_DIR/src"

	# -run syscall
	# -compile-only
	# -no-rebuild -run syscall
	./run.bash "$@"
}
