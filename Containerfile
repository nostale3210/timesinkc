ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts /usr/share/timesink/scripts


RUN readarray basic_pkgs < /usr/share/timesink/scripts/basics.pkgs && \
    dnf install -y ${basic_pkgs[*]} && \
    ostree container commit

RUN readarray lang_pkgs < /usr/share/timesink/scripts/lang.pkgs && \
    dnf install -y ${lang_pkgs[*]} && \
    ostree container commit

RUN readarray network_pkgs < /usr/share/timesink/scripts/network.pkgs && \
    dnf install -y ${network_pkgs[*]} && \
    ostree container commit

RUN readarray gnome_pkgs < /usr/share/timesink/scripts/gnome.pkgs && \
    dnf install -y ${gnome_pkgs[*]} && \
    ostree container commit

RUN readarray fedora_release_pkgs < /usr/share/timesink/scripts/fedora-release.pkgs && \
    dnf install -y ${fedora_release_pkgs[*]} && \
    plymouth-set-default-theme bgrt && \
    ostree container commit

RUN readarray drivers_pkgs < /usr/share/timesink/scripts/drivers.pkgs && \
    dnf install -y ${drivers_pkgs[*]} && \
    ostree container commit

RUN readarray firmware_pkgs < /usr/share/timesink/scripts/firmware.pkgs && \
    dnf install -y ${firmware_pkgs[*]} && \
    ostree container commit

RUN readarray extra_pkgs < /usr/share/timesink/scripts/extras.pkgs && \
    dnf install -y ${extra_pkgs[*]} && \
    ostree container commit

RUN readarray fonts_pkgs < /usr/share/timesink/scripts/fonts.pkgs && \
    dnf install -y ${fonts_pkgs[*]} && \
    ostree container commit

RUN dnf install -y @printing && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/copr.sh && \
    ostree container commit

RUN --mount=type=secret,id=AKMOD_PRIVKEY,dst=/tmp/certs/private_key.priv \
    if [[ "$IMAGE_FLAVOR" = "main" ]]; then \
        bash /usr/share/timesink/scripts/drivers.sh; else \
        bash /usr/share/timesink/scripts/nvidia.sh; fi && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/non-repo.sh && \
    ostree container commit

COPY files/usr/share/pixmaps/ /usr/share/pixmaps/
COPY files/usr/share/plymouth/ /usr/share/plymouth/

RUN KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' | tail -n 1)" && \
    dracut --no-hostonly --kver "$KVER" \
    --reproducible -v --add "ostree plymouth i18n" \
    -f "/lib/modules/$KVER/initramfs.img" && \
    ostree container commit
