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

VER="2.0"

# where to install
INSTALL_PREFIX="$PWD/_tmux-install"
NJOBS=32

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
TOPDIR="$PWD"
SOURCE_DIR="$PWD/tmux-$VER"
BUILD_DIR="$PWD/tmux-$VER"

__errmsg() {
    echo "$1" >&2
}

prepare_from_tarball() {
    local ver="$VER"
    local fn="tmux-$ver.tar.gz"
    local url="http://downloads.sourceforge.net/tmux/$fn"

    [ -x "$SOURCE_DIR/configure" ] && {
        __errmsg "$SOURCE_DIR/configure already exists, skip preparing."
        return 0
    } || {
        wget -c -O "$fn" "$url"
        tar -xzf "$fn"
    }
}

build_tmux() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    "$SOURCE_DIR/configure"           \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
    make install

    cd "$TOPDIR"
}

prepare_from_tarball
build_tmux
