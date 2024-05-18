#!/usr/bin/env bash

set -oue pipefail

install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv
install -Dm644 /usr/etc/pki/akmods/certs/public_key.der /etc/pki/akmods/certs/public_key.der

rpm-ostree install mock akmod-nvidia
rpm-ostree install xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power nvidia-vaapi-driver libva-utils vdpauinfo
akmods --force \
    --kernels "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" \
    --kmod nvidia

systemctl enable nvidia-{suspend,resume,hibernate}

rm -rf /etc/pki/akmods/private/private_key.priv

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree.repo
