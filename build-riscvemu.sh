#!/bin/bash -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=riscvemu
PKG_VERSION=2017-08-06
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://bellard.org/riscvemu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5d8ffc2d9966b900794c9cbb477ff16a
PKG_DEPENDS='curl'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- Makefile.orig	2017-08-16 10:50:08.192673537 +0800
+++ Makefile	2017-08-16 10:50:59.780689683 +0800
@@ -98,6 +98,9 @@ LDFLAGS+=-mwindows
 endif
 endif
 
+CFLAGS+=$(EXTRA_CFLAGS)
+LDFLAGS+=$(EXTRA_LDFLAGS)
+
 RISCVEMU_OBJS:=$(EMU_OBJS) riscvemu.o riscv_machine.o softfp.o
 
 X86EMU_OBJS:=$(EMU_OBJS) x86emu.o x86_cpu.o x86_machine.o ide.o ps2.o vmmouse.o pckbd.o vga.o
EOF
	patch -p0 <<"EOF"
Fix the following compilation errors

	riscvemu.c: In function ‘virt_machine_run’:
	riscvemu.c:584:31: error: ‘stdin_fd’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
	gcc -O2 -Wall -g -Werror -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -MMD -D_GNU_SOURCE -DCONFIG_VERSION=\"2017-08-06\" -DCONFIG
	_SLIRP -DCONFIG_FS_NET -DCONFIG_SDL -isystem /home/yousong/.usr/include -c -o ps2.o ps2.c
	cc1: all warnings being treated as errors
	make: *** [riscvemu.o] Error 1
--- riscvemu.c.orig	2017-08-16 10:54:03.644747231 +0800
+++ riscvemu.c	2017-08-16 10:55:07.344767168 +0800
@@ -541,9 +541,6 @@ void virt_machine_run(VirtMachine *m)
     fd_set rfds, wfds, efds;
     int fd_max, ret, delay;
     struct timeval tv;
-#ifndef _WIN32
-    int stdin_fd;
-#endif
     
     delay = virt_machine_get_sleep_duration(m, MAX_SLEEP_TIME);
     
@@ -555,7 +552,7 @@ void virt_machine_run(VirtMachine *m)
 #ifndef _WIN32
     if (m->console_dev && virtio_console_can_write_data(m->console_dev)) {
         STDIODevice *s = m->console->opaque;
-        stdin_fd = s->stdin_fd;
+        int stdin_fd = s->stdin_fd;
         FD_SET(stdin_fd, &rfds);
         fd_max = stdin_fd;
 
@@ -581,6 +578,8 @@ void virt_machine_run(VirtMachine *m)
     }
     if (ret > 0) {
 #ifndef _WIN32
+        STDIODevice *s = m->console->opaque;
+        int stdin_fd = s->stdin_fd;
         if (m->console_dev && FD_ISSET(stdin_fd, &rfds)) {
             uint8_t buf[128];
             int ret, len;
EOF
}

configure() {
	true
}

staging() {
	true
}

install() {
	true
}

# disable SDL because the version installed by apt-get requires libuuid 1.0
# (symbol uuid_generate@UUID_1.0) while the one installed by us is libuuid 1.2
MAKE_VARS+=(
	EXTRA_CFLAGS="${EXTRA_CFLAGS[*]}"
	EXTRA_LDFLAGS="${EXTRA_LDFLAGS[*]}"
	CONFIG_SDL=
)
