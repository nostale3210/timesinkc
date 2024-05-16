#!/usr/bin/env bash

set -oue pipefail

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf install -y intel-media-driver libva-intel-driver
dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf groupupdate -y multimedia --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
dnf groupupdate -y sound-and-video
dnf install -y steam-devices
