#!/usr/bin/env bash
set -ouex pipefail

mkdir -p /var/lib/alternatives

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

dnf copr enable -y bieszczaders/kernel-cachyos-lto
# dnf config-manager -y addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia-580.repo
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf config-manager -y addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo

dnf install -y akmods --from-repo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto

dnf install -y xorg-x11-drv-nvidia-580xx akmod-nvidia-580xx xorg-x11-drv-nvidia-580xx-cuda libva-nvidia-driver

dnf install -y nvidia-container-toolkit nvidia-container-toolkit-base \
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
    (cat /var/cache/akmods/nvidia/"${NVIDIA_AKMOD_VERSION::-5}"-for-"${KVER_LONG}".failed.log &&
    exit 1)

dnf copr disable -y bieszczaders/kernel-cachyos-lto
dnf config-manager -y setopt rpmfusion-free.enabled=0 \
    rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 \
    rpmfusion-nonfree-updates.enabled=0 \
    nvidia-container-toolkit.enabled=0
