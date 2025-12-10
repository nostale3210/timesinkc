#!/usr/bin/env bash

set -oue pipefail

dnf config-manager -y setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1 \
    rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1

dnf install -y mesa-dri-drivers mesa-filesystem mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers \
    mesa-libEGL mesa-libgbm mesa-libGL mesa-libOpenCL mesa-libTeflon --allowerasing --from-repo=terra-mesa
dnf swap -y ffmpeg-free ffmpeg --allowerasing --from-repo=terra-multimedia

dnf install -y intel-media-driver libva-intel-driver

dnf install -y steam-devices gamescope

dnf config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0
