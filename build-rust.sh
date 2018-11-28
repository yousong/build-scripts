#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=rust
PKG_VERSION=1.30.1
PKG_SOURCE="rustc-${PKG_VERSION}-src.tar.gz"

rust_init() {
	local os="$(uname -s)"
	if [ "$os" = "Linux" ]; then
		PKG_SOURCE="rust-$PKG_VERSION-x86_64-unknown-linux-gnu.tar.gz"
		PKG_SOURCE_MD5SUM=9480f4c55d97bfdeb3d6e8b4cc32bd9b
	elif [ "$os" = "Darwin" ]; then
		PKG_SOURCE="rust-$PKG_VERSION-x86_64-apple-darwin.tar.gz"
	else
		__errmsg "unsupported os type: $os"
		return 1
	fi
	PKG_SOURCE_URL="https://static.rust-lang.org/dist/$PKG_SOURCE"
}
rust_init

. "$PWD/env.sh"
STRIP=()

RUST_DIR="$INSTALL_PREFIX/rust/$PKG_VERSION"

configure() {
	true
}

compile() {
	true
}

staging() {

	cd "$PKG_BUILD_DIR"
	./install.sh \
		--prefix="$RUST_DIR" \
		--destdir="$PKG_STAGING_DIR"
}

install_post() {
	__errmsg "
Rust has been installed to $RUST_DIR

A taste of rust and cargo

	cargo new hello --bin
	cargo build
	cargo build --release
	cargo run --release
"
}
