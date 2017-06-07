#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
GOROOT_FINAL="$INSTALL_PREFIX/go/goroot-$PKG_VERSION"
# tarballs of golang are prefixed with go/ without version information
PKG_SOURCE_UNTAR_FIXUP=1

configure() {
	true
}

compile() {
	cd "$PKG_SOURCE_DIR"

	cd src/
	# --no-clean is for avoiding passing -a option to `go tool dist bootstrap`
	# to avoid "rebuild all"
	GOROOT_FINAL="$GOROOT_FINAL" \
		GOROOT_BOOTSTRAP="$GOROOT_BOOTSTRAP" \
		./all.bash --no-clean
}

staging() {
	cpdir "$PKG_SOURCE_DIR" "$PKG_STAGING_DIR"
}

install() {
	mkdir -p "$GOROOT_FINAL"
	cpdir "$PKG_STAGING_DIR" "$GOROOT_FINAL"
}

do_patch_common() {
	# os/exec: TestNohup fails inside tmux, https://github.com/golang/go/issues/5135
	patch -p1 <<"EOF"
From acb47657096a728d10b33f2949b5a52ef5226b9d Mon Sep 17 00:00:00 2001
From: Aaron Jacobs <jacobsa@google.com>
Date: Tue, 25 Aug 2015 08:53:42 +1000
Subject: [PATCH] os/signal: skip the nohup test on darwin when running in
 tmux.

The nohup command doesn't work in tmux on darwin.

Fixes #5135.

Change-Id: I1c21073d8bd54b49dd6b0bad86ef088d6d8e7a5f
Reviewed-on: https://go-review.googlesource.com/13883
Reviewed-by: Brad Fitzpatrick <bradfitz@golang.org>
---
 src/os/signal/signal_test.go | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/src/os/signal/signal_test.go b/src/os/signal/signal_test.go
index a71633c..7942e78 100644
--- a/src/os/signal/signal_test.go
+++ b/src/os/signal/signal_test.go
@@ -255,6 +255,12 @@ func TestNohup(t *testing.T) {
 
 	Stop(c)
 
+	// Skip the nohup test below when running in tmux on darwin, since nohup
+	// doesn't work correctly there. See issue #5135.
+	if runtime.GOOS == "darwin" && os.Getenv("TMUX") != "" {
+		t.Skip("Skipping nohup test due to running in tmux on darwin")
+	}
+
 	// Again, this time with nohup, assuming we can find it.
 	_, err := os.Stat("/usr/bin/nohup")
 	if err != nil {
EOF
}

do_patch_go14() {
	patch -p1 <<"EOF"
From 4890699929da4d76a6b237cfce36e2d5b1bb1460 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Thu, 31 Dec 2015 21:36:27 +0800
Subject: [PATCH] backport: runtime: initialize extra M for cgo during mstart

backport from go1.5 "b8caed8 runtime: initialize extra M for cgo during
mstart"
---
 src/runtime/cgocall.go  | 5 -----
 src/runtime/proc.c      | 7 ++++++-
 src/runtime/sigqueue.go | 9 ---------
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/src/runtime/cgocall.go b/src/runtime/cgocall.go
index 7fd9146..490e129 100644
--- a/src/runtime/cgocall.go
+++ b/src/runtime/cgocall.go
@@ -101,11 +101,6 @@ func cgocall_errno(fn, arg unsafe.Pointer) int32 {
 		racereleasemerge(unsafe.Pointer(&racecgosync))
 	}
 
-	// Create an extra M for callbacks on threads not created by Go on first cgo call.
-	if needextram == 1 && cas(&needextram, 1, 0) {
-		onM(newextram)
-	}
-
 	/*
 	 * Lock g to m to ensure we stay on the same stack if we do a
 	 * cgo callback. Add entry to defer stack in case of panic.
diff --git a/src/runtime/proc.c b/src/runtime/proc.c
index 8462c4b..34adae7 100644
--- a/src/runtime/proc.c
+++ b/src/runtime/proc.c
@@ -852,8 +852,13 @@ mstart(void)
 
 	// Install signal handlers; after minit so that minit can
 	// prepare the thread to be able to handle the signals.
-	if(g->m == &runtime·m0)
+	if(g->m == &runtime·m0) {
+		if(runtime·needextram) {
+			runtime·needextram = 0;
+			runtime·newextram();
+		}
 		runtime·initsig();
+	}
 	
 	if(g->m->mstartfn)
 		g->m->mstartfn();
diff --git a/src/runtime/sigqueue.go b/src/runtime/sigqueue.go
index fed4560..2d9c24d 100644
--- a/src/runtime/sigqueue.go
+++ b/src/runtime/sigqueue.go
@@ -154,15 +154,6 @@ func signal_disable(s uint32) {
 // This runs on a foreign stack, without an m or a g.  No stack split.
 //go:nosplit
 func badsignal(sig uintptr) {
-	// Some external libraries, for example, OpenBLAS, create worker threads in
-	// a global constructor. If we're doing cpu profiling, and the SIGPROF signal
-	// comes to one of the foreign threads before we make our first cgo call, the
-	// call to cgocallback below will bring down the whole process.
-	// It's better to miss a few SIGPROF signals than to abort in this case.
-	// See http://golang.org/issue/9456.
-	if _SIGPROF != 0 && sig == _SIGPROF && needextram != 0 {
-		return
-	}
 	cgocallback(unsafe.Pointer(funcPC(sigsend)), noescape(unsafe.Pointer(&sig)), unsafe.Sizeof(sig))
 }
 
-- 
2.6.4
EOF
	patch -p1 <<"EOF"
From 082a2374fbe0d41e500158270e1ddc321c09a9e4 Mon Sep 17 00:00:00 2001
From: Brad Fitzpatrick <bradfitz@golang.org>
Date: Fri, 12 Dec 2014 15:54:24 +1100
Subject: [PATCH] cmd/api: update the API checker to Go 1.4 and git

Still using the ancient go/types API. Updating that to the modern API
should be a separate effort in a separate change.

Change-Id: Ic1c5ae3c13711d34fe757507ecfc00ee883810bf
Reviewed-on: https://go-review.googlesource.com/1404
Reviewed-by: David Symonds <dsymonds@golang.org>
---
 src/cmd/api/run.go | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/src/cmd/api/run.go b/src/cmd/api/run.go
index ed5613e..c2c6650 100644
--- a/src/cmd/api/run.go
+++ b/src/cmd/api/run.go
@@ -25,10 +25,10 @@ import (
 	"strings"
 )
 
-// goToolsVersion is the hg revision of the go.tools subrepo we need
+// goToolsVersion is the git revision of the x/tools subrepo we need
 // to build cmd/api.  This only needs to be updated whenever a go/types
 // bug fix is needed by the cmd/api tool.
-const goToolsVersion = "6698ca2900e2"
+const goToolsVersion = "875ff2496f865e" // aka hg 6698ca2900e2
 
 var goroot string
 
@@ -38,9 +38,9 @@ func main() {
 	if goroot == "" {
 		log.Fatal("No $GOROOT set.")
 	}
-	_, err := exec.LookPath("hg")
+	_, err := exec.LookPath("git")
 	if err != nil {
-		fmt.Println("Skipping cmd/api checks; hg not available")
+		fmt.Println("Skipping cmd/api checks; git not available")
 		return
 	}
 
@@ -108,7 +108,7 @@ func prepGoPath() string {
 	// The GOPATH we'll return
 	gopath := filepath.Join(os.TempDir(), "gopath-api-"+cleanUsername(username)+"-"+cleanUsername(strings.Fields(runtime.Version())[0]), goToolsVersion)
 
-	// cloneDir is where we run "hg clone".
+	// cloneDir is where we run "git clone".
 	cloneDir := filepath.Join(gopath, "src", "code.google.com", "p")
 
 	// The dir we clone into. We only atomically rename it to finalDir on
@@ -127,10 +127,7 @@ func prepGoPath() string {
 	if err := os.MkdirAll(cloneDir, 0700); err != nil {
 		log.Fatal(err)
 	}
-	cmd := exec.Command("hg",
-		"clone", "--rev="+goToolsVersion,
-		"https://code.google.com/p/go.tools",
-		tempBase)
+	cmd := exec.Command("git", "clone", "https://go.googlesource.com/tools", tempBase)
 	cmd.Dir = cloneDir
 	out, err := cmd.CombinedOutput()
 	if err != nil {
@@ -138,8 +135,15 @@ func prepGoPath() string {
 			log.Printf("# Skipping API check; network appears to be unavailable")
 			os.Exit(0)
 		}
-		log.Fatalf("Error running hg clone on go.tools: %v\n%s", err, out)
+		log.Fatalf("Error running git clone on x/tools: %v\n%s", err, out)
 	}
+	cmd = exec.Command("git", "reset", "--hard", goToolsVersion)
+	cmd.Dir = tmpDir
+	out, err = cmd.CombinedOutput()
+	if err != nil {
+		log.Fatalf("Error updating x/tools in %v to %v: %v, %s", tmpDir, goToolsVersion, err, out)
+	}
+
 	if err := os.Rename(tmpDir, finalDir); err != nil {
 		log.Fatal(err)
 	}
@@ -163,23 +167,22 @@ func goToolsCheckoutGood(dir string) bool {
 		return false
 	}
 
-	cmd := exec.Command("hg", "id", "--id")
+	cmd := exec.Command("git", "rev-parse", "HEAD")
 	cmd.Dir = dir
 	out, err := cmd.Output()
 	if err != nil {
 		return false
 	}
 	id := strings.TrimSpace(string(out))
-	if id != goToolsVersion {
+	if !strings.HasPrefix(id, goToolsVersion) {
 		return false
 	}
 
-	cmd = exec.Command("hg", "status")
+	cmd = exec.Command("git", "status", "--porcelain")
 	cmd.Dir = dir
 	out, err = cmd.Output()
-	if err != nil || len(out) > 0 {
+	if err != nil || strings.TrimSpace(string(out)) != "" {
 		return false
 	}
-
 	return true
 }
-- 
2.6.4

EOF

	patch -p1 <<"EOF"
From efe42509a20fca96d865dc525ecf55658b566662 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Wed, 7 Jun 2017 21:19:03 +0800
Subject: [PATCH] net: TestDialTimeout: skip if
 tcp_{syncookies,abort_on_overflow} enabled

---
 src/net/dial_test.go | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/src/net/dial_test.go b/src/net/dial_test.go
index 42898d669f..3e15ba50fd 100644
--- a/src/net/dial_test.go
+++ b/src/net/dial_test.go
@@ -15,6 +15,7 @@ import (
 	"regexp"
 	"runtime"
 	"strconv"
+	"strings"
 	"sync"
 	"testing"
 	"time"
@@ -31,7 +32,34 @@ func newLocalListener(t *testing.T) Listener {
 	return ln
 }
 
+func sysctl(varname string) (int64, error) {
+	out, err := exec.Command("sysctl", "-n", varname).Output()
+	if err != nil {
+		return 0, err
+	}
+	valstr := string(out)
+	valstr = strings.TrimSpace(valstr)
+	val, err := strconv.ParseInt(valstr, 10, 8)
+	return val, err
+}
+
 func TestDialTimeout(t *testing.T) {
+	if runtime.GOOS == "linux" {
+		enabled_syncookies, err := sysctl("net.ipv4.tcp_syncookies")
+		if err != nil {
+			t.Skipf("sysctl net.ipv4.tcp_syncookies failed: %v", err)
+		}
+		if enabled_syncookies != 0 {
+			t.Skipf("net.ipv4.tcp_syncookies = %v", enabled_syncookies)
+		}
+		enabled_abort_on_overflow, err := sysctl("net.ipv4.tcp_abort_on_overflow")
+		if err != nil {
+			t.Skipf("sysctl net.ipv4.tcp_abort_on_overflow failed: %v", err)
+		}
+		if enabled_abort_on_overflow != 0 {
+			t.Skipf("net.ipv4.tcp_abort_on_overflow = %v", enabled_abort_on_overflow)
+		}
+	}
 	origBacklog := listenerBacklog
 	defer func() {
 		listenerBacklog = origBacklog
-- 
2.12.2

EOF
}

do_patch() {
	local ver="${PKG_VERSION%.*}"

	cd "$PKG_SOURCE_DIR"

	if [ "$ver" = "1.4" ]; then
		do_patch_common
		do_patch_go14
	fi
}
