#!/bin/sh -e

PKGNAME=redis
VER="3.0.2"

. "$PWD/env.sh"
# If we have git repo present, extract sources from there
# rather than downloading them over the network.
BUILD_DIR="$BASE_BUILD_DIR/redis-$VER"

__errmsg() {
    echo "$1" >&2
}

prepare_from_tarball() {
    local ver="$VER"
    local fn="redis-$ver.tar.gz"
    local url="http://download.redis.io/releases/$fn"

    [ -x "$BUILD_DIR/src/redis.c" ] && {
        __errmsg "$BUILD_DIR/src/redis.c already exists, skip preparing."
        return 0
    } || {
		cd "$BASE_DL_DIR"
		wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    }
}

build_redis() {
	local dest_dir="$BASE_DESTDIR/_$PKGNAME-install"

    cd "$BUILD_DIR"
    make -j "$NJOBS"
	rm -rf "$dest_dir"
    make PREFIX="$dest_dir" install
    #cp "$dest_dir/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_redis
