ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts /tmp/scripts
COPY certs /tmp/certs

RUN rpm-ostree upgrade

RUN rpm-ostree install bootc neovim adw-gtk3-theme gnome-tweaks nautilus-python \
    pinentry-gnome3 evince-thumbnailer evince-previewer totem-video-thumbnailer \
    firefox geoclue2 unzip distrobox

RUN rpm-ostree install zsh zsh-autosuggestions zsh-syntax-highlighting

RUN bash /tmp/scripts/fusion.sh

RUN bash /tmp/scripts/copr.sh

RUN if [[ "$IMAGE_FLAVOR" = "main" ]]; then \
        bash /tmp/scripts/drivers.sh; else \
        bash /tmp/scripts/nvidia.sh; fi

RUN bash /tmp/scripts/non-repo.sh
