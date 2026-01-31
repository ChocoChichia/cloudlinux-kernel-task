FROM quay.io/centos/centos:stream8


RUN dnf -y update && dnf clean all

RUN dnf install -y \
    dnf-plugins-core \
    rpm-build \
    rpmdevtools \
    git \
    curl \
    gcc \
    make \
    && dnf clean all

RUN rpmdev-setuptree

WORKDIR /root

RUN curl -LO \
    https://vault.centos.org/8-stream/BaseOS/Source/SPackages/kernel-4.18.0-448.el8.src.rpm

RUN rpm -ivh kernel-4.18.0-448.el8.src.rpm

RUN rm -rf kernel-*.rpm

RUN dnf builddep -y rpmbuild/SPECS/kernel.spec

WORKDIR /root/rpmbuild/SPECS
RUN rpmbuild -bb kernel.spec

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]