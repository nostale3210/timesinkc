#!/usr/bin/bash

mount -o rw,remount /
mount -o bind /deploy/INSERT_DEPLOYMENT /deploy/INSERT_DEPLOYMENT

cd /deploy/INSERT_DEPLOYMENT

mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount -o rbind /dev dev/
mount -o rbind /run run/

mount -o bind,rw /var var/
mount -o bind,rw /home home/
mount -o bind,rw /mnt mnt/
mount -o bind,rw /etc etc/
mount -o bind,rw /deploy deploy/

mkdir -p deploy/og
mount -o bind / deploy/og

mount -o bind,ro usr usr
chattr +i .

echo "INSERT_DEPLOYMENT" > deploy/current

mkdir -p var/.etc{,work}
mount -t overlay overlay -o lowerdir=etc,upperdir=var/.etc,workdir=var/.etcwork etc

exec /usr/sbin/switch_root /deploy/INSERT_DEPLOYMENT "/usr/sbin/init" "$@"
