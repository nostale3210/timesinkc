#!/usr/bin/env bash

set -oue pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv
install -Dm644 /usr/etc/pki/akmods/certs/public_key.der /etc/pki/akmods/certs/public_key.der

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


dnf install -y akmod-nvidia kernel
dnf install -y xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power nvidia-vaapi-driver libva-utils vdpauinfo

KVER="$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -n 1)"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')"

akmods --force \
    --kernels "${KVER}" \
    --kmod nvidia

modinfo /usr/lib/modules/${KVER}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
(cat /var/cache/akmods/nvidia/${NVIDIA_AKMOD_VERSION}-for-${KVER}.failed.log && exit 1)

dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf groupupdate -y multimedia --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
dnf groupupdate -y sound-and-video
dnf install -y steam-devices

systemctl enable nvidia-{suspend,resume,hibernate}

rm -rf /etc/pki/akmods/private/private_key.priv
