#!/bin/bash

echo
echo "Install USB-acm driver & create hotplug support"
echo

#echo "Run install some files"
opkg update;
opkg install libusb-1.0;
opkg install usbutils --force-depends;
opkg install kmod-usb-core --force-depends;
opkg install  mosquitto-client

#echo "get driver to module dir"
#wget https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/usb-acm -P /etc/modules.d
#echo "get driver to hotplug dir"
#wget https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/cdc-acm.ko -P /tmp;
#cd /tmp;
#modprobe cdc-acm;
cd;

cat <<\EOF > /etc/hotplug.d/usb/20-zwave
ZWAVE_PRODID="658/200/0"
SYMLINK="zwave"


if [ "${PRODUCT}" = "${ZWAVE_PRODID}" ]; then
    if [ "${ACTION}" = "add" ]; then
        DEVICE_NAME=$(find /sys/${DEVPATH}/tty/ -name ttyACM* | grep -Eo "ttyACM.*$")
        if [ -z ${DEVICE_NAME} ]; then
            logger -t hotplug "20-zwave: Info: no tty device created - exiting"
            exit
        fi
          logger -t hotplug "20-zwave: determined ${DEVICE_NAME} as device name for Aeotec Z-Stick "


        /bin/chown root:plugdev /dev/${DEVICE_NAME}
        /bin/chmod 664 /dev/${DEVICE_NAME}
        logger -t hotplug "20-zwave: Changed access rights for /dev/${DEVICE_NAME}"


        ln -s /dev/${DEVICE_NAME} /dev/${SYMLINK}
        logger -t hotplug "20-zwave: Symlink /dev/${SYMLINK} -> /dev/${DEVICE_NAME} created"
    fi


    if [ "${ACTION}" = "remove" ]; then
        rm /dev/${SYMLINK}
        logger -t hotplug "20-zwave: Symlink /dev/${SYMLINK} removed"
    fi
fi
EOF

cat <<\EOF > /root/usbinit.sh
#!/bin/bash

ID_ZWAVE="658/200/0"

# Devices werden beim Booten quasi eingesteckt...
ACTION="add"

# Init cdc_acm devices
for i in $(dmesg | grep -Eo "cdc_acm.*ttyACM.*$" | cut -d " " -f 2); do

        DEVICENAME=${i%:}
        DEVPATH="bus/usb/devices/${DEVICENAME}"
        PRODUCT=$(grep PRODUCT /sys/bus/usb/devices/${DEVICENAME}/uevent | cut -d "=" -f 2)

        case "${PRODUCT}" in
                ${ID_ZWAVE})
                        . /etc/hotplug.d/usb/20-zwave
                        ;;
        esac
done
EOF

chmod +x /root/usbinit.sh;
cp /etc/rc.local /etc/rc.local.bak;
sed -i '/exit 0/i bash /root/usbinit_z2538.sh' /etc/rc.local;
