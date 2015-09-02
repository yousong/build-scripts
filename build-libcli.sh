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
PKGNAME=libcli
VER="1.9.7"

. "$PWD/env.sh"

# If we have git repo present, extract sources from there
# rather than downloading them over the network.
BUILD_DIR="$BASE_BUILD_DIR/libcli-$VER"

prepare_from_tarball() {
    local ver="$VER"
    local fn="libcli-$ver.tar.gz"
    local url="http://github.com/dparrish/libcli/tarball/v1.9.7"

    if [ -f "$BUILD_DIR/libcli.h" ]; then
        __errmsg "$BUILD_DIR/libcli.h already exists, skip preparing."
        return 0
    else
		cd "$BASE_DL_DIR"
        wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" --transform="s:^[^/]\\+:libcli-$ver:" -xzf "$fn"
    fi
}

build_libcli() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    make -j "$NJOBS"
    make DESTDIR="$BASE_DESTDIR/_$PKGNAME-install" PREFIX="$INSTALL_PREFIX" install
    cp "$BASE_DESTDIR/_$PKGNAME-install/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_libcli
