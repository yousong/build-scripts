#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=bcc
PKG_VERSION=0.3.0
PKG_SOURCE_VERSION="$PKG_VERSION"
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/iovisor/bcc/archive/v$PKG_SOURCE_VERSION.tar.gz"
PKG_DEPENDS='luajit libelf'
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"
env_init_llvm_toolchain

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
--- a/src/python/CMakeLists.txt.orig	2017-06-24 19:08:10.912790987 +0800
+++ b/src/python/CMakeLists.txt	2017-06-24 19:08:15.940792560 +0800
@@ -21,9 +21,6 @@ add_custom_command(OUTPUT ${PIP_INSTALLA
   )
 add_custom_target(bcc_py ALL DEPENDS ${PIP_INSTALLABLE})
 
-if(EXISTS "/etc/debian_version")
-  set(PYTHON_FLAGS "${PYTHON_FLAGS} --install-layout deb")
-endif()
 install(CODE "execute_process(COMMAND ${PYTHON_CMD} setup.py install -f ${PYTHON_FLAGS}
-  --prefix=${CMAKE_INSTALL_PREFIX} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})"
+  --root=$(DESTDIR) --prefix=${CMAKE_INSTALL_PREFIX} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})"
   COMPONENT python)
EOF
}

CMAKE_ARGS+=(
	-DLLVM_DIR="$INSTALL_PREFIX/toolchain/llvm-4.0.0/lib/cmake/llvm"
)
