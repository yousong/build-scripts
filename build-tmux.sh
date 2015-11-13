#!/bin/sh -e

# TMUX depends on libevent-dev to build.
#
#	sudo apt-get build-dep tmux
#
# tmux on Debian Wheezy 7 has version 1.6 (Fetched with command "tmux -V")
#
# CentOS 6.6 lacks a libevent version that fulfils tmux's requirement so that
# we have to build it manually here with the following commands
#
#		setup_dev_env
#		./build-libevent.sh
#
# Newer versions are required for the following features to work
#
#  - TMUX plugins, >= 1.9, https://github.com/tmux-plugins/tpm
#  - set focus-events off, >= 1.8, see CHANGES file in source code.
#

PKG_NAME=tmux
PKG_VERSION="2.1"
PKG_SOURCE="tmux-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/tmux/tmux/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="74a2855695bccb51b6e301383ad4818c"

. "$PWD/env.sh"

main
