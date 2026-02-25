#!/usr/bin/env bash
set -oue pipefail

dnf config-manager -y setopt terra.enabled=1 terra-mesa.enabled=1 terra-multimedia.enabled=1

dnf install -y @standard
dnf install -y @printing
dnf install -y @networkmanager-submodules
dnf install -y @multimedia
dnf install -y fcitx5 fcitx5-autostart fcitx5-configtool fcitx5-gtk \
    fcitx5-chinese-addons fcitx5-hangul fcitx5-mozc
dnf install -y @hardware-support
dnf install -y @guest-desktop-agents
dnf install -y @fonts
dnf install -y @desktop-accessibility
dnf install -y @core
dnf install -y @base-graphical
