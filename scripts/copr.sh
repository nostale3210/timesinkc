#!/usr/bin/env bash
set -oue pipefail

dnf copr enable -y che/nerd-fonts
dnf copr enable -y bieszczaders/kernel-cachyos-lto
dnf copr enable -y bieszczaders/kernel-cachyos-addons
dnf copr enable -y chenxiaolong/sbctl
dnf config-manager -y addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

sed -i "s/\[repository\]/\[librewolf\]/" /etc/yum.repos.d/librewolf.repo

dnf install -y nerd-fonts librewolf sbctl

dnf install -y libcap-ng libcap-ng-devel procps-ng procps-ng-devel

dnf install -y kernel-cachyos-lto kernel-cachyos-lto-devel-matched scx-scheds scx-tools

dnf copr disable -y che/nerd-fonts
dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf copr disable -y bieszczaders/kernel-cachyos-addons
dnf copr disable -y chenxiaolong/sbctl
dnf config-manager -y setopt librewolf.enabled=0
