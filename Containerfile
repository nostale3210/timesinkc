ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:latest as main

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

COPY files/ /
COPY scripts /usr/share/timesink/scripts

RUN dnf install -y @printing && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/copr.sh && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/drivers.sh && \
    ostree container commit

RUN bash /usr/share/timesink/scripts/non-repo.sh && \
    ostree container commit

FROM main as nvidia

RUN --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
        bash /usr/share/timesink/scripts/nvidia.sh

