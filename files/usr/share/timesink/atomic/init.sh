#!/usr/bin/bash

if [[ "$(cat /var/deployments/current)" != "INSERT_DEPLOYMENT" ]]; then
    exch /usr /var/deployments/INSERT_DEPLOYMENT/usr
    exch /etc /var/deployments/INSERT_DEPLOYMENT/etc
    mv /var/deployments/INSERT_DEPLOYMENT /var/deployments/"$(cat /var/deployments/current)"
    echo "INSERT_DEPLOYMENT" > /var/deployments/current
fi

mount -o bind,ro /usr /usr

exec /usr/bin/init
