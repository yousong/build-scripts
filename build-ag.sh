#!/bin/sh -e

# silversearcher-ag is available in Debian since release jessie.
#
#   apt-get install silversearcher-ag
#
# To manually build it, the following package needs to be installed.
#
#   apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
#
#   yum -y groupinstall "Development Tools"
#   yum -y install pcre-devel xz-devel
#
# See https://github.com/ggreer/the_silver_searcher for details.
#

# N.B. prefix the version number with `v'
PKGNAME=ag
VER="0.30.0"

. "$PWD/env.sh"

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
BUILD_DIR="$BASE_BUILD_DIR/the_silver_searcher-$VER"

prepare_from_tarball() {
    local ver="$VER"
    local fn="the_silver_searcher-$ver.tar.gz"
    local url="http://geoff.greer.fm/ag/releases/$fn"

    if [ -x "$BUILD_DIR/configure" ]; then
        __errmsg "$BUILD_DIR/configure already exists, skip preparing."
        return 0
    else
		cd "$BASE_DL_DIR"
        wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    fi
}

build_ag() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
    make DESTDIR="$BASE_DESTDIR/_$PKGNAME-install" install
    cp "$BASE_DESTDIR/_$PKGNAME-install/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_ag
