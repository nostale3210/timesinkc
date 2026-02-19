#!/usr/bin/env bash
set -oue pipefail

if [[ "$1" == "git" ]]; then
    dnf copr -y enable avengemedia/dms-git
    dnf copr -y enable yalter/niri-git
    dnf config-manager -y setopt "*niri-git*".priority=1
else
    dnf copr -y enable avengemedia/dms
    dnf install -y mangowc xdg-desktop-portal-wlr xdg-desktop-portal-gtk
fi

dnf install -y NetworkManager iputils acl fwupd nm-connection-editor
dnf install -y selinux-policy-targeted \
    policycoreutils-python-utils setroubleshoot-server
dnf install -y gnome-keyring libgnome-keyring gnome-keyring-pam qt6ct

dnf install -y niri xdg-desktop-portal-gnome xdg-desktop-portal-gtk

dnf install -y --from-repo coprdep:copr.fedorainfracloud.org:avengemedia:danklinux \
    danksearch dgop dms-greeter matugen quickshell-git
dnf install -y --setopt=install_weak_deps=True dms
dnf install -y cava wl-clipboard adw-gtk3-theme

dnf install -y dbus-tools wiremix xorg-x11-server-Xwayland xwayland-satellite
dnf install -y gnome-disk-utility nautilus \
    webp-pixbuf-loader gvfs gvfs-afc gvfs-afp gvfs-archive gvfs-client gvfs-fuse gvfs-goa \
    gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb
dnf install -y glycin-thumbnailer papers-thumbnailer gst-thumbnailers papers-nautilus
dnf install -y kitty

dnf install -y wl-mirror tuned-ppd

if [[ "$1" == "git" ]]; then
    dnf copr -y disable avengemedia/dms-git
    dnf copr -y disable yalter/niri-git
else
    dnf copr -y disable avengemedia/dms
fi

# Replace deprecated systemd --user import environment
sed -i "s/\(systemctl --user import-environment\)$/\# \1/" /usr/bin/niri-session
sed -i "s/\(dbus-update-activation-environment\) \(--all\)$/\1 --systemd \2/" /usr/bin/niri-session

# Hide im-chooser
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/im-chooser.desktop

dnf config-manager -y setopt terra.enabled=0 terra-mesa.enabled=0 terra-multimedia.enabled=0
