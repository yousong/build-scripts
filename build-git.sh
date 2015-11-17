#!/bin/sh -e

# Extra packages has to be installed to support https helper etc.
#
#   apt-get install -y curl-devel
#
#   yum -y groupinstall "Development Tools"
#   yum-builddep git-email
#
# Manpages and perl bindings are installed with readonly permissions 0444.  To overwrite previous install, clean them
#
#	rm -rfv /home/yousong/.usr/share/man/man3/Git*
#	rm -rfv /home/yousong/.usr/share/perl/5.14.2/Git*
#
PKG_NAME=git
PKG_VERSION="2.6.3"
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://www.kernel.org/pub/software/scm/git/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="b711be7628a4a2c25f38d859ee81b423"

. "$PWD/env.sh"

main
