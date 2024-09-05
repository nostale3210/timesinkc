#!/usr/bin/env bash

set -oue pipefail

dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

dnf5 install -y --best mesa-dri-drivers
MESAVER="$(rpm -q mesa-dri-drivers --queryformat '%{VERSION}-%{RELEASE}')"
dnf5 install -y mesa-filesystem-"${MESAVER}" \
    mesa-libEGL-"${MESAVER}" mesa-libGL-"${MESAVER}" \
    mesa-libgbm-"${MESAVER}" mesa-libglapi-"${MESAVER}" \
    mesa-vulkan-drivers-"${MESAVER}"

dnf5 install -y intel-media-driver libva-intel-driver
dnf5 config-manager -y setopt updates-testing.enabled=1 &&
    dnf5 config-manager -y setopt rpmfusion-free-updates-testing.enabled=1 &&
    dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld-"${MESAVER}" &&
    dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld-"${MESAVER}" &&
    dnf5 config-manager -y setopt updates-testing.enabled=0 &&
    dnf5 config-manager -y setopt rpmfusion-free-updates-testing.enabled=0
dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
dnf5 install -y steam-devices gamescope

dnf5 config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0
