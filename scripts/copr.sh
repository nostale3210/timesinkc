#!/usr/bin/env bash

set -oue pipefail

dnf install -y dnf-plugins-core

dnf copr enable -y che/nerd-fonts
dnf copr enable -y kylegospo/system76-scheduler
dnf config-manager -y --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo

dnf install -y nerd-fonts system76-scheduler \
    gnome-shell-extension-system76-scheduler tailscale

systemctl enable com.system76.Scheduler.service
systemctl enable tailscaled.service

dnf copr disable -y che/nerd-fonts
dnf copr disable -y kylegospo/system76-scheduler
dnf config-manager -y --disable tailscale-stable
