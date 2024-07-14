#!/usr/bin/env bash

set -oue pipefail

dnf5 copr enable -y che/nerd-fonts
dnf5 copr enable -y kylegospo/system76-scheduler
dnf5 config-manager -y --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo

dnf5 install -y nerd-fonts system76-scheduler \
    gnome-shell-extension-system76-scheduler tailscale

systemctl enable com.system76.Scheduler.service
systemctl enable tailscaled.service

dnf5 copr disable -y che/nerd-fonts
dnf5 copr disable -y kylegospo/system76-scheduler
dnf5 config-manager -y --disable tailscale-stable
