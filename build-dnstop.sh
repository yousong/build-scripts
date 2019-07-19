#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It uses curses-ui for interaction
#
#	-4	Count IPv4 packets
#	-6	Count IPv6 packets
#		Count both if neither -4, -6 were present
#	-Q	Count queries
#	-R	Count responses
#		Count only queries by default
#	-l N	Domain stats up to N components.  N>=1 && N<=9
#
# Use '?' for help
#
#	s	Sources list
#	t	Query types
#	9	9th level Query Names.  Literally whole name
#	(	9th level Query Names with Sources
#
# Example
#
# 	sudo dnstop -4 -Q -l 9 br0
#
PKG_NAME=dnstop
PKG_VERSION=2018-05-22
PKG_SOURCE_PROTO=git
PKG_SOURCE_VERSION=a5a5d2e2ca9a433bb8f017682ac6f2085741bdf8
PKG_SOURCE_URL=https://github.com/measurement-factory/dnstop.git
PKG_DEPENDS='libpcap ncurses'

. "$PWD/env.sh"
