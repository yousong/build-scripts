#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Extra packages has to be installed to support http,https transport (git-http-backend, etc.)
#
#   sudo apt-get install -y libcurl4-openssl-dev libssl-dev libexpat-dev
#   sudo yum install -y curl-devel openssl-devel expat-devel
#
#   yum -y groupinstall "Development Tools"
#   yum-builddep git-email
#
# Sometimes we need to install several perl modules for the git-send-email to work
#
#	sudo yum install -y perl-CPAN
#	sudo cpan Net::SMTP::SSL MIME::Base64 Authen::SASL
#
# Manpages and perl bindings are installed with readonly permissions 0444.  To overwrite previous install, clean them
#
#	rm -rfv /home/yousong/.usr/share/man/man3/Git*
#	rm -rfv /home/yousong/.usr/share/perl/5.14.2/Git*
#
PKG_NAME=git
PKG_VERSION=2.6.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.kernel.org/pub/software/scm/git/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=169409c2f9872797f1efb41fb9a99dc3
PKG_DEPENDS='curl libiconv openssl zlib'

. "$PWD/env.sh"
