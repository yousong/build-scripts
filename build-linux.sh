#!/bin/sh -e
#
# Build a kernel with embedded initramfs for trying various kernel features
#
# Initramfs will be constructed with busybox so build it statically first
#
PKG_NAME=linux
PKG_VERSION=4.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%.*}.x/$PKG_SOURCE"
#PKG_SOURCE_URL="http://mirrors.ustc.edu.cn/linux-kernel/v${PKG_VERSION%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="58b35794eee3b6d52ce7be39357801e7"
PKG_PLATFORM=linux

. "$PWD/env.sh"

EXTRA_CFLAGS=
EXTRA_CPPFLAGS=
EXTRA_LDFLAGS=
MAKE_VARS="V=1"

# WiP
#
# 2. Default init is `/init`, or specify it with `rdinit=/linuxrc`
# 3. init/main.c: see "call chain of start_kernel()" in kernel-notes.md
# 4. /proc/cpuinfo will have flag `hypervisor' when running on a hypervisor
#
# Refs
#
# - http://www.helptouser.com/unixlinux/235281-is-there-a-way-to-get-linux-to-treat-an-initramfs-as-the-final-root-filesystem.html
# - http://stackoverflow.com/questions/10437995/initramfs-built-into-custom-linux-kernel-is-not-running
#
INITRAMFS_BASE="$PKG_BUILD_DIR/_b"
INITRAMFS_DIR="$INITRAMFS_BASE/_initramfs"

prepare_extra() {
	local bbpath="$INSTALL_PREFIX/bin/busybox"
	local bin

	# busybox has to be statically linked
	[ -n "$bbpath" -a -x "$bbpath" ]
	file $bbpath | grep -q 'statically linked'

	rm -rf "$INITRAMFS_DIR"
	mkdir -p "$INITRAMFS_DIR"

	cd "$INITRAMFS_DIR"
	mkdir -p bin sbin usr/bin usr/sbin
	/bin/cp "$bbpath" "$INITRAMFS_DIR/bin/"
	for bin in mount sh; do
		ln -s /bin/busybox "$INITRAMFS_DIR/bin/$bin"
	done

	cat >init <<EOF
#!/bin/sh
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t tmpfs none /tmp
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
busybox --install

exec setsid sh -c 'while true; do echo; echo Press any key to activate this console; read; /bin/sh </dev/ttyS0 &>/dev/ttyS0; done'
EOF
	chmod a+x init

	# Copied from OpenWrt base-files
	cat >"$INITRAMFS_BASE/base-files.txt" <<EOF
dir /proc 755 0 0
dir /sys 755 0 0
dir /tmp 777 0 0
dir /dev 755 0 0
dir /dev/pts 755 0 0
nod /dev/console 600 0 0 c 5 1
nod /dev/null 666 0 0 c 1 3
nod /dev/zero 666 0 0 c 1 5
nod /dev/tty 666 0 0 c 5 0
nod /dev/tty0 660 0 0 c 4 0
nod /dev/tty1 660 0 0 c 4 1
nod /dev/random 666 0 0 c 1 8
nod /dev/urandom 666 0 0 c 1 9
EOF
}

_configure_ftrace() {
	# FTRACE support in kernel,
	#
	# -Debugging the kernel using Ftrace - part 1, http://lwn.net/Articles/365835/
	#
	#		mount -t debugfs none /sys/kernel/debug
	#		cd /sys/kernel/debug/tracing
	#		cat available_tracers
	#		echo function >current_tracer
	#		head -n32 trace
	#		echo function_graph >current_tracer
	#		head -n32 trace
	#		echo 1 >tracing_on
	#		echo 0 >tracing_on
	#
	# - trace-cmd: A front-end for Ftrace, https://lwn.net/Articles/410200/
	#
	#	trace-cmd is also available in OpenWrt package/devel/trace-cmd
	#
	# - https://github.com/rostedt/trace-cmd
	# - http://git.kernel.org/cgit/linux/kernel/git/rostedt/trace-cmd.git/?h=trace-cmd-v2.6
	#
	cat <<EOF
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_STACK_TRACER=y
CONFIG_DYNAMIC_FTRACE=y
EOF
}

configure() {
	cd "$PKG_BUILD_DIR"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	cat >.config <<EOF
CONFIG_DEBUG_INFO=y
CONFIG_SMP=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_COMPAQ is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_IBM is not set
CONFIG_HOTPLUG_PCI_PCIE=y
# CONFIG_HOTPLUG_PCI_SHPC is not set
CONFIG_BLK_DEV_INITRD=y
# CONFIG_BLOCK is not set
CONFIG_INITRAMFS_SOURCE="$INITRAMFS_DIR $INITRAMFS_BASE/base-files.txt"
CONFIG_INITRAMFS_ROOT_UID=$(id -u)
CONFIG_INITRAMFS_ROOT_GID=$(id -g)
# CONFIG_RD_GZIP is not set
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZ4 is not set
CONFIG_TMPFS=y
CONFIG_DEVTMPFS=y
EOF
	#_configure_ftrace >>.config
	make ARCH=x86_64 kvmconfig
}

staging() {
	true
}

install() {
	true
}

uninstall() {
	true
}

install_post() {
	cat <<EOF

Test the built kernel

	qemu-system-x86_64 -smp cpus=4 -m 32 -nographic -kernel $PKG_BUILD_DIR/arch/x86/boot/bzImage -append 'console=ttyS0'

EOF
}
