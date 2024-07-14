ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM quay.io/${BASE_IMAGE}:$FEDORA_MAJOR_VERSION as main

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts /usr/share/timesink/scripts

RUN readarray basic_pkgs < /usr/share/timesink/scripts/basics.pkgs && \
    dnf install -y ${basic_pkgs[*]} && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/copr.sh && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/drivers.sh && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/non-repo.sh && \
    ostree container commit

FROM main as nvidia

RUN --mount=type=secret,id=AKMOD_PRIVKEY,dst=/tmp/certs/private_key.priv \
        bash /usr/share/timesink/scripts/nvidia.sh

