#!/bin/bash
set -e

cd /root/rpmbuild/SPECS
rpmbuild -bb kernel.spec

echo "Result RPMs : "
ls /root/rpmbuild/RPMS/
