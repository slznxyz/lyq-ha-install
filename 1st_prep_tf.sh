#!/bin/bash

echo
echo "Install USB driver & create hotplug support"
echo

#echo "Run update & install some files"
opkg update;
opkg install libusb-1.0;
opkg install usbutils --force-depends;
opkg install kmod-usb-core --force-depends;
opkg install git-http;
opkg install ca-bundle;
opkg install  mosquitto-client

#echo "get driver to module dir"
wget https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/usb-acm -P /etc/modules.d
#echo "get driver to hotplug dir"
wget https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/cdc-acm.ko -P /tmp;
cd /tmp;
modprobe cdc-acm;
mkdir -p /opt/usbacm;
cd;

echo
echo "Adding z-wave usb dongle"
echo

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

cat <<\EOF > /opt/usbacm/usbinit.sh
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

chmod +x /opt/usbacm/usbinit.sh;

echo
echo "Adding cc2531 usb dongle"
echo

cat <<\EOF > /etc/hotplug.d/usb/20-zigbee
ZIGBEE_PRODID="451/16a8/9"
SYMLINK="zigbee"


if [ "${PRODUCT}" = "${ZIGBEE_PRODID}" ]; then
    if [ "${ACTION}" = "add" ]; then
        DEVICE_NAME=$(find /sys/${DEVPATH}/tty/ -name ttyACM* | grep -Eo "ttyACM.*$")
        if [ -z ${DEVICE_NAME} ]; then
            logger -t hotplug "20-zigbee: Info: no tty device created - exiting"
            exit
        fi
          logger -t hotplug "20-zigbee: determined ${DEVICE_NAME} as device name for Ti CC2531 "


        /bin/chown root:plugdev /dev/${DEVICE_NAME}
        /bin/chmod 664 /dev/${DEVICE_NAME}
        logger -t hotplug "20-zigbee: Changed access rights for /dev/${DEVICE_NAME}"


        ln -s /dev/${DEVICE_NAME} /dev/${SYMLINK}
        logger -t hotplug "20-zigbee: Symlink /dev/${SYMLINK} -> /dev/${DEVICE_NAME} created"
    fi


    if [ "${ACTION}" = "remove" ]; then
        rm /dev/${SYMLINK}
        logger -t hotplug "20-zigbee: Symlink /dev/${SYMLINK} removed"
    fi
fi
EOF

cat <<\EOF > /opt/usbacm/usbinit_z2531.sh
#!/bin/bash


ID_ZIGBEE="451/16a8/9"


# Devices werden beim Booten quasi eingesteckt...
ACTION="add"


# Init cdc_acm devices
for i in $(dmesg | grep -Eo "cdc_acm.*ttyACM.*$" | cut -d " " -f 2); do


        DEVICENAME=${i%:}
        DEVPATH="bus/usb/devices/${DEVICENAME}"
        PRODUCT=$(grep PRODUCT /sys/bus/usb/devices/${DEVICENAME}/uevent | cut -d "=" -f 2)


        case "${PRODUCT}" in
                ${ID_ZIGBEE})
                        . /etc/hotplug.d/usb/20-zigbee
                        ;;
        esac
done
EOF

chmod +x /opt/usbacm/usbinit_z2531.sh;

echo
echo "Adding cc2538 usb dongle"
echo

cat <<\EOF > /etc/hotplug.d/usb/20-zcc2538
ZCC2538_PRODID="451/16c8/100"
SYMLINK="zcc2538"




if [ "${PRODUCT}" = "${ZCC2538_PRODID}" ]; then
    if [ "${ACTION}" = "add" ]; then
        DEVICE_NAME=$(find /sys/${DEVPATH}/tty/ -name ttyACM* | grep -Eo "ttyACM.*$")
        if [ -z ${DEVICE_NAME} ]; then
            logger -t hotplug "20-zcc2538: Info: no tty device created - exiting"
            exit
        fi
          logger -t hotplug "20-zcc2538: determined ${DEVICE_NAME} as device name for Ti CC2538 "




        /bin/chown root:plugdev /dev/${DEVICE_NAME}
        /bin/chmod 664 /dev/${DEVICE_NAME}
        logger -t hotplug "20-zcc2538: Changed access rights for /dev/${DEVICE_NAME}"




        ln -s /dev/${DEVICE_NAME} /dev/${SYMLINK}
        logger -t hotplug "20-zcc2538: Symlink /dev/${SYMLINK} -> /dev/${DEVICE_NAME} created"
    fi




    if [ "${ACTION}" = "remove" ]; then
        rm /dev/${SYMLINK}
        logger -t hotplug "20-zcc2538: Symlink /dev/${SYMLINK} removed"
    fi
fi
EOF

cat <<\EOF > /opt/usbacm/usbinit_z2538.sh
#!/bin/bash




ID_ZCC2538="451/16c8/100"




# Devices werden beim Booten quasi eingesteckt...
ACTION="add"




# Init cdc_acm devices
for i in $(dmesg | grep -Eo "cdc_acm.*ttyACM.*$" | cut -d " " -f 2); do




        DEVICENAME=${i%:}
        DEVPATH="bus/usb/devices/${DEVICENAME}"
        PRODUCT=$(grep PRODUCT /sys/bus/usb/devices/${DEVICENAME}/uevent | cut -d "=" -f 2)




        case "${PRODUCT}" in
                ${ID_ZCC2538})
                        . /etc/hotplug.d/usb/20-zcc2538
                        ;;
        esac
done
EOF

chmod +x /opt/usbacm/usbinit_z2538.sh;

cp /etc/rc.local /etc/rc.local.bak;
sed -i '/exit 0/i bash /opt/usbacm/usbinit.sh \nsleep 1 \nbash /opt/usbacm/usbinit_z2531.sh \nsleep 1 \nbash /opt/usbacm/usbinit_z2538.sh' /etc/rc.local
sed -i  '/list listen_https/s/^/#/' /etc/config/uhttpd

cat >> /etc/config/adbyby <<'EOF'
    list subscribe_url 'https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts'
    list subscribe_url 'https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt'
    list subscribe_url 'https://gitee.com/halflife/list/raw/master/ad.txt'
    list subscribe_url 'https://gitee.com/xinggsf/Adblock-Rule/raw/master/mv.txt'
    list subscribe_url 'https://anti-ad.net/easylist.txt'
EOF
