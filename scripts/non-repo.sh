#!/usr/bin/env bash

set -oue pipefail

#nix
curl -L https://hydra.nixos.org/job/nixpkgs/trunk/lixStatic.x86_64-linux/latest/download-by-type/file/binary-dist > /usr/bin/nix
chmod +x /usr/bin/nix
chmod +x /usr/bin/nx

pip install --prefix=/usr pynvim

#flathub remote
mkdir -p /etc/flatpak/remotes.d
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /etc/flatpak/remotes.d

#android-udev
chmod a+r /etc/udev/rules.d/51-android.rules

#binaries for services
chmod +x /usr/libexec/assembler
chmod +x /usr/libexec/dotfile-manager
chmod +x /usr/libexec/flatpak-manager
chmod +x /usr/libexec/pod-up
chmod +x /usr/libexec/prefix-dedupe
chmod +x /usr/libexec/sys-up
chmod +x /usr/libexec/user-up
chmod +x /usr/bin/tsd

#services
systemctl enable dconf-update.service
systemctl enable flatpak-manager.service
systemctl enable prefix-dedupe.timer
systemctl enable sys-up.timer

systemctl --global enable assemble.service
systemctl --global enable dotfile-manager.service
systemctl --global enable user-up.timer

#hide applications
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvim.desktop

#modify os-release
sed -i "s/^\(VERSION=\"[0-9]*\)\(.*\)/\1.`date "+%Y-%m-%d"`\2/" /usr/lib/os-release

#fonts
mkdir -p /usr/share/fonts/Lilex
curl -OL https://github.com/mishamyrt/Lilex/releases/latest/download/Lilex.zip
unzip -j Lilex.zip ttf/* -d /usr/share/fonts/Lilex/
rm -rf Lilex.zip

fc-cache -f -v

glib-compile-schemas /usr/share/glib-2.0/schemas
