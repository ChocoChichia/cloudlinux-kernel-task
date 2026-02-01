#!/bin/bash
set -e

SPEC=~/rpmbuild/SPECS/kernel.spec
SRC=~/rpmbuild/SOURCES

cd "$SRC"

curl -sL \
  "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=80e648042e512d5a767da251d44132553fe04ae0" \
  -o upstream-fix-80e648.patch


cat > upstream-fix-f90fff.patch << 'EOF'
--- a/kernel/time/posix-cpu-timers.c	2023-01-09 18:17:34.000000000 +0400
+++ b/kernel/time/posix-cpu-timers.c	2026-02-01 23:09:41.630109704 +0400
@@ -1121,6 +1121,15 @@
 	LIST_HEAD(firing);
 
 	lockdep_assert_irqs_disabled();
+	
++	/*
++	 * Ensure that release_task(tsk) can't happen while
++	 * handle_posix_cpu_timers() is running. Otherwise, a concurrent
++	 * posix_cpu_timer_del() may fail to lock_task_sighand(tsk) and
++	 * miss timer->it.cpu.firing != 0.
++	 */
++	if (tsk->exit_state)
++		return;
 
 	/*
 	 * The fast path checks that there are no expired thread or thread

EOF

PATCHES=(
  upstream-fix-80e648.patch
  upstream-fix-f90fff.patch
)

PATCH_BASE=999901


cd ~/rpmbuild/SPECS

for i in "${!PATCHES[@]}"; do
  num=$((PATCH_BASE + i))
  if grep -q "^# empty final patch" "$SPEC"; then
    sed -i "/^# empty final patch/i Patch${num}: ${PATCHES[$i]}" "$SPEC"
  else
    sed -i "/^%description/i Patch${num}: ${PATCHES[$i]}" "$SPEC"
  fi
done

sed -i "/^ApplyOptionalPatch linux-kernel-test.patch/i ApplyOptionalPatch upstream-fix-80e648.patch" "$SPEC"
sed -i "/^ApplyOptionalPatch linux-kernel-test.patch/i ApplyOptionalPatch upstream-fix-f90fff.patch" "$SPEC"

rpmbuild -bs kernel.spec

echo "Patched SRPM produced:"
ls -la ~/rpmbuild/SRPMS/