ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts/ /tmp/scripts

RUN useradd -mG wheel temp && passwd -d temp

RUN dnf install -y fedora-release-silverblue

RUN readarray gnome_pkgs < /tmp/scripts/gnome.pkgs && \
    dnf install -y ${gnome_pkgs[*]}

RUN dnf install -y neovim
