Shell scripts for quickly building different versions of several projects.

- Edit `env.sh` before building.

- Not trying to be foolproof.

	Previously experience with the target project and some shell scripting is
	expected.

- Scripts are executed with `/bin/sh -e`.
- Try to be reentrant.
- Use abs path in scripts.

On CentOS 6.6, manpages installed manually cannot be found man command by
default.  To solve this, try adding the following line to `/etc/man.config`

	MANPATH_MAP	/home/yousong/.usr/bin	/home/yousong/.usr/share/man

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
