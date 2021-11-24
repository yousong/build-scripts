#!/bin/bash -e
#
# Copyright 2016-2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# tcpdump 4.99 can fail with "[Invalid header: len(100) < caplen(116)]"
# when reading dumps written by old versions of the program (e.g.  4.9.2).
# The check was introduced in tcpdump commit 9e6ba479 ("Add sanity checks on
# packet header (packet length / capture length)")
#
# - https://github.com/the-tcpdump-group/tcpdump/commit/9e6ba479d8cee861a396cae59d7cf91bd3a5a563
#
# len(100) is the packet length on the wire and caplen(116) is the portion
# present in the capture.  It seems tcpdump 4.9 can write packets with snaplen
# 16 bytes bigger than actual length.
#
# pcap format:
#  - /usr/include/pcap/pcap.h
#  - https://wiki.wireshark.org/Development/LibpcapFileFormat
#
# Integers in the pcap file will use native endianness and the endianness can
# be inferred by check layout of the magic 0xa1b2c3d4
#
# 	pcap file header: 24 bytes
# 	pcap packet header: 16 bytes: 4 sec, 4 usec, 4 caplen, 4 len
# 	pcap packet data
# 	pcap packet header: 16 bytes: 4 sec, 4 usec, 4 caplen, 4 len
# 	pcap packet data
# 	...
#
#
PKG_NAME=tcpdump
PKG_VERSION=4.9.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.tcpdump.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a4ead41d371f91aa0a2287f589958bae
PKG_DEPENDS='libpcap openssl'

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS="libnl3 $PKG_DEPENDS"
fi

CONFIGURE_ARGS+=(
	--with-system-libpcap
)
