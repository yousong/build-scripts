#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# bmv2 is mainly written in C++.  It uses c++11 feature alignas which is
# supported in GCC only since version 4.8.
#
# If we decided to compile with our custom toolchain like GCC 7.1, we will
# also need to rebuild all bmv2's dependencies, including boost, libpcap,
# libnanomsg, libjudy, etc.
#
PKG_NAME=bmv2
PKG_VERSION=2017-06-17
PKG_SOURCE_VERSION=7da419ab4a0ae57f1ab82cacd6a704397022ad2c
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/p4lang/behavioral-model/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_DEPENDS='gmp judy libpcap nanomsg openssl python2 thrift'
PKG_SOURCE_UNTAR_FIXUP=1
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
There are unused parameters like "other" in somes classes' constructors

--- a/configure.ac.orig	2017-06-20 14:18:30.413007476 +0800
+++ b/configure.ac	2017-06-20 14:05:53.405506297 +0800
@@ -215,7 +215,7 @@ AC_SUBST([AM_CPPFLAGS], ["$MY_CPPFLAGS \
                           -isystem\$(top_srcdir)/third_party/jsoncpp/include \
                           -isystem\$(top_srcdir)/third_party/spdlog"])
 
-AC_SUBST([AM_CXXFLAGS], ["$PTHREAD_CFLAGS -Wall -Werror -Wextra"])
+AC_SUBST([AM_CXXFLAGS], ["$PTHREAD_CFLAGS -Wall -Wextra"])
 AC_SUBST([AM_CFLAGS], ["$PTHREAD_CFLAGS"])
 
 # Checks for typedefs, structures, and compiler characteristics.
EOF

	patch -p1 <<"EOF"

Including <functional> explicitly is needed for GCC 7

--- a/include/bm/bm_sim/packet_handler.h.orig	2017-06-20 11:39:58.700205326 +0800
+++ b/include/bm/bm_sim/packet_handler.h	2017-06-20 11:40:05.660207502 +0800
@@ -16,6 +16,8 @@
 #ifndef BM_BM_SIM_PACKET_HANDLER_H_
 #define BM_BM_SIM_PACKET_HANDLER_H_
 
+#include <functional>
+
 namespace bm {
 
 class PacketDispatcherIface {
--- a/third_party/spdlog/bm/spdlog/spdlog.h.orig	2017-06-20 11:32:17.224060886 +0800
+++ b/third_party/spdlog/bm/spdlog/spdlog.h	2017-06-20 11:32:25.424063455 +0800
@@ -28,6 +28,8 @@
 
 #pragma once
 
+#include <functional>
+
 #include "tweakme.h"
 #include "common.h"
 #include "logger.h"
EOF

	patch -p1 <<"EOF"

Fixes the following compilation errors

	pcap_file.cpp: In member function 'std::unique_ptr<bm::PcapPacket> bm::PcapFileIn::current() const':
	pcap_file.cpp:152:21: error: this statement may fall through [-Werror=implicit-fallthrough=]
		 pcap_fatal_error("Must call moveNext() before calling current()");
		 ~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	pcap_file.cpp:153:3: note: here
	   case State::AtEnd:
	   ^~~~

--- a/src/bm_sim/pcap_file.cpp.orig	2017-06-20 11:46:07.300320694 +0800
+++ a/src/bm_sim/pcap_file.cpp	2017-06-20 11:46:24.740326152 +0800
@@ -31,7 +31,7 @@ namespace bm {
 namespace {
 
 // TODO(antonin): remove or good enough?
-void pcap_fatal_error(const std::string &message) {
+__attribute__((noreturn)) void pcap_fatal_error(const std::string &message) {
   Logger::get()->critical(message);
   exit(1);
 }
EOF
}

EXTRA_CFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")
EXTRA_CPPFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")
EXTRA_CXXFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")
EXTRA_LDFLAGS+=(-L"$INSTALL_PREFIX/boost/boost-1.61/lib")
EXTRA_LDFLAGS+=( -L"$INSTALL_PREFIX/boost/boost-1.61/lib" -Wl,-rpath,"$INSTALL_PREFIX/boost/boost-1.61/lib" )
