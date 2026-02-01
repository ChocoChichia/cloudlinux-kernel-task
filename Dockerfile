FROM quay.io/centos/centos:stream8

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN dnf -y update && dnf clean all

RUN dnf install -y \
    dnf-plugins-core \
    rpm-build \
    rpmdevtools \
    curl \
    git \
    && dnf clean all

RUN dnf config-manager --set-enabled powertools

RUN rpmdev-setuptree

WORKDIR /root

RUN curl -LO \
    https://vault.centos.org/8-stream/BaseOS/Source/SPackages/kernel-4.18.0-448.el8.src.rpm

RUN rpm -ivh kernel-4.18.0-448.el8.src.rpm

RUN dnf builddep -y rpmbuild/SPECS/kernel.spec

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
