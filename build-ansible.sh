#!/bin/bash -e
#
# Copyright 2013-2019 (c) Yousong Zhou
#
# Install requirements
#
#	pip install -r requirements.txt
#
# Example
#
#	# github streisand
#	ansible-playbook playbooks/streisand.yml -vvv
#
PKG_NAME=ansible
PKG_VERSION=2.8.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://releases.ansible.com/ansible/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6860a44bf6badad6a4f77091b53b04e3
PKG_PYTHON_VERSIONS=3

. "$PWD/env.sh"
. "$PWD/utils-python-package.sh"
