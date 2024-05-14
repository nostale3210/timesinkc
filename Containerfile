ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts/ /tmp/scripts

RUN useradd -mG wheel temp && passwd -d temp

RUN dnf install -y fedora-release fedora-release-ostree-desktop fedora-release-silverblue \
    xorg-x11-server-Xwayland xdg-desktop-portal xdg-desktop-portal-gtk langpacks-en \
    flatpak

RUN readarray gnome_pkgs < /tmp/scripts/gnome.pkgs && \
    dnf install -y ${gnome_pkgs[*]}

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

RUN dnf install -y neovim adw-gtk3 gnome-tweaks nautilus-python \
    pinentry-gnome3 evince-thumbnailer evince-previewer totem-video-thumbnailer \
    firefox

RUN dnf install -y plymouth plymouth-system-theme usb_modeswitch zram-generator-defaults

RUN chmod a+r /usr/etc/udev/rules.d/51-android.rules && \
    chmod +x /usr/libexec/flatpak-manager && \
    chmod +x /usr/libexec/dotfile-manager && \
    systemctl enable dconf-update.service && \
    systemctl enable flatpak-manager.service

RUN dracut --kver "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
