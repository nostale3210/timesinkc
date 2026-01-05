#!/usr/bin/env bash
set -oue pipefail

dnf config-manager -y setopt terra.enabled=1 terra-mesa.enabled=1 terra-multimedia.enabled=1

dnf install -y @standard
dnf install -y @printing
dnf install -y @networkmanager-submodules
dnf install -y @multimedia
dnf install -y @input-methods
dnf install -y @hardware-support
dnf install -y @guest-desktop-agents
dnf install -y @fonts
dnf install -y @desktop-accessibility
dnf install -y @core
dnf install -y @base-graphical
