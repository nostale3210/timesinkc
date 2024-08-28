#!ALD_PATH/init/safe/busybox ash

if [[ "$(ALD_PATH/init/safe/busybox cat ALD_PATH/current)" != "INSERT_DEPLOYMENT" ]]; then
    ALD_PATH/init/safe/busybox mount -o remount,rw /
    ALD_PATH/init/safe/jexch -e /usr ALD_PATH/INSERT_DEPLOYMENT/usr || break
    ALD_PATH/init/safe/jexch -e /etc ALD_PATH/INSERT_DEPLOYMENT/etc
    ALD_PATH/init/safe/busybox mv ALD_PATH/INSERT_DEPLOYMENT ALD_PATH/"$(ALD_PATH/init/safe/busybox cat ALD_PATH/current)"
    ALD_PATH/init/safe/busybox echo "INSERT_DEPLOYMENT" > ALD_PATH/current
fi

mount -o bind,ro /usr /usr
mount -o bind,rw /usr/local /usr/local

exec /usr/sbin/init
