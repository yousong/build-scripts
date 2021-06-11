#!/bin/bash -e
#
# Copyright 2015-2021 (c) Yousong Zhou
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
PKG_VERSION=1.16.5
PKG_SOURCE="$PKG_NAME$PKG_VERSION.src.tar.gz"
PKG_SOURCE_URL="https://storage.googleapis.com/golang/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f3c06704e536dcca1814b16dbcdc4a36
PKG_DEPENDS=go1.4

. "$PWD/env.sh"
. "$PWD/utils-go.sh"

GOROOT_BOOTSTRAP="$INSTALL_PREFIX/go/goroot-1.4.20170926"

godisttest() {
	# We want it use dist tool in the build dir: ./pkg/tool/linux_amd64/dist
	export GOROOT="$PKG_BUILD_DIR"
	export PATH=$PKG_BUILD_DIR/bin:$PATH
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

	if false; then
		set -x
		go tool dist test -list
		cd ../test
		go build -o runtest.exe run.go
		go run -x -gcflags= literal2.go
		./runtest.exe -v literal2.go
	fi
	if false; then
		go test -v cmd/go -run TestScript/mod_convert_git
		#go tool dist test go_test:cmd/go
	fi

	# -run regex
	# -run !regex
	# -compile-only
	# -no-rebuild
	# test0 test1
	./run.bash "$@"
}
