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
