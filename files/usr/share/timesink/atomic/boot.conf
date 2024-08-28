title ALD Deployment INSERT_DEPLOYMENT
version INSERT_DEPLOYMENT
linux /INSERT_DEPLOYMENT/vmlinuz
initrd /INSERT_DEPLOYMENT/initramfs.img
options root=UUID=INSERT_ROOT_UUID_HERE ro rd.luks.uuid=luks-INSERT_LUKS_UUID_HERE rhgb quiet init=ALD_PATH/init/INSERT_DEPLOYMENT.sh rd.luks.options=tpm2-device=auto,discard
grub_users $grub_users
grub_arg --unrestricted
grub_class fedora
