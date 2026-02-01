FROM quay.io/centos/centos:stream8

ARG srpmPath
ARG srpmName

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

COPY "$srpmPath" .

RUN rpm -ivh  "$srpmName"

RUN dnf builddep -y rpmbuild/SPECS/kernel.spec

COPY entrypoint.sh /entrypoint.sh
COPY apply_patches.sh /apply_patches.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /apply_patches.sh

ENTRYPOINT ["/entrypoint.sh"]
