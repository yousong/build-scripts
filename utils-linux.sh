#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# config option names extracted from
# https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh
kconfig_docker() {
	kconfig_set_option CONFIG_NAMESPACES y
	kconfig_set_option CONFIG_NET_NS y
	kconfig_set_option CONFIG_PID_NS y
	kconfig_set_option CONFIG_IPC_NS y
	kconfig_set_option CONFIG_UTS_NS y

	kconfig_set_option CONFIG_CGROUPS y
	kconfig_set_option CONFIG_CGROUP_CPUACCT y
	kconfig_set_option CONFIG_CGROUP_DEVICE y
	kconfig_set_option CONFIG_CGROUP_FREEZER y
	kconfig_set_option CONFIG_CGROUP_SCHED y
	kconfig_set_option CONFIG_RT_GROUP_SCHED y
	kconfig_set_option CONFIG_FAIR_GROUP_SCHED y
	kconfig_set_option CONFIG_CFS_BANDWIDTH y

	kconfig_set_option CONFIG_MEMCG_SWAP_ENABLED y
	kconfig_set_option CONFIG_MEMCG_SWAP y

	kconfig_set_option CONFIG_CPUSETS y
	kconfig_set_option CONFIG_MEMCG y
	kconfig_set_option CONFIG_KEYS y
	kconfig_set_option CONFIG_OVERLAY_FS y

	kconfig_set_option CONFIG_VETH y
	kconfig_set_option CONFIG_BRIDGE y
	kconfig_set_option CONFIG_BRIDGE_NETFILTER y
	kconfig_set_option CONFIG_NF_NAT_IPV4 y
	kconfig_set_option CONFIG_IP_NF_FILTER y
	kconfig_set_option CONFIG_IP_NF_TARGET_MASQUERADE y
	kconfig_set_option CONFIG_NETFILTER_XT_MATCH_ADDRTYPE y
	kconfig_set_option CONFIG_NETFILTER_XT_MATCH_CONNTRACK y
	kconfig_set_option CONFIG_NETFILTER_XT_MATCH_IPVS y
	kconfig_set_option CONFIG_IP_NF_NAT y
	kconfig_set_option CONFIG_NF_NAT y
	kconfig_set_option CONFIG_NF_NAT_NEEDED y

	# required for bind-mounting /dev/mqueue into containers
	kconfig_set_option CONFIG_POSIX_MQUEUE y

	## Optional
	# Requires setting user_namespace.enable=1 on kernel command line
	#kconfig_set_option CONFIG_USER_NS y
	kconfig_set_option CONFIG_SECCOMP y
	kconfig_set_option CONFIG_CGROUP_PIDS y
}

kconfig_bbr() {
	# To use BBR
	#
	#	net.core.default_qdisc=fq
	#	net.ipv4.tcp_congestion_control=bbr
	#
	# To find available tcp congestion algo
	#
	#	sysctl net.ipv4.tcp_available_congestion_control
	#
	kconfig_set_option CONFIG_TCP_CONG_BBR y
	kconfig_set_option CONFIG_NET_SCH_CODEL y
	kconfig_set_option CONFIG_NET_SCH_FQ y
	kconfig_set_option CONFIG_NET_SCH_FQ_CODEL y
}

kconfig_openvswitch() {
	kconfig_set_option CONFIG_NET_IPGRE y
	kconfig_set_option CONFIG_VXLAN y
	kconfig_set_option CONFIG_GENEVE y
	kconfig_set_option CONFIG_OPENVSWITCH y
	kconfig_set_option CONFIG_OPENVSWITCH_GRE y
	kconfig_set_option CONFIG_OPENVSWITCH_VXLAN y
	kconfig_set_option CONFIG_OPENVSWITCH_GENEVE y
}

kconfig_dpdk() {
	kconfig_set_option CONFIG_UIO y
	kconfig_set_option CONFIG_HUGETLBFS y
	kconfig_set_option CONFIG_PROC_PAGE_MONITOR y
	kconfig_set_option CONFIG_HPET y
	kconfig_set_option CONFIG_HPET_MMAP y
}

kconfig_wireguard() {
	# https://www.wireguard.com/install/
	kconfig_set_option CONFIG_NET y # for basic networking support
	kconfig_set_option CONFIG_INET y # for basic IP support
	kconfig_set_option CONFIG_NET_UDP_TUNNEL y # for sending and receiving UDP packets
	kconfig_set_option CONFIG_CRYPTO_BLKCIPHER y # for doing scatter-gather I/O
	kconfig_set_option CONFIG_PADATA y # for parallel crypto, only available on multi-core machines
}

# Refs
#
# - Using systemtap with self-built kernels,
#   https://sourceware.org/systemtap/wiki/SystemTapWithSelfBuiltKernel
# - systemtap README, https://sourceware.org/git/gitweb.cgi?p=systemtap.git;a=blob;f=README
kconfig_systemtap() {
	# DEBUG_INFO means "gcc -g" and the resulting binaries have it.  In the
	# case of RHEL family distributions
	#
	#  - kernel-debuginfo is mostly just the build tree installed into
	#    /usr/lib/debug/lib/modules/<uname -r>/
	#  - kernel-debuginfo-common contains the source code shared by all builds
	#
	# This can make the build tree very big (up to around 1GB)
	kconfig_set_option CONFIG_DEBUG_INFO y
	kconfig_set_option CONFIG_KPROBES y
	kconfig_set_option CONFIG_RELAY y
	kconfig_set_option CONFIG_DEBUG_FS y
	kconfig_set_option CONFIG_MODULES y
	kconfig_set_option CONFIG_MODULE_UNLOAD y

	# uprobe was merged since mainline 3.5; utrace was deprecated then. For
	# older kernels, have fun kniting patches
	kconfig_set_option CONFIG_UPROBES y

	# It says in the wiki that SystemTap does not support this
	kconfig_set_option CONFIG_DEBUG_INFO_SPLIT n
}

kconfig_blk_nbd() {
	kconfig_set_option CONFIG_NET y
	kconfig_set_option CONFIG_BLK_DEV_NBD m
}
