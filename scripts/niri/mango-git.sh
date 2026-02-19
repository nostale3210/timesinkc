#!/usr/bin/env bash
set -oue pipefail

dnf install -y xdg-desktop-portal-wlr xdg-desktop-portal-gtk wlroots-devel scenefx-devel
dnf install -y gcc gcc-c++ cmake glibc wayland-devel wayland-protocols-devel
dnf install -y libinput-devel libdrm-devel libxkbcommon-devel
dnf install -y pixman-devel meson ninja-build libdisplay-info-devel
dnf install -y libliftoff-devel hwdata-devel libseat-devel
dnf install -y pcre2-devel xorg-x11-server-Xwayland xorg-x11-server-Xwayland-devel
dnf install -y libxcb-devel xcb-util-wm-devel

git clone https://github.com/DreamMaoMao/mangowc.git
pushd mangowc
meson build -Dprefix=/usr
ninja -C build install
popd
rm -rf mangowc
