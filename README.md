Scripts for quickly building/installing specified versions of projects from source code to specified locations.

- Edit `env.sh` settings before building
- Not trying to be foolproof

	Previously experience with the target project and some shell scripting experience is expected

- Scripts are executed with `/bin/sh -e`
- Try to be reentrant
- Use absolute path

## Backup Mirror

- https://distfiles.macports.org/$PKG_NAME

## Tips

On CentOS 6.6, manpages installed manually cannot be found by `man` command by default.  To solve this, try adding something like the following to `/etc/man.config`

	MANPATH_MAP	/home/yousong/.usr/bin	/home/yousong/.usr/share/man

Many of the times packages depend on the installation of other packages to be successfully built and run.  Currently we just use the distribution's package manager to install those dependencies for us.

	apt-get install build-essential
	apt-get build-dep openvpn
	apt-cache showsrc openvpn | grep Build-Depends

	yum -y groupinstall "Development Tools"
	yum-builddep openvpn

When dependencies cannot be satisfied by system package manager, we build the required version ourself.

## Background

There are times when we want to build packages from source for reasons like

1. The one provided by the distribution is old, has bugs, lacks the features.
	- QEMU, Vim, tmux, nginx, protobuf, openvswitch belong to this category
2. Or the distribution in concern does not provide it at all
	- ag (the_silver_searcher), crosstool-ng, mausezahn, libcli, mosh, openrestry, tengine are of this type
3. We want the process of `wget`, `configure`, `make`, `make install` to be automatic or at least semi-automatic.
	- Just specify the package name, version, url location, and optionally the MD5SUM of the source code, then viola.
4. We need to do customizations and want to make the process easily repeatable/reproducible at a later time
	- QEMU, nginx, vim are of this type
5. We want the effect/result of the build to be local without requiring root privileges or polutting the system directories
	- These packages will by default install to `$HOME/.usr` (the `--prefix` option)

The idea is not new, yet the result is rewarding.

Build scripts here uses the naming convention from OpenWrt package `Makefile`.

## TODO

	# install builddep with apt-get or yum
	./ag.sh builddep

	# download source tarballs
	./ag.sh download

	./ag.sh prepare
	./ag.sh build
	./ag.sh install

	./nginx.sh flavors
	FLAVOR=vanilla ./nginx.sh prepare
	FLAVOR=vanilla ./nginx.sh build

	# clean files in build_dir
	FLAVOR=vanilla ./nginx.sh clean

	# 1. prepare
	# 2. build
	# 3. install to staging area
	# 4. make a list of installed files
	# 5. remove files in final install area
	FLAVOR=vanilla ./nginx.sh uninstall

Or make

	make ag
	make ag/builddep
	make ag/download
	make ag/prepare
	make ag/build
	make ag/install

	make nginx FLAVOR=vanilla

	make ag/clean
	make ag/uninstall
