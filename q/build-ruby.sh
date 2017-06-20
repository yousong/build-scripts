#!/bin/bash -e

PKG_NAME=ruby
PKG_VERSION=2.3.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://cache.ruby-lang.org/pub/ruby/${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e81740ac7b14a9f837e9573601db3162

. "$PWD/env.sh"
