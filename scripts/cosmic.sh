#!/usr/bin/env bash
set -oue pipefail

dnf config-manager -y setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1 \
    rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1
dnf install -y @cosmic-desktop-environment --skip-broken \
    --exclude=thunderbird,gnome-calculator,nheko,okular,rhythmbox,abrt,setroubleshoot,libreoffice-core
dnf install -y pavucontrol gnome-tweaks steam vulkan-tools seahorse
dnf config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0

rm -rf /etc/systemd/system/display-manager.service
systemctl enable cosmic-greeter.service

chmod +x /usr/libexec/fix-greetd
systemctl enable fix-greetd.service

dnf autoremove -y
