#!/usr/bin/env bash

set -oue pipefail

dnf config-manager -y setopt terra.enabled=1
dnf install -y terra-release-mesa terra-release-multimedia
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

dnf swap -y mesa-dri-drivers mesa-dri-drivers --allowerasing --from-repo=terra-mesa
dnf install -y mesa-filesystem mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers \
    mesa-libEGL mesa-libgbm mesa-libGL mesa-libOpenCL mesa-libTeflon --allowerasing --from-repo=terra-mesa
dnf swap -y ffmpeg-free ffmpeg --allowerasing --from-repo=terra-multimedia

dnf install -y intel-media-driver libva-intel-driver

dnf install -y steam-devices gamescope

dnf config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0 \
    terra.enabled=0 terra-mesa.enabled=0 terra-multimedia.enabled=0
