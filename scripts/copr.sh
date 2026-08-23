#!/usr/bin/env bash
set -oue pipefail

dnf copr enable -y che/nerd-fonts
dnf copr enable -y bieszczaders/kernel-cachyos-lto
dnf copr enable -y bieszczaders/kernel-cachyos-addons
dnf config-manager -y addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

sed -i "s/\[repository\]/\[librewolf\]/" /etc/yum.repos.d/librewolf.repo

dnf install -y librewolf sbctl
dnf install -y nerd-fonts --from-repo=copr:copr.fedorainfracloud.org:che:nerd-fonts

dnf install -y libcap-ng libcap-ng-devel procps-ng procps-ng-devel

dnf install -y kernel-cachyos-lto-7.1.8-cachyos1.lto.fc44 \
    kernel-cachyos-lto-devel-matched-7.1.8-cachyos1.lto.fc44 \
    scx-scheds scx-tools

dnf copr disable -y che/nerd-fonts
dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf copr disable -y bieszczaders/kernel-cachyos-addons
dnf config-manager -y setopt librewolf.enabled=0
