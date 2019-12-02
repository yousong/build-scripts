#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Prerequisites
#
#	yum groupinstall "Development Tools"
#	yum install ncurses-devel
#	yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel
#
# - https://git.centos.org/rpms/kernel/commits/c7
#
centos_major="${centos_major:-7}"
centos_kernel_buildid="${centos_kernel_buildid:-.bs}"
centos_kernel_buildid=.yn20191202
if [ "${centos_kernel_buildid#.}" = "${centos_kernel_buildid}" ]; then
	echo "bad \$centos_kernel_buildid: must start with a dot" >&2
	false
fi

case "$centos_major" in
	7)
		centos_kernel_mainline_version=3.10.0
		centos_kernel_revision_default=1062.4.3.el7
		centos_kernel_revision="${centos_kernel_revision:-$centos_kernel_revision_default}"
		centos_kernel_version="$centos_kernel_mainline_version-$centos_kernel_revision"
		;;
	*)
		echo "unknown centos major version" >&2
		false
esac
centos_cN="c$centos_major"
centos_elN="el$centos_major"

PKG_NAME="kernel-c$centos_major"
PKG_VERSION="$centos_kernel_version"

centos_use_git=
if [ -n "$centos_use_git" ]; then
	PKG_SOURCE="kernel-$PKG_VERSION.tar.gz"
	PKG_SOURCE_URL="https://git.centos.org/rpms/kernel.git"
	PKG_SOURCE_PROTO=git
	PKG_SOURCE_VERSION=
else
	PKG_SOURCE="kernel-$PKG_VERSION.src.rpm"
	PKG_SOURCE_URL="http://vault.centos.org/centos/$centos_major/updates/Source/SPackages/$PKG_SOURCE"
	: PKG_SOURCE_URL="http://vault.centos.org/centos/$centos_major/os/Source/SPackages/$PKG_SOURCE"
	PKG_SOURCE_MD5SUM=361e1129ce338348f3daffba083297b5
fi

PKG_BUILD_DIR_BASENAME="$PKG_NAME-$PKG_VERSION"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=no

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"
. "$PWD/utils-linux.sh"

centos_kernel_BUILD_DIR="$PKG_BUILD_DIR/BUILD/kernel-$PKG_VERSION/linux-$PKG_VERSION$centos_kernel_buildid.x86_64"
centos_kernel_SOURCES_DIR="$PKG_BUILD_DIR/SOURCES"
centos_kernel_SPECS_DIR="$PKG_BUILD_DIR/SPECS"
centos_kernel_RPMS_DIR="$PKG_BUILD_DIR/RPMS"
centos_kernel_spec="$centos_kernel_SPECS_DIR/kernel.spec"

EXTRA_CFLAGS=()
EXTRA_CPPFLAGS=()
EXTRA_LDFLAGS=()
MAKE_VARS=(
	V=1
)
STRIP=()

_rpmbuild() {
	local topdir="$PKG_BUILD_DIR"
	rpmbuild \
		-D "%_topdir $topdir" \
		-D "%buildid $centos_kernel_buildid" \
		"$@" \

}

do_patch() {
	cd "$centos_kernel_SOURCES_DIR"
	for config in *.config; do
		kconfig_set_option CONFIG_BLK_DEV_NBD m "$config"
		kconfig_set_option CONFIG_HFSPLUS_FS m "$config"
		kconfig_set_option CONFIG_VFIO_PCI_VGA y "$config"

		kconfig_set_option CONFIG_OCFS2_FS m "$config"
		kconfig_set_option CONFIG_OCFS2_FS_O2CB y "$config"
		kconfig_set_option CONFIG_OCFS2_FS_USERSPACE_CLUSTER y "$config"
		kconfig_set_option CONFIG_OCFS2_FS_STATS y "$config"
		kconfig_set_option CONFIG_OCFS2_DEBUG_MASKLOG y "$config"
		kconfig_set_option CONFIG_OCFS2_DEBUG_FS y "$config"
	done
	patch -p1 <<"EOF"
--- a/kernel.spec.orig	2019-10-16 11:03:06.163470259 +0000
+++ b/kernel.spec	2019-10-16 11:04:15.509438768 +0000
@@ -453,6 +453,8 @@ Patch1000: debrand-single-cpu.patch
 Patch1001: debrand-rh_taint.patch
 Patch1002: debrand-rh-i686-cpu.patch
 
+Patch2000: fix-building-nbd.patch
+
 BuildRoot: %{_tmppath}/kernel-%{KVRA}-root
 
 %description
@@ -796,6 +798,8 @@ ApplyOptionalPatch debrand-single-cpu.pa
 ApplyOptionalPatch debrand-rh_taint.patch
 ApplyOptionalPatch debrand-rh-i686-cpu.patch
 
+ApplyOptionalPatch fix-building-nbd.patch
+
 # Any further pre-build tree manipulations happen here.
 
 chmod +x scripts/checkpatch.pl
EOF
	cat >fix-building-nbd.patch <<"EOF"
Fix building nbd.ko

> Phil Perry pperry at elrepo.org wrote:
>
> Because Red Hat do not configure and build this module, they do not
> maintain the code for it in their kernel.
>
> REQ_TYPE_SPECIAL was renamed to REQ_TYPE_DRV_PRIV some time back, so try
> patching for that in nbd.c and rebuilding.
>
> Be aware that by building the unmaintained module you will be missing
> all relevant security patches for this module since RHEL7 was first
> released some 3.5 years ago. A better solution would be to backport the
> module from the latest upstream kernel and maintain it out of tree.

Ref: https://lists.centos.org/pipermail/centos/2017-October/167060.html

--- a/drivers/block/nbd.c.orig	2019-10-16 08:43:53.871794075 +0000
+++ b/drivers/block/nbd.c	2019-10-16 08:44:00.242791771 +0000
@@ -616,7 +616,7 @@ static int __nbd_ioctl(struct block_devi
 		fsync_bdev(bdev);
 		mutex_lock(&nbd->tx_lock);
 		blk_rq_init(NULL, &sreq);
-		sreq.cmd_type = REQ_TYPE_SPECIAL;
+		sreq.cmd_type = REQ_TYPE_DRV_PRIV;
 		nbd_cmd(&sreq) = NBD_CMD_DISC;
 
 		/* Check again after getting mutex back.  */
EOF
}

prepare() {
	mkdir -p "$centos_kernel_SOURCES_DIR"
	mkdir -p "$centos_kernel_SPECS_DIR"
	cd "$centos_kernel_SOURCES_DIR"
	rpm2cpio "$BASE_DL_DIR/$PKG_SOURCE" \
		| cpio -id

	do_patch
	cp "$centos_kernel_SOURCES_DIR/kernel.spec" "$centos_kernel_spec"
}

configure() {
	true

}

compile() {
	_rpmbuild \
		-bb \
		--without debug \
		--without debuginfo \
		--without doc \
		--without kabichk \
		--without perf \
		--with kdump \
		"$centos_kernel_spec"

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
	local frpm

	__errmsg "List of packages"
	__errmsg ""
	for frpm in "$centos_kernel_RPMS_DIR/x86_64/"*.rpm; do
		if [ -f "$frpm" ]; then
			__errmsg "	sudo rpm -ivh $frpm"
		fi
	done
}
