#!/usr/bin/env bash
set -oue pipefail

dnf install -y mesa-dri-drivers mesa-filesystem mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers \
    mesa-libEGL mesa-libgbm mesa-libGL mesa-libOpenCL mesa-libTeflon --allowerasing --from-repo=terra-mesa
dnf swap -y ffmpeg-free ffmpeg --allowerasing --from-repo=terra-multimedia

dnf install -y libva-intel-media-driver libva-utils

dnf install -y steam-device-rules
