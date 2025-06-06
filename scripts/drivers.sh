#!/usr/bin/env bash

set -oue pipefail

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

dnf install -y --best mesa-dri-drivers

dnf install -y intel-media-driver libva-intel-driver
{ dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld &&
    dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld ; } ||
    { dnf config-manager -y setopt updates-testing.enabled=1 &&
        dnf config-manager -y setopt rpmfusion-free-updates-testing.enabled=1 &&
        dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld &&
        dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld &&
        dnf config-manager -y setopt updates-testing.enabled=0 &&
        dnf config-manager -y setopt rpmfusion-free-updates-testing.enabled=0 ; } ||
        :
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf install -y steam-devices gamescope

dnf config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0
