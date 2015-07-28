#!/bin/sh -e

# Extra packages has to be installed to support https helper etc.
#
#   apt-get install -y curl-devel
#
#   yum -y groupinstall "Development Tools"
#   yum-builddep git-email
#

PKGNAME=git
VER="2.5.0"

. "$PWD/env.sh"

BUILD_DIR="$BASE_BUILD_DIR/$PKGNAME-$VER"

prepare_from_tarball() {
    local ver="$VER"
    local fn="git-$ver.tar.gz"
    local url="https://www.kernel.org/pub/software/scm/git/$fn"

    if [ -x "$BUILD_DIR/configure" ]; then
        __errmsg "$BUILD_DIR/configure already exists, skip preparing."
        return 0
    else
		cd "$BASE_DL_DIR"
        wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    fi
}

build_git() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    "$BUILD_DIR/configure"            \
        --prefix="$INSTALL_PREFIX"    \

    make -j "$NJOBS"
    make DESTDIR="$BASE_DESTDIR/_$PKGNAME-install" install
    cp "$BASE_DESTDIR/_$PKGNAME-install/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_git
