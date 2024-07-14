#!/usr/bin/env bash

set -oue pipefail

dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 install -y intel-media-driver libva-intel-driver
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
dnf5 groupupdate -y multimedia --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
dnf5 groupupdate -y sound-and-video
dnf5 install -y steam-devices

dnf5 config-manager -y --disable rpmfusion-free rpmfusion-free-updates \
    rpmfusion-nonfree rpmfusion-nonfree-updates
