#!/usr/bin/env bash

set -ouex pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

dnf copr enable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia-580.repo
dnf config-manager -y addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo

dnf install -y akmods --from-repo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto

dnf install -y nvidia-driver akmod-nvidia libva-nvidia-driver nvidia-driver-cuda

dnf install -y nvidia-container-toolkit nvidia-container-toolkit-base \
    libnvidia-container-tools libnvidia-container1

# KVER="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}')"
KVER_LONG="$(rpm -q kernel-cachyos-lto --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')"

akmods --force \
    --kernels "${KVER_LONG}" \
    --kmod "nvidia"

# modinfo /usr/lib/modules/"${KVER_LONG}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko > /dev/null || \
# (cat /var/cache/akmods/nvidia/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER_LONG}".failed.log && exit 1)

modinfo -l /usr/lib/modules/"${KVER_LONG}"/extra/nvidia/nvidia.ko.xz

rm -rf /etc/pki/akmods/private/private_key.priv

dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y setopt fedora-nvidia-580.enabled=0 nvidia-container-toolkit.enabled=0

dnf autoremove -y
