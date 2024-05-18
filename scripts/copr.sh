#!/usr/bin/env bash

set -oue pipefail

curl -Lo /etc/yum.repos.d/_copr_peterwu-rendezvous.repo https://copr.fedorainfracloud.org/coprs/peterwu/rendezvous/repo/fedora-$(rpm -E %fedora)/peterwu-rendezvous-fedora-$(rpm -E %fedora).repo
curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts.repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-$(rpm -E %fedora)/che-nerd-fonts-fedora-$(rpm -E %fedora).repo
curl -Lo /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo
curl -Lo /etc/yum.repos.d/tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo

rpm-ostree install bibata-cursor-themes nerd-fonts system76-scheduler \
    gnome-shell-extension-system76-scheduler tailscale

systemctl enable com.system76.Scheduler.service
systemctl enable tailscaled.service

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_peterwu-rendezvous.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_che-nerd-fonts.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
