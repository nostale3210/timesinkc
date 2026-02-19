ARG SOURCE_IMAGE="${SOURCE_IMAGE:-fedora}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"
ARG BASE_IMAGE="${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"

FROM "quay.io/${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}" AS shared

ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"

RUN dnf swap -y --allowerasing fedora-release-container fedora-release && \
    dnf swap -y --allowerasing fedora-release-identity-container fedora-release-identity-basic && \
    dnf distro-sync -y && \
    dnf install -y dnf5-plugins && \
    dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release && \
    dnf install -y terra-release-mesa terra-release-multimedia && \
    dnf config-manager -y setopt "*terra*".priority=1 "*terra*".exclude="nerd-fonts scx-tools scx-scheds python3-protobuf gnome*" && \
    dnf config-manager -y setopt "*fedora*".exclude="kernel-core-* kernel-modules-* kernel-uki-virt-*"

RUN --mount=type=bind,src=/scripts,target=/scripts \
    mkdir -p /var/lib/alternatives &&\
    readarray basic_pkgs < /scripts/basics.pkgs && \
    dnf install -y --setopt='tsflags=' "${basic_pkgs[@]}"

COPY files/ /

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/copr.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/drivers.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/non-repo.sh

COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/hald /usr/bin/hald
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/move-mount /usr/bin/move-mount
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/boot/90ald /usr/lib/dracut/modules.d/90ald
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/boot/ald-boot.service /usr/lib/systemd/system/ald-boot.service
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/boot/ald-boot.sh /usr/libexec/ald-boot.sh
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/tools/librarizer .
COPY --from=ghcr.io/nostale3210/hald-utils:latest /app/tools/dep_check .

RUN chmod +x /usr/libexec/ald-boot.sh

RUN mandb && bash librarizer && \
    sed "/# Dependencies/r drc_libs" /usr/lib/dracut/modules.d/90ald/module-setup.sh && \
    sed -i "/# Dependencies/r drc_libs" /usr/lib/dracut/modules.d/90ald/module-setup.sh && \
    rm -f librarizer drc_libs

RUN bash dep_check && \
    rm -f dep_check

RUN sed -i "s/tsd upgrade/hald dep -uzsag/g" /usr/libexec/sys-up && \
    sed -i "s/\"bootc\"/\"hald\"/g" /usr/libexec/sys-up

RUN chmod 4755 /usr/bin/newgidmap && \
    chmod 4755 /usr/bin/newuidmap

RUN KVER="$(rpm -q kernel-cachyos-lto --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
    dracut --no-hostonly --kver "$KVER" --reproducible -v \
    --add "ald tpm2-tss systemd-pcrphase plymouth" -f "/lib/modules/$KVER/initramfs.img" && \
    chmod 0600 "/lib/modules/$KVER/initramfs.img"



FROM shared AS gnome-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/gnome.sh


FROM gnome-main AS gnome-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh



FROM shared AS cosmic-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/cosmic.sh


FROM cosmic-main AS cosmic-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh



FROM shared AS niri-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/niri/install_groups.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/niri/comp_shell.sh "reg"


FROM niri-main AS niri-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh



FROM shared AS niri-git-main

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/niri/install_groups.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/niri/mango-git.sh

RUN --mount=type=bind,src=/scripts,target=/scripts \
    bash /scripts/niri/comp_shell.sh "git"


FROM niri-git-main AS niri-git-nvidia

RUN --mount=type=bind,src=/scripts,target=/scripts \
    --mount=type=secret,id=AKMOD_PRIVKEY,target=/tmp/certs/private_key.priv \
    bash /scripts/nvidia.sh
