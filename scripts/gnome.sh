#!/usr/bin/env bash
set -oue pipefail

dnf install -y kitty \
    papirus-icon-theme gnome-tweaks

dnf install -y @workstation-product-environment --skip-broken \
    --exclude=thunderbird,gnome-calculator,nheko,okular,rhythmbox,abrt,setroubleshoot,libreoffice-core \
    --exclude=evince,yelp,gnome-boxes,gnome-calendar,gnome-characters,gnome-clocks,gnome-connections \
    --exclude=gnome-contacts,gnome-font-viewer,gnome-maps,gnome-weather,gnome-logs,gnome-remote-desktop \
    --exclude=PackageKit,totem,snapshot,gnome-text-editor,loupe,mediawriter,simple-scan,toolbox \
    --exclude=baobab,firefox,toolbox
dnf install -y fedora-release-silverblue fuse-libs evince-previewer evince-thumbnailer tuned tuned-ppd

glib-compile-schemas /usr/share/glib-2.0/schemas

dnf autoremove -y
