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
mount -o bind,rw /deploy deploy/

mkdir -p deploy/og
mount -o bind,ro / deploy/og

mount -o bind,ro usr usr
mount -o bind,rw usr/local usr/local
chattr +i .

echo "INSERT_DEPLOYMENT" > deploy/current

mkdir -p deploy/.var{,work}
mount -t overlay var-overlay -o lowerdir=var:deploy/var.INSERT_DEPLOYMENT,upperdir=deploy/.var,workdir=deploy/.varwork var

mkdir -p deploy/.etc{,work}
mount -t overlay etc-overlay -o lowerdir=etc,upperdir=deploy/.etc,workdir=deploy/.etcwork etc

exec /usr/sbin/switch_root /deploy/INSERT_DEPLOYMENT "/usr/sbin/init" "$@"
