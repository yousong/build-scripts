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
# Read git.centos.org git logs, you may find that kernel versions are not
# continuous.  One tagged version may get lost in the "%changelog" on later
# version bump, e.g. the entry for 1062.1.2 got lost when bumping to 1062.4.1
# in commit b876298a
#
# - https://git.centos.org/rpms/kernel/commits/c7
# - http://vault.centos.org/centos/7/updates/Source/SPackages/
# - Red Hat Enterprise Linux Release Dates, https://access.redhat.com/articles/3078
#
centos_major="${centos_major:-7}"
centos_kernel_buildid="${centos_kernel_buildid:-.bs}"
centos_kernel_buildid=.yn20191203
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
@@ -453,6 +453,9 @@ Patch1000: debrand-single-cpu.patch
 Patch1001: debrand-rh_taint.patch
 Patch1002: debrand-rh-i686-cpu.patch
 
+Patch2000: fix-building-nbd.patch
+Patch2001: KVM-x86-Allow-suppressing-prints-on-RDMSR-WRMSR-of-u.patch
+
 BuildRoot: %{_tmppath}/kernel-%{KVRA}-root
 
 %description
@@ -796,6 +798,9 @@ ApplyOptionalPatch debrand-single-cpu.pa
 ApplyOptionalPatch debrand-rh_taint.patch
 ApplyOptionalPatch debrand-rh-i686-cpu.patch
 
+ApplyOptionalPatch fix-building-nbd.patch
+ApplyOptionalPatch KVM-x86-Allow-suppressing-prints-on-RDMSR-WRMSR-of-u.patch
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

	cat >KVM-x86-Allow-suppressing-prints-on-RDMSR-WRMSR-of-u.patch <<"EOF"
Upstream fab0aa3b776f0a3af1db1f50e04f1884015f9082

  Subject: [PATCH] KVM: x86: Allow suppressing prints on RDMSR/WRMSR of
   unhandled MSRs

  Some guests use these unhandled MSRs very frequently.
  This cause dmesg to be populated with lots of aggregated messages on
  usage of ignored MSRs. As ignore_msrs=true means that the user is
  well-aware his guest use ignored MSRs, allow to also disable the
  prints on their usage.

  An example of such guest is ESXi which tends to access a lot to MSR
  0x34 (MSR_SMI_COUNT) very frequently.

  In addition, we have observed this to cause unnecessary delays to
  guest execution. Such an example is ESXi which experience networking
  delays in it's guests (L2 guests) because of these prints (even when
  prints are rate-limited). This can easily be reproduced by pinging
  from one L2 guest to another.  Once in a while, a peak in ping RTT
  will be observed. Removing these unhandled MSR prints solves the
  issue.

  Because these prints can help diagnose issues with guests,
  this commit only suppress them by a module parameter instead of
  removing them from code entirely.

  Signed-off-by: Eyal Moscovici <eyal.moscovici@oracle.com>
  Reviewed-by: Liran Alon <liran.alon@oracle.com>
  Reviewed-by: Krish Sadhukhan <krish.sadhukhan@oracle.com>
  Signed-off-by: Krish Sadhukhan <krish.sadhukhan@oracle.com>
  Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
  [Changed suppress_ignore_msrs_prints to report_ignored_msrs - Radim]
  Signed-off-by: Radim Krčmář <rkrcmar@redhat.com>

--- a/arch/x86/kvm/x86.c.orig	2019-12-03 02:22:43.713015134 +0000
+++ b/arch/x86/kvm/x86.c	2019-12-03 02:25:35.970851847 +0000
@@ -106,6 +106,9 @@ EXPORT_SYMBOL_GPL(kvm_x86_ops);
 static bool __read_mostly ignore_msrs = 0;
 module_param(ignore_msrs, bool, S_IRUGO | S_IWUSR);
 
+static bool __read_mostly report_ignored_msrs = true;
+module_param(report_ignored_msrs, bool, S_IRUGO | S_IWUSR);
+
 unsigned int min_timer_period_us = 500;
 module_param(min_timer_period_us, uint, S_IRUGO | S_IWUSR);
 
@@ -2320,7 +2323,9 @@ int kvm_set_msr_common(struct kvm_vcpu *
 		/* Drop writes to this legacy MSR -- see rdmsr
 		 * counterpart for further detail.
 		 */
-		vcpu_unimpl(vcpu, "ignored wrmsr: 0x%x data %llx\n", msr, data);
+		if (report_ignored_msrs)
+			vcpu_unimpl(vcpu, "ignored wrmsr: 0x%x data 0x%llx\n",
+				msr, data);
 		break;
 	case MSR_AMD64_OSVW_ID_LENGTH:
 		if (!guest_cpuid_has(vcpu, X86_FEATURE_OSVW))
@@ -2342,8 +2347,10 @@ int kvm_set_msr_common(struct kvm_vcpu *
 				    msr, data);
 			return 1;
 		} else {
-			vcpu_unimpl(vcpu, "ignored wrmsr: 0x%x data %llx\n",
-				    msr, data);
+			if (report_ignored_msrs)
+				vcpu_unimpl(vcpu,
+					"ignored wrmsr: 0x%x data 0x%llx\n",
+					msr, data);
 			break;
 		}
 	}
@@ -2564,7 +2571,9 @@ int kvm_get_msr_common(struct kvm_vcpu *
 					       msr_info->index);
 			return 1;
 		} else {
-			vcpu_unimpl(vcpu, "ignored rdmsr: 0x%x\n", msr_info->index);
+			if (report_ignored_msrs)
+				vcpu_unimpl(vcpu, "ignored rdmsr: 0x%x\n",
+					msr_info->index);
 			msr_info->data = 0;
 		}
 		break;
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
