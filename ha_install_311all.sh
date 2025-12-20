#!/bin/bash
set -e




WORKDIR="/root/ha_install"
SERVICE_NAME="ha-final-install.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"




mkdir -p "$WORKDIR"
cd "$WORKDIR"




echo "========== Step 1: sysprep + docker =========="




wget -q https://raw.githubusercontent.com/hhalibo/mbh-bulseye/refs/heads/main/sysprep.sh
wget -q https://raw.githubusercontent.com/hhalibo/mbh-bulseye/refs/heads/main/docker.sh
wget -q https://raw.githubusercontent.com/slznxyz/lyq-ha-install/refs/heads/main/load_images_from_samba.sh



chmod +x sysprep.sh docker.sh load_images_from_samba.sh
bash sysprep.sh
bash docker.sh
bash load_images_from_samba.sh

wget -q https://raw.githubusercontent.com/hhalibo/mbh-bulseye/refs/heads/main/blueinst311.sh
wget -q https://raw.githubusercontent.com/hhalibo/mbh-bulseye/refs/heads/main/update-hostname.sh
# 自动输入 y
yes y | bash blueinst311.sh
