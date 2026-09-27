#!/usr/bin/env bash
set -ouex pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

dnf config-manager -y setopt terra.enabled=1
dnf copr enable -y bieszczaders/kernel-cachyos-lto
dnf install -y terra-release-nvidia

dnf install -y akmods --from-repo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto

dnf install -y nvidia-driver-580xx nvidia-driver-580xx-cuda nvidia-driver-580xx-cuda-libs \
    libva-nvidia-driver

dnf install -y nvidia-container-toolkit \
    libnvidia-container-tools libnvidia-container1 || :

# KVER="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}')"
KVER_LONG="$(rpm -q kernel-cachyos-lto --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia-580xx" --queryformat '%{VERSION}-%{RELEASE}')"

akmods --force \
    --kernels "${KVER_LONG}" \
    --kmod "nvidia-580xx"

rm -rf /etc/pki/akmods/private/private_key.priv

# modinfo /usr/lib/modules/"${KVER_LONG}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko > /dev/null || \
# (cat /var/cache/akmods/nvidia/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER_LONG}".failed.log && exit 1)

modinfo -l /usr/lib/modules/"${KVER_LONG}"/extra/nvidia-580xx/nvidia.ko.xz ||
    (cat /var/cache/akmods/nvidia-580xx/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER_LONG}".failed.log &&
    exit 1)

dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y setopt terra.enabled=0 terra-nvidia.enabled=0
