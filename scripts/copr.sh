#!/usr/bin/env bash
set -oue pipefail

dnf copr enable -y che/nerd-fonts
dnf copr enable -y kylegospo/system76-scheduler
dnf config-manager -y addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf config-manager -y addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

dnf install -y nerd-fonts system76-scheduler \
    tailscale librewolf

systemctl enable com.system76.Scheduler.service
systemctl enable tailscaled.service

dnf copr disable -y che/nerd-fonts
dnf copr disable -y kylegospo/system76-scheduler
dnf config-manager -y setopt tailscale-stable.enabled=0

dnf remove -y toolbox
