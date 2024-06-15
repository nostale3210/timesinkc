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
rm -rf zellij.tar.gz

#proot
curl -L https://proot.gitlab.io/proot/bin/proot > /usr/bin/proot
chmod +x /usr/bin/proot

#tectonic
curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh
chmod +x tectonic && mv tectonic /usr/bin/tectonic

pip install --prefix=/usr nautilus-open-any-terminal
pip install --prefix=/usr pynvim

#flathub remote
mkdir -p /usr/etc/flatpak/remotes.d
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d

#android-udev
chmod a+r /usr/etc/udev/rules.d/51-android.rules

#binaries for services
chmod +x /usr/libexec/assembler
chmod +x /usr/libexec/dotfile-manager
chmod +x /usr/libexec/flatpak-manager
chmod +x /usr/libexec/pod-up
chmod +x /usr/libexec/sys-up
chmod +x /usr/libexec/user-up

#services
systemctl enable dconf-update.service
systemctl enable flatpak-manager.service
systemctl enable sys-up.timer

systemctl disable bootc-fetch-apply-updates.timer
systemctl mask bootc-fetch-apply-updates.timer

systemctl --global enable assembler.service
systemctl --global enable dotfile-manager.service
systemctl --global enable user-up.timer

rm -rf /usr/lib/systemd/system/systemd-remount-fs.service

#hide applications
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvim.desktop

#themes
wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 |
    tar xfj - -C /usr/share/icons

#fonts
mkdir -p /usr/share/fonts/Lilex
curl -OL https://github.com/mishamyrt/Lilex/releases/latest/download/Lilex.zip
unzip -j Lilex.zip ttf/* -d /usr/share/fonts/Lilex/
rm -rf Lilex.zip

fc-cache -f -v

glib-compile-schemas /usr/share/glib-2.0/schemas
