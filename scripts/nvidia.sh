#!/usr/bin/env bash

set -ouex pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

dnf copr enable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo

dnf install -y akmods --from-repo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto

dnf install -y nvidia-driver akmod-nvidia libva-nvidia-driver nvidia-driver-cuda

# KVER="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}')"
KVER_LONG="$(rpm -q kernel-cachyos-lto --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')"

sed -i -e 's/kernel-open$/kernel/g' /etc/nvidia/kernel.conf

akmods --force \
    --kernels "${KVER_LONG}" \
    --kmod "nvidia"

# modinfo /usr/lib/modules/"${KVER_LONG}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko > /dev/null || \
# (cat /var/cache/akmods/nvidia/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER_LONG}".failed.log && exit 1)

modinfo /usr/lib/modules/"${KVER_LONG}"/extra/nvidia/nvidia.ko.xz

rm -rf /etc/pki/akmods/private/private_key.priv

dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y setopt fedora-nvidia.enabled=0

dnf autoremove -y
