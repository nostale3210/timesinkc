#!/usr/bin/env bash
set -oue pipefail

dnf5 config-manager -y setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1 \
    rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1
dnf5 install -y @cosmic-desktop-environment
dnf5 install -y pavucontrol gnome-tweaks steam vulkan-tools seahorse
dnf5 config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0

rm -rf /etc/systemd/system/display-manager.service
systemctl enable cosmic-greeter.service

chmod +x /usr/libexec/fix-greetd
systemctl enable fix-greetd.service
