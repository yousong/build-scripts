#!/bin/sh -e

#
# This is mainly for tmux-2.0 on CentOS 6.6

PKGNAME=libevent
VER="2.0.22"

. "$PWD/env.sh"

BUILD_DIR="$BASE_BUILD_DIR/libevent-$VER-stable"

prepare_from_tarball() {
    local ver="$VER"
    local fn="libevent-$ver-stable.tar.gz"
    local url="https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/$fn"

    if [ -x "$BUILD_DIR/configure" ]; then
        __errmsg "$BUILD_DIR/configure already exists, skip preparing."
        return 0
    else
		cd "$BASE_DL_DIR"
        wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    fi
}

build_libevent() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
    make DESTDIR="$BASE_DESTDIR/_$PKGNAME-install" install
    cp "$BASE_DESTDIR/_$PKGNAME-install/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_libevent
