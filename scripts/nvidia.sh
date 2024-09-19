#!/usr/bin/env bash

set -oue pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv
install -Dm644 /usr/etc/pki/akmods/certs/public_key.der /etc/pki/akmods/certs/public_key.der

dnf5 config-manager -y setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1 \
    rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1

dnf5 install -y dnf

KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}')"
KERNEL_RELEASE="$(rpm -q kernel --queryformat '%{RELEASE}')"
KERNEL_ARCH="$(rpm -q kernel --queryformat '%{ARCH}')"
KVER_SHORT="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}')"
KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
KURL="https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_VERSION}/${KERNEL_RELEASE}/${KERNEL_ARCH}"

dnf install -y akmod-nvidia kernel-devel-"${KVER_SHORT}" \
    kernel-devel-matched-"${KVER_SHORT}" ||
    dnf install -y akmod-nvidia \
    "${KURL}"/kernel-devel-"${KVER}".rpm \
    "${KURL}"/kernel-devel-matched-"${KVER}".rpm
dnf install -y xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power nvidia-vaapi-driver libva-utils vdpauinfo

KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')"

akmods --force \
    --kernels "${KVER}" \
    --kmod "nvidia"

modinfo /usr/lib/modules/"${KVER}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
(cat /var/cache/akmods/nvidia/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER}".failed.log && exit 1)

systemctl enable nvidia-{suspend,resume,hibernate}

rm -rf /etc/pki/akmods/private/private_key.priv

dnf5 remove -y dnf

dnf5 config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0

echo 'kargs = ["rd.drivers.blacklist=nouveau", "modprobe.blacklist=nouveau", "nvidia-drm.modeset=1", "nvidia-drm.fbdev=1"]' > /usr/lib/bootc/kargs.d/12-nvidia.toml
