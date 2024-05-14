#!/usr/bin/env bash

set -oue pipefail

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf install -y akmod-nvidia
dnf install -y xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power nvidia-vaapi-driver libva-utils vdpauinfo
akmods --force \
    --kernels "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" \
    --kmod nvidia

dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf groupupdate -y multimedia --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
dnf groupupdate -y sound-and-video

systemctl enable nvidia-{suspend,resume,hibernate}
