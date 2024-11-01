ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM "quay.io/${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}" AS shared

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /

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
    bash /scripts/non-repo.sh && \
    ostree container commit

RUN KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
    dracut --no-hostonly --kver "$KVER" --reproducible -v --add "ostree tpm2-tss systemd-pcrphase" -f "/lib/modules/$KVER/initramfs.img" && \
    chmod 0600 "/lib/modules/$KVER/initramfs.img" && \
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
