#!/var/deployments/init/safe/busybox ash

if [[ "$(/var/deployments/init/safe/busybox cat /var/deployments/current)" != "INSERT_DEPLOYMENT" ]]; then
    /var/deployments/init/safe/busybox mount -o remount,rw /
    /var/deployments/init/safe/jexch -e /usr /var/deployments/INSERT_DEPLOYMENT/usr || break
    /var/deployments/init/safe/jexch -e /etc /var/deployments/INSERT_DEPLOYMENT/etc
    /var/deployments/init/safe/busybox mv /var/deployments/INSERT_DEPLOYMENT /var/deployments/"$(/var/deployments/init/safe/busybox cat /var/deployments/current)"
    /var/deployments/init/safe/busybox echo "INSERT_DEPLOYMENT" > /var/deployments/current
fi

mount -o bind,ro /usr /usr

exec /usr/bin/init
