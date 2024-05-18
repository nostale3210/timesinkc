#!/usr/bin/env bash

set -oue pipefail

rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

rpm-ostree override remove \
    libavfilter-free \
    libavformat-free \
    libavcodec-free \
    libavutil-free \
    libpostproc-free \
    libswresample-free \
    libswscale-free \
    --install ffmpeg
rpm-ostree install \
    gstreamer1-{plugin-libav,plugins-bad-free-extras,plugins-ugly,vaapi} \
    steam-devices

rpm-ostree install steam-devices
