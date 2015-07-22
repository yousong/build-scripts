#!/bin/sh -e

# TMUX depends on libevent-dev to build.
#
#	sudo apt-get build-dep tmux
#
# tmux on Debian Wheezy 7 has version 1.6 (Fetched with command "tmux -V")
#
# Newer versions are required for the following features to work
#
#  - TMUX plugins, >= 1.9, https://github.com/tmux-plugins/tpm
#  - set focus-events off, >= 1.8, see CHANGES file in source code.
#

PKGNAME=tmux
VER="2.0"

. "$PWD/env.sh"
# If we have git repo present, extract sources from there
# rather than downloading them over the network.
BUILD_DIR="$BASE_BUILD_DIR/tmux-$VER"

prepare_from_tarball() {
    local ver="$VER"
    local fn="tmux-$ver.tar.gz"
    local url="http://downloads.sourceforge.net/tmux/$fn"

    [ -x "$BUILD_DIR/configure" ] && {
        __errmsg "$BUILD_DIR/configure already exists, skip preparing."
        return 0
    } || {
		cd "$BASE_DL_DIR"
		wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    }
}

build_tmux() {
	local dest_dir="$BASE_DESTDIR/_$PKGNAME-install"

    cd "$BUILD_DIR"

    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
	rm -rf "$dest_dir"
    make DESTDIR="$dest_dir" install
    cp "$dest_dir/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_tmux
