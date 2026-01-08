#!/usr/bin/env bash
set -oue pipefail

dnf install -y NetworkManager iputils acl fwupd nm-connection-editor
dnf install -y selinux-policy-targeted \
    policycoreutils-python-utils setroubleshoot-server
dnf install -y gnome-keyring libgnome-keyring gnome-keyring-pam qt6ct

dnf install -y niri xdg-desktop-portal-gnome xdg-desktop-portal-gtk
dnf install -y mangowc xdg-desktop-portal-wlr xdg-desktop-portal-gtk
dnf copr -y enable avengemedia/dms
dnf install -y --from-repo coprdep:copr.fedorainfracloud.org:avengemedia:danklinux \
    cliphist danksearch dgop dms-greeter matugen quickshell-git
dnf install -y --setopt=install_weak_deps=True dms
dnf install -y cava wl-clipboard adw-gtk3-theme
dnf copr disable avengemedia/dms
dnf install -y dbus-tools wiremix xorg-x11-server-Xwayland xwayland-satellite
dnf install -y gnome-disk-utility nautilus \
    webp-pixbuf-loader gvfs gvfs-afc gvfs-afp gvfs-archive gvfs-client gvfs-fuse gvfs-goa \
    gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb
dnf install -y glycin-thumbnailer papers-thumbnailer gst-thumbnailers papers-nautilus
dnf install -y helium-browser-bin
dnf install -y kitty

dnf install -y wl-mirror tuned-ppd

glib-compile-schemas /usr/share/glib-2.0/schemas

sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/im-chooser.desktop
dnf config-manager -y setopt terra.enabled=0 terra-mesa.enabled=0 terra-multimedia.enabled=0
