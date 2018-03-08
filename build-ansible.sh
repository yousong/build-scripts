#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
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
PKG_VERSION=2.3.0.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://releases.ansible.com/ansible/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=cf19fa58f534700322250e70bb24fcc9
PKG_PYTHON_VERSIONS=2

. "$PWD/env.sh"
. "$PWD/utils-python-package.sh"
