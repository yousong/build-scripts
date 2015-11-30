#!/bin/sh -e
#
# Build a kernel with embedded initramfs for trying various kernel features
#
#		qemu-system-x86_64 -smp cpus=4 -m 32 -nographic -kernel arch/x86/boot/bzImage -append 'console=ttyS0'
#
# Initramfs will be constructed with busybox so build it statically first
PKG_NAME=linux
PKG_VERSION=4.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%.*}.x/$PKG_SOURCE"
#PKG_SOURCE_URL="http://mirrors.ustc.edu.cn/linux-kernel/v${PKG_VERSION%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="58b35794eee3b6d52ce7be39357801e7"

. "$PWD/env.sh"

if ! os_is_linux; then
	__errmsg "we build Linux kernel only on Linux"
	exit 1
fi

EXTRA_CFLAGS=
EXTRA_CPPFLAGS=
EXTRA_LDFLAGS=
MAKE_VARS="V=1"

# WiP
#
# 1. `dir` definition in initramfs-base-files.txt for `proc`, `sys`, `dev`,
#    `tmp` do not work.  They have to be firstly created on the specified
#    directory
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
	mkdir -p proc sys dev tmp
	mkdir -p bin sbin usr/bin usr/sbin

	/bin/cp "$bbpath" "$INITRAMFS_DIR/bin/"
	for bin in mount sh; do
		ln -s /bin/busybox "$INITRAMFS_DIR/bin/$bin"
	done

	cat >init <<EOF
#!/bin/sh
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
mount -t tmpfs none /tmp
busybox --install

exec /bin/sh
EOF
	chmod a+x init

	# Copied from OpenWrt base-files
	cat >"$INITRAMFS_BASE/base-files.txt" <<EOF
nod /dev/console 600 0 0 c 5 1
nod /dev/null 666 0 0 c 1 3
nod /dev/zero 666 0 0 c 1 5
nod /dev/tty 666 0 0 c 5 0
nod /dev/tty0 660 0 0 c 4 0
nod /dev/tty1 660 0 0 c 4 1
nod /dev/random 666 0 0 c 1 8
nod /dev/urandom 666 0 0 c 1 9
dir /dev/pts 755 0 0
EOF
}

build_configure() {
	cd "$PKG_BUILD_DIR"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	cat >>.config <<EOF
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
EOF
	make ARCH=x86_64 kvmconfig
}

install_do() {
	cd "$PKG_BUILD_DIR"
}

main
