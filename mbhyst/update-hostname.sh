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
