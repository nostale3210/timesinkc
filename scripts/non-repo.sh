#!/usr/bin/env bash

set -oue pipefail

#nix
curl -L https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > /usr/bin/nix
chmod +x /usr/bin/nix
chmod +x /usr/bin/nx
chmod +x /usr/bin/ne
chmod +x /usr/bin/nenv
chmod +x /usr/bin/nix-index

#zellij
curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz > zellij.tar.gz
tar -xf zellij.tar.gz --directory /usr/bin/
chmod +x /usr/bin/zellij

#proot
curl -L https://proot.gitlab.io/proot/bin/proot > /usr/bin/proot
chmod +x /usr/bin/proot

#tectonic
curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh
chmod +x tectonic && mv tectonic /usr/bin/tectonic

#flathub remote
mkdir -p /usr/etc/flatpak/remotes.d
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d

#android-udev
chmod a+r /usr/etc/udev/rules.d/51-android.rules

#binaries for services
chmod +x /usr/libexec/flatpak-manager

#services
systemctl enable dconf-update.service
systemctl enable flatpak-manager.service
systemctl disable bootc-fetch-apply-updates.timer

#fonts
mkdir -p /usr/share/fonts/Lilex
curl -OL https://github.com/mishamyrt/Lilex/releases/latest/download/Lilex.zip
unzip -j Lilex.zip ttf/* -d /usr/share/fonts/Lilex/
rm -rf Lilex.zip

fc-cache -f -v