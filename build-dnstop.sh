#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=dnstop
PKG_VERSION=2018-05-22
PKG_SOURCE_PROTO=git
PKG_SOURCE_VERSION=a5a5d2e2ca9a433bb8f017682ac6f2085741bdf8
PKG_SOURCE_URL=https://github.com/measurement-factory/dnstop.git
PKG_DEPENDS='libpcap ncurses'

. "$PWD/env.sh"
