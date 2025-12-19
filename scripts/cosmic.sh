#!/usr/bin/env bash
set -oue pipefail

dnf config-manager -y setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1 \
    rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1

dnf install -y @cosmic-desktop-environment --skip-broken \
    --exclude=thunderbird,gnome-calculator,nheko,okular,rhythmbox,abrt,libreoffice-core \
    --exclude=firefox,setroubleshoot,librewolf,toolbox
dnf install -y wiremix gnome-tweaks

dnf config-manager -y setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0 \
    rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0 \
    terra.enabled=0 terra-mesa.enabled=0 terra-multimedia.enabled=0

rm -rf /etc/systemd/system/display-manager.service
systemctl enable cosmic-greeter.service

sed -i "s/Inherits=Adwaita/Inherits=Pop,Adwaita/" /usr/share/icons/default/index.theme

#hide applications
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvim.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/micro.desktop
