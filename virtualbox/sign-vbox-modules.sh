#!/bin/bash

# This script needs to run after every kernel update.

# Use `apt install virtualbox-6.1` instead of `apt install virtualbox`
# `apt list virtualbox-6.1 -a`

# All credits to Øyvind Stegard for this.
# Taken from https://stegard.net/2016/10/virtualbox-secure-boot-ubuntu-fail/

# sudo -i
# mkdir /root/module-signing
# cd /root/module-signing
# openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=YOUR_NAME/"
# [...]
# chmod 600 MOK.priv

# import the machine owner key and reboot, and enroll MOK
# sudo mokutil --import /root/module-signing/MOK.der

# use this script
#for modfile in $(dirname $(modinfo -n vboxdrv))/*.ko; do
#  echo "Signing $modfile"
#  /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 \
#                                /root/module-signing/MOK.priv \
#                                /root/module-signing/MOK.der "$modfile"
#done

# Run these just in case
# sudo /sbin/vboxconfig
# service virtualbox restart

sign_file="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"
mok_key="/var/lib/shim-signed/mok/MOK.priv"
mok_cert="/var/lib/shim-signed/mok/MOK.der"

for modfile in $(dirname $(modinfo -n vboxdrv))/*.ko; do
  echo "Signing $modfile"
  $sign_file sha256 $mok_key $mok_cert $modfile
done
echo "Loading vbox modules"
modprobe vboxdrv
modprobe vboxnetflt
modprobe vboxpci
modprobe vboxnetadp
echo "Loaded vbox modules:"
lsmod | grep vbox
