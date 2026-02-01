#!/bin/bash
set -e

SPEC=~/rpmbuild/SPECS/kernel.spec
SRC=~/rpmbuild/SOURCES

PATCHES=(
  upstream-fix-80e648.patch
  upstream-fix-f90fff.patch
)

PATCH_BASE=999901

cd  ~/rpmbuild/SOURCES

curl "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=80e648042e512d5a767da251d44132553fe04ae0" -o upstream-fix-80e648.patch
curl "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=f90fff1e152dedf52b932240ebbd670d83330eca" -o upstream-fix-f90fff.patch

cd ~/rpmbuild/SPECS

for i in "${!PATCHES[@]}"; do
  num=$((PATCH_BASE + i))
  sed -i "/^# empty final patch/i Patch${num}: ${PATCHES[$i]}" "$SPEC"
done


for p in "${PATCHES[@]}"; do
  sed -i "/^ApplyOptionalPatch linux-kernel-test.patch/i ApplyOptionalPatch $p" "$SPEC"
done

rpmbuild -bs kernel.spec 


