#!/usr/bin/env bash
set -oue pipefail

BUILD_TYPE="$1"
FEDORA_VERSION="$2"

if [[ "$BUILD_TYPE" == "git" ]]; then
    GIT=1
    dnf copr -y enable duxlabs/dms-git
    dnf copr -y enable yalter/niri-git
    dnf config-manager -y setopt "*niri-git*".priority=1
    dnf install -y gcc gcc-c++ cmake glibc meson ninja-build \
        wayland-devel wayland-protocols-devel libxkbcommon-devel \
        libinput-devel libseat-devel libdisplay-info-devel \
        libdrm-devel libliftoff-devel libxcb-devel \
        wlroots-devel systemd-devel mesa-libgbm-devel \
        pixman-devel hwdata-devel pcre2-devel xorg-x11-server-Xwayland-devel \
        libxcb-devel scenefx-devel fontconfig-devel cjson-devel pipewire-devel \
        pango-devel cairo-gobject-devel json-devel tomlplusplus-devel \
        jemalloc-devel gtk4-devel sdbus-cpp-devel libei-devel libeis-devel
else
    dnf copr -y enable duxlabs/dms
fi

if [[ "$FEDORA_VERSION" -ge "45" ]]; then
    KEYRING=("oo7-daemon" "oo7-portal" "oo7-cli" "pam_oo7")
else
    KEYRING=("gnome-keyring" "libgnome-keyring" "gnome-keyring-pam")
fi

dnf install -y NetworkManager iputils acl fwupd nm-connection-editor
dnf install -y selinux-policy-targeted \
    policycoreutils-python-utils setroubleshoot-server
dnf install -y "${KEYRING[@]}" qt6ct

dnf install -y niri xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-wlr

dnf install -y --from-repo coprdep:copr.fedorainfracloud.org:duxlabs:dux-repo \
    dux-search dux-gop dux-greeter"${GIT:+-git}" matugen quickshell-git dux-files"${GIT:+-git}" \
    dux-calendar"${GIT:+-git}"
dnf install -y --setopt=install_weak_deps=True dms
dnf install -y cava wl-clipboard adw-gtk3-theme fuzzel

dnf install -y dbus-tools wiremix xorg-x11-server-Xwayland xwayland-satellite
dnf install -y gnome-disk-utility nautilus \
    webp-pixbuf-loader gvfs gvfs-afc gvfs-client gvfs-fuse gvfs-goa \
    gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb
dnf install -y glycin-thumbnailer papers-thumbnailer gst-thumbnailers papers-nautilus
dnf install -y kitty

dnf install -y wl-mirror tuned-ppd

if [[ "$BUILD_TYPE" == "git" ]]; then
    dnf copr -y disable duxlabs/dms-git
    dnf copr -y disable yalter/niri-git
else
    dnf copr -y disable duxlabs/dms
fi

# Replace deprecated systemd --user import environment
sed -i "s/\(systemctl --user import-environment\)$/\# \1/" /usr/bin/niri-session
sed -i "s/\(dbus-update-activation-environment\) \(--all\)$/\1 --systemd \2/" /usr/bin/niri-session

systemctl --global add-wants mango-session.target dms.service
systemctl --global add-wants niri.service dms.service

dnf config-manager -y setopt terra.enabled=0 terra-mesa.enabled=0 terra-multimedia.enabled=0
