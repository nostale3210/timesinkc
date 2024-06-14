#!/usr/bin/env bash

set -oue pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv
install -Dm644 /usr/etc/pki/akmods/certs/public_key.der /etc/pki/akmods/certs/public_key.der

dnf config-manager -y --enable rpmfusion-free rpmfusion-free-updates \
    rpmfusion-nonfree rpmfusion-nonfree-updates

dnf install -y akmod-nvidia
dnf install -y xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power nvidia-vaapi-driver libva-utils vdpauinfo

KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')"

akmods --force \
    --kernels "${KVER}" \
    --kmod nvidia

modinfo /usr/lib/modules/${KVER}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
(cat /var/cache/akmods/nvidia/${NVIDIA_AKMOD_VERSION}-for-${KVER}.failed.log && exit 1)

systemctl enable nvidia-{suspend,resume,hibernate}

rm -rf /etc/pki/akmods/private/private_key.priv

dnf config-manager -y --disable rpmfusion-free rpmfusion-free-updates \
    rpmfusion-nonfree rpmfusion-nonfree-updates
