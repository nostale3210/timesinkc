#!/usr/bin/env bash
set -oue pipefail

dnf5 copr enable -y kylegospo/system76-scheduler
dnf5 install -y gnome-shell-extension-system76-scheduler kitty nautilus-python\
    papirus-icon-theme gnome-tweaks
dnf5 copr disable -y kylegospo/system76-scheduler

dnf5 remove -y gnome-terminal-nautilus

pip install --prefix=/usr nautilus-open-any-terminal

sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Tour.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yelp.desktop

wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 |
    tar xfj - -C /usr/share/icons
