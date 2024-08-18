ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM "quay.io/${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}" AS shared

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /

RUN KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
    dracut --no-hostonly --kver "$KVER" --reproducible -v --add "ostree tpm2-tss systemd-pcrphase" -f "/lib/modules/$KVER/initramfs.img" && \
    chmod 0600 "/lib/modules/$KVER/initramfs.img" && \
    ostree container commit

RUN --mount=type=bind,src=/scripts,target=/scripts \
    mkdir -p /var/lib/alternatives &&\
    readarray basic_pkgs < /scripts/basics.pkgs && \
    rpm-ostree install dnf5 dnf5-plugins bootc bootupd && \
    dnf5 install -y "${basic_pkgs[@]}" && \
    ostree container commit

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/copr.sh && \
    ostree container commit

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/drivers.sh && \
    ostree container commit

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/non-repo.sh "bootc" && \
    ostree container commit


FROM shared AS silverblue-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/gnome.sh && \
    ostree container commit


FROM silverblue-main AS silverblue-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh && \
    ostree container commit


FROM shared AS cosmic-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/cosmic.sh && \
    ostree container commit

RUN --mount=type=bind,src=/scripts,target=/scripts \
    readarray support_pkgs < /scripts/support.pkgs && \
    dnf5 install -y "${support_pkgs[@]}" && \
    ostree container commit


FROM cosmic-main AS cosmic-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh && \
    ostree container commit


FROM "quay.io/${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}" AS container-only-main

COPY files/ /

RUN --mount=type=bind,src=/scripts,target=/scripts \
    mkdir -p /var/lib/alternatives &&\
    readarray basic_pkgs < /scripts/basics.pkgs && \
    dnf install -y dnf5 dnf5-plugins && \
    dnf5 install -y "${basic_pkgs[@]}"

RUN dnf5 install -y kernel kernel-modules kernel-modules-extra systemd dracut git-core lvm2 systemd-container shim-x64 systemd-boot-unsigned \
    efibootmgr NetworkManager NetworkManager-bluetooth NetworkManager-config-connectivity-fedora NetworkManager-wifi NetworkManager-wwan \
    acl alsa-ucm alsa-utils attr audit bash bash-color-prompt bash-completion bc bind-utils brltty btrfs-progs bzip2 chrony cifs-utils \
    colord compsize coreutils cpio cryptsetup curl default-editor dhcp-client dnsmasq e2fsprogs ethtool exfatprogs file filesystem \
    firewalld fpaste fwupd gamemode glibc glibc-all-langpacks hostname iproute iptables-nft iptstate iputils kbd less linux-firmware \
    logrotate lrzsz lsof mdadm mesa-dri-drivers mesa-vulkan-drivers mpage mtr nfs-utils nss-altfiles nss-mdns ntfsprogs opensc pam_afs_session \
    paps passwdqc pciutils pinfo pipewire-alsa pipewire-gstreamer pipewire-pulseaudio pipewire-utils plocate plymouth plymouth-system-theme \
    policycoreutils procps-ng psmisc quota realmd rootfiles rpm rsync selinux-policy-targeted setup shadow-utils sos sssd-common sudo systemd-oomd-defaults \
    systemd-resolved systemd-udev tar time tree unzip uresourced usbutils util-linux wget2-wget which whois wireplumber words wpa_supplicant zip \
    zram-generator-defaults mcelog microcode_ctl virtualbox-guest-additions open-vm-tools-desktop \
    tpm2-tools tpm2-tss

RUN dnf install -y --allowerasing fedora-release xorg-x11-server-Xwayland xdg-desktop-portal xdg-desktop-portal-gtk \
    polkit-gnome fedora-release-common fedora-release-identity-workstation

RUN dnf install -y podman distrobox langpacks-en add-determinism fuse-overlayfs crun

RUN KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
    dracut --no-hostonly --kver "$KVER" --reproducible -v --add "tpm2-tss systemd-pcrphase" -f "/lib/modules/$KVER/initramfs.img" && \
    chmod 0600 "/lib/modules/$KVER/initramfs.img"

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/copr.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/drivers.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/non-repo.sh container

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/cosmic.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    readarray support_pkgs < /scripts/support.pkgs && \
    dnf5 install -y --allowerasing "${support_pkgs[@]}"

RUN chmod 4755 /usr/bin/newgidmap && \
    chmod 4755 /usr/bin/newuidmap

FROM container-only-main AS container-only-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh
