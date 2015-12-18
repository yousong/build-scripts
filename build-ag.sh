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

PKG_NAME=ag
PKG_VERSION="0.31.0"
PKG_SOURCE="the_silver_searcher-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://geoff.greer.fm/ag/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="6a4275e0191e7fe2f834f7ec00eabbbe"

. "$PWD/env.sh"

PKG_BUILD_DIR="$BASE_BUILD_DIR/the_silver_searcher-$PKG_VERSION"

