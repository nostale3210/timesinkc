#!/usr/bin/env bash
set -oue pipefail

dnf copr enable -y che/nerd-fonts
dnf config-manager -y addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf config-manager -y addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

GNUPGHOME="$(mktemp -d)"
export GNUPGHOME

sed -i "s/\[repository\]/\[librewolf\]/" /etc/yum.repos.d/librewolf.repo
gpg --keyserver 'keys.openpgp.org' --recv-keys '662E3CDD6FE329002D0CA5BB40339DD82B12EF16'

dnf install --skip-unavailable librewolf

DNF_LIBREWOLF="$(find /var/cache/libdnf5 -type d -name "librewolf*" | head -n1)"
mkdir "$DNF_LIBREWOLF/pubring"

gpg --export gpg@librewolf.net > "$DNF_LIBREWOLF/pubring/40339DD82B12EF16.pub"

dnf install -y nerd-fonts tailscale librewolf

dnf install -y kernel-core kernel-devel-matched kernel-modules kernel-modules-extra

dnf copr disable -y che/nerd-fonts
dnf config-manager -y setopt tailscale-stable.enabled=0 librewolf.enabled=0
