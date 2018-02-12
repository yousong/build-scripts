#
# Copyright 2015-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# tarballs of golang are prefixed with go/ without version information
PKG_SOURCE_UNTAR_FIXUP=1

GO_RELEASE_VER="${PKG_VERSION%.*}"
GOROOT_FINAL="$INSTALL_PREFIX/go/goroot-$PKG_VERSION"
# most files in go are not compiled by GNU tools...  It may happen that
#
#	strip: Unable to recognise the format of the input file
#
# even though `file` utility recognizes them
STRIP=()

configure() {
	true
}

compile() {
	# ianlancetaylor:
	#
	# > You are only going to use Go 1.4 to build a newer release of Go. That
	# > test failure does not matter. We are not going to ensure that all Go 1.4
	# > tests continue to pass when using newer compilers and newer operating
	# > system versions. We are only going to ensure that Go 1.4 works to build
	# > newer releases of Go, and ensure that the tests of those newer releases
	# > pass.
	#
	# > The instructions do not recommend that you run the Go 1.4 all.bash. I
	# > don't recommend it either. If you choose to follow that path, I'm afraid
	# > that you are on your own.
	#
	# https://github.com/golang/go/issues/18771#issuecomment-274879224
	local script
	if [ "$GO_RELEASE_VER" = "1.4" ]; then
		script=make.bash
	else
		script=all.bash
	fi

	cd "$PKG_SOURCE_DIR/src"
	# --no-clean is for avoiding passing -a option to `go tool dist bootstrap`
	# to avoid "rebuild all"
	#
	# use make.bash on lowmem machine
	GOROOT_FINAL="$GOROOT_FINAL" \
		GOROOT_BOOTSTRAP="$GOROOT_BOOTSTRAP" \
		"./$script" --no-clean
}

staging() {
	local d="$PKG_STAGING_DIR$GOROOT_FINAL"

	mkdir -p "$d"
	cpdir "$PKG_SOURCE_DIR" "$d"
}

install() {
	local d="$PKG_STAGING_DIR$GOROOT_FINAL"

	mkdir -p "$GOROOT_FINAL"
	cpdir "$d" "$GOROOT_FINAL"
}

do_patch() {
	local ver="${PKG_VERSION%.*}"

	cd "$PKG_SOURCE_DIR"

	if [ "$ver" != "1.4" ]; then
		do_patch_go
	fi
}

do_patch_go() {
	patch -p1 <<"EOF"
CentOS 7 does not have user namespace enabled by default.  The syscall test
failed to detect and clone() call will fail with EINVAL

diff --git a/src/syscall/exec_linux_test.go b/src/syscall/exec_linux_test.go
index 114deec..7493787 100644
--- a/src/syscall/exec_linux_test.go
+++ b/src/syscall/exec_linux_test.go
@@ -35,6 +35,18 @@ func isChrooted(t *testing.T) bool {
 }
 
 func checkUserNS(t *testing.T) {
+	if whoami, err := exec.LookPath("whoami"); err == nil {
+		pid, err := syscall.ForkExec(whoami, []string{whoami}, &syscall.ProcAttr{
+			Sys: &syscall.SysProcAttr{
+				Cloneflags: syscall.CLONE_NEWUSER,
+			},
+		})
+		if err == nil {
+			syscall.Wait4(pid, nil, 0, nil)
+		} else {
+			t.Skipf("unable to clone with CLONE_NEWUSER: %v", err)
+		}
+	}
 	if _, err := os.Stat("/proc/self/ns/user"); err != nil {
 		if os.IsNotExist(err) {
 			t.Skip("kernel doesn't support user namespaces")
EOF
}
