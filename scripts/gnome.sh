#!/usr/bin/env bash
set -oue pipefail

dnf copr enable -y kylegospo/system76-scheduler
dnf install -y gnome-shell-extension-system76-scheduler kitty nautilus-python\
    papirus-icon-theme gnome-tweaks
dnf copr disable -y kylegospo/system76-scheduler

dnf install -y @workstation-product-environment --skip-broken \
    --exclude=thunderbird,gnome-calculator,nheko,okular,rhythmbox,abrt,setroubleshoot,libreoffice-core \
    --exclude=evince,yelp,gnome-boxes,gnome-calendar,gnome-characters,gnome-clocks,gnome-connections \
    --exclude=gnome-contacts,gnome-font-viewer,gnome-maps,gnome-weather,gnome-logs,gnome-remote-desktop \
    --exclude=PackageKit,sudshi,totem,snapshot,gnome-text-editor,loupe,mediawriter,simple-scan,toolbox \
    --exclude=baobab,firefox
dnf install -y fedora-release-silverblue fuse-libs evince-previewer evince-thumbnailer tuned tuned-ppd

dnf remove -y gnome-terminal-nautilus

pip install --prefix=/usr nautilus-open-any-terminal

# sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop

wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 |
    tar xfj - -C /usr/share/icons

glib-compile-schemas /usr/share/glib-2.0/schemas

dnf autoremove -y
