#!/usr/bin/env bash

set -oue pipefail

mkdir -p /var/lib/alternatives

rpm-ostree install intel-media-driver libva-intel-driver

rpm-ostree override remove \
    mesa-va-drivers \
    --install mesa-va-drivers-freeworld \
    --install mesa-vdpau-drivers-freeworld

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree.repo
