#!/bin/sh -e

# silversearcher-ag is available in Debian since release jessie.
#
#   apt-get install silversearcher-ag
#
# To manually build it, the following package needs to be installed.
#
#   apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
#
# See https://github.com/ggreer/the_silver_searcher for details.
#

# N.B. prefix the version number with `v'
VER="0.30.0"

# where to install
INSTALL_PREFIX="$PWD/_ag-install"
NJOBS=32

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
TOPDIR="$PWD"
SOURCE_DIR="$PWD/the_silver_searcher-$VER"
BUILD_DIR="$PWD/the_silver_searcher-$VER"

__errmsg() {
    echo "$1" >&2
}

prepare_from_tarball() {
    local ver="$VER"
    local fn="the_silver_searcher-$ver.tar.gz"
    local url="http://geoff.greer.fm/ag/releases/$fn"

    [ -x "$SOURCE_DIR/configure" ] && {
        __errmsg "$SOURCE_DIR/configure already exists, skip preparing."
        return 0
    } || {
        wget -c -O "$fn" "$url"
        tar -xzf "$fn"
    }
}

build_ag() {
    cd "$BUILD_DIR"

    "$SOURCE_DIR/configure"           \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
    make install

    cd "$TOPDIR"
}

prepare_from_tarball
build_ag
