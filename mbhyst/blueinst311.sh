#!/bin/bash

echo
echo "Install BlueTooth Drivers for M401A"
echo

apt update && apt install -y apt-transport-https apparmor udisks2 gpiod lrzsz avahi-daemon bluez bluetooth pulseaudio-module-bluetooth bluez-firmware;
mv /lib/firmware/rtl_bt/rtl8761b_config.bin /lib/firmware/rtl_bt/rtl8761b_config.bin.orig;
curl -L https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/rtl8761b_config_2m -o /lib/firmware/rtl_bt/rtl8761b_config.bin;
mv /boot/dtb/amlogic/meson-g12a-s905l3a-cm311.dtb /boot/dtb/amlogic/meson-g12a-s905l3a-cm311.dtb.orig;
curl -L https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/meson-g12a-cm311.dtb -o /boot/dtb/amlogic/meson-g12a-s905l3a-cm311.dtb;
sed -i '/ProtectSystem=full/a ExecStopPost=\/usr\/bin\/env gpioset 0 82=0' /lib/systemd/system/bluetooth.service;
apt-get install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus cifs-utils systemd-journal-remote -y;
touch /etc/default/grub && echo "systemd.unified_cgroup_hierarchy=false" > /etc/default/grub;
sed -i 's/swapaccount=1$/& apparmor=1 security=apparmor systemd.unified_cgroup_hierarchy=0/' /boot/uEnv.txt;
sed -i '1s/^/#/; 1a PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"' /etc/os-release;
wget https://github.com/home-assistant/os-agent/releases/download/1.5.1/os-agent_1.5.1_linux_aarch64.deb;

cat >> ~/update-hostname.sh <<'EOF'
#!/bin/bash

# 提示输入新的主机名
read -p "Enter new hostname: " new_hostname

# 检查是否输入了新的主机名
if [ -z "$new_hostname" ]; then
    echo "No hostname entered. Exiting."
    exit 1
fi

# 使用sudo和sed命令更新/etc/hostname和/etc/hosts文件
sudo sed -i "s/armbian/$new_hostname/g" /etc/hostname
sudo sed -i "s/armbian/$new_hostname/g" /etc/hosts

echo "Hostname and hosts file updated successfully."

# 询问用户是否需要重启
read -p "Do you want to reboot now? (y/n): " answer

case $answer in
    [Yy]* )
        echo "Rebooting now..."
        sudo reboot
        ;;
    [Nn]* )
        echo "Reboot canceled."
        ;;
    * )
        echo "Invalid response. Exiting without reboot."
        ;;
esac
EOF

chmod +x update-hostname.sh;
./update-hostname.sh
