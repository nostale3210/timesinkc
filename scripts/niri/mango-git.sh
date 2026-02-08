#!/usr/bin/env bash
set -oue pipefail

dnf install -y xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    gcc gcc-c++ cmake glibc wayland-devel wayland-protocols-devel \
    libinput-devel libdrm-devel libxkbcommon-devel \
    pixman-devel meson ninja-build libdisplay-info-devel \
    libliftoff-devel hwdata-devel libseat-devel \
    pcre2-devel xorg-x11-server-Xwayland xorg-x11-server-Xwayland-devel \
    libxcb-devel xcb-util-wm-devel mesa-libgbm-devel glslang-devel \
    vulkan-loader-devel libwayland-egl libglvnd-egl libglvnd-gles \
    lcms2-devel xcb-util-renderutil-devel xcb-util-errors-devel \
    cairo-devel libglvnd-devel

git clone https://gitlab.freedesktop.org/wlroots/wlroots.git
pushd wlroots
meson setup build/
ninja -C build/ install
mv /usr/local/lib64/libwlroots-* /usr/lib64/
popd
rm -rf wlroots

git clone https://github.com/DreamMaoMao/mangowc.git
pushd mangowc
git switch wl-only
meson setup build -Dprefix=/usr
ninja -C build install
popd
rm -rf mangowc
