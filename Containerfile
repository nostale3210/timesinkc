ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts/ /tmp/scripts
ADD certs/private_key.priv /etc/pki/akmods/private/private_key.priv

RUN dnf install -y cryptsetup tpm2-tools tpm2-tss

RUN dnf install -y fedora-release fedora-release-ostree-desktop fedora-release-silverblue \
    xorg-x11-server-Xwayland xdg-desktop-portal xdg-desktop-portal-gtk langpacks-en \
    glibc-all-langpacks flatpak wget

RUN readarray gnome_pkgs < /tmp/scripts/gnome.pkgs && \
    dnf install -y ${gnome_pkgs[*]}

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

RUN dnf install -y neovim adw-gtk3-theme gnome-tweaks nautilus-python \
    pinentry-gnome3 evince-thumbnailer evince-previewer totem-video-thumbnailer \
    firefox geoclue2 unzip distrobox

RUN dnf install -y @printing

RUN dnf install -y plymouth plymouth-system-theme usb_modeswitch zram-generator-defaults

RUN chmod +x /tmp/scripts/* && \
    mkdir -p /var/lib/alternatives && \
    if [[ "$IMAGE_FLAVOR" = "main" ]]; then \
        /tmp/scripts/drivers.sh && \
        rm -rf /etc/pki/akmods/private/private_key.priv; else \
        /tmp/scripts/nvidia.sh; fi
    
RUN /tmp/scripts/non-repo.sh

RUN rm -rf /root && dnf install -y rootfiles

COPY files/usr/share/pixmaps/ /usr/share/pixmaps/
COPY files/usr/share/plymouth/ /usr/share/plymouth/

RUN plymouth-set-default-theme bgrt && \
    dracut --kver "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
