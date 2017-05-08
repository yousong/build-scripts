#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# When testing libraries, we need to write a simple application to use the
# libraries to load input data
#
# Instrumentation of black-box binaries can be achieved by running in qemu
# user-mode emulation.  See files under qemu_mode/
#
# Good examples of starting files can be found in testcases/
#
# Instrumentations are done in the assembly level.  See add_instrumentation()
# call in afl-as.c for details
#
# Examples
#
#	./afl-gcc -o b test-instr.c
#	mkdir -p i o
#	echo i >i/i
#	./afl-fuzz -i i -o o -- ./b
#
# Links
#
# - http://lcamtuf.coredump.cx/afl/
# - https://github.com/google/oss-fuzz/
# - QuickStartGuide.txt, README, sister_projects.txt under docs/
#
PKG_NAME=afl
PKG_VERSION=2.41b
PKG_SOURCE="afl-$PKG_VERSION.tgz"
PKG_SOURCE_URL="http://lcamtuf.coredump.cx/afl/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9a87752684bf01cb4fd9c63657cf1077

. "$PWD/env.sh"

configure() {
	true
}

MAKE_ARGS="$MAKE_ARGS			\\
	PREFIX='$INSTALL_PREFIX'	\\
"
