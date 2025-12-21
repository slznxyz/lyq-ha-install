#!/bin/bash
set -euo pipefail

############################################
# 生产版：自动识别 M401A / CM311，安装蓝牙驱动并自动重启
# - 仅 DTB 部分按型号分支
# - 其余步骤与原两份脚本一致
# - update-hostname.sh：不询问，直接 reboot
############################################

if [ "$(id -u)" -ne 0 ]; then
  echo "❌ 请用 root 运行：sudo bash $0"
  exit 1
fi

log() { echo -e "[$(date '+%F %T')] $*"; }

get_model() {
  # ARM 盒子最常见：device-tree model
  if [ -r /sys/firmware/devicetree/base/model ]; then
    tr -d '\0' </sys/firmware/devicetree/base/model
    return 0
  fi
  # 某些平台会有 DMI
  if [ -r /sys/class/dmi/id/product_name ]; then
    cat /sys/class/dmi/id/product_name
    return 0
  fi
  echo "UNKNOWN"
}

MODEL="$(get_model)"
log "Detected model: ${MODEL}"

echo
echo "Install BlueTooth Drivers (All-in-One Production)"
echo

############################################
# 通用依赖安装
############################################
log "apt update..."
apt update -y

log "Installing bluetooth/system packages..."
apt install -y apt-transport-https apparmor udisks2 gpiod lrzsz avahi-daemon \
  bluez bluetooth pulseaudio-module-bluetooth bluez-firmware

############################################
# 通用：替换 RTL8761B firmware
############################################
FW_DIR="/lib/firmware/rtl_bt"
FW_FILE="${FW_DIR}/rtl8761b_config.bin"
FW_BAK="${FW_FILE}.orig"
FW_URL="https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/rtl8761b_config_2m"

log "Updating bluetooth firmware: ${FW_FILE}"
if [ -f "$FW_FILE" ] && [ ! -f "$FW_BAK" ]; then
  mv "$FW_FILE" "$FW_BAK"
  log "Backup created: ${FW_BAK}"
fi
curl -fL "$FW_URL" -o "$FW_FILE"

############################################
# 分支：DTB 替换（关键差异）
############################################
DTB_DIR="/boot/dtb/amlogic"

case "$MODEL" in
  *M401A*|*m401a*)
    DTB_FILE="${DTB_DIR}/meson-g12a-s905l3a-m401a.dtb"
    DTB_BAK="${DTB_FILE}.orig"
    DTB_URL="https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/meson-g12a-s905l3a-m401a-bt.dtb"
    log "Model branch: M401A"
    ;;
  *CM311*|*cm311*)
    DTB_FILE="${DTB_DIR}/meson-g12a-s905l3a-cm311.dtb"
    DTB_BAK="${DTB_FILE}.orig"
    DTB_URL="https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/meson-g12a-cm311.dtb"
    log "Model branch: CM311"
    ;;
  *)
    log "❌ Unknown model: ${MODEL}"
    log "请执行并把输出发我，我给你加型号分支："
    log "  cat /sys/firmware/devicetree/base/model 2>/dev/null | tr -d '\\0'"
    log "  uname -a"
    exit 1
    ;;
esac

log "Updating DTB: ${DTB_FILE}"
if [ -f "$DTB_FILE" ] && [ ! -f "$DTB_BAK" ]; then
  mv "$DTB_FILE" "$DTB_BAK"
  log "Backup created: ${DTB_BAK}"
fi
curl -fL "$DTB_URL" -o "$DTB_FILE"

############################################
# 通用：bluetooth.service 增加 ExecStopPost
############################################
BT_SVC="/lib/systemd/system/bluetooth.service"
log "Patching bluetooth.service ExecStopPost..."
if [ -f "$BT_SVC" ]; then
  if ! grep -q 'ExecStopPost=/usr/bin/env gpioset 0 82=0' "$BT_SVC"; then
    sed -i '/ProtectSystem=full/a ExecStopPost=\/usr\/bin\/env gpioset 0 82=0' "$BT_SVC"
    log "Patched: ExecStopPost added"
  else
    log "Already patched, skip"
  fi
else
  log "⚠️ bluetooth.service not found at ${BT_SVC} (skip patch)"
fi

############################################
# 通用：额外依赖 + cgroup / apparmor 设置
############################################
log "Installing extra packages..."
apt-get install -y apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus cifs-utils systemd-journal-remote

log "Setting /etc/default/grub..."
touch /etc/default/grub
echo "systemd.unified_cgroup_hierarchy=false" > /etc/default/grub

log "Patching /boot/uEnv.txt..."
if [ -f /boot/uEnv.txt ]; then
  if ! grep -q 'apparmor=1' /boot/uEnv.txt; then
    sed -i 's/swapaccount=1$/& apparmor=1 security=apparmor systemd.unified_cgroup_hierarchy=0/' /boot/uEnv.txt
  else
    log "uEnv.txt already patched, skip"
  fi
else
  log "⚠️ /boot/uEnv.txt not found, skip"
fi

log "Patching /etc/os-release..."
if [ -f /etc/os-release ]; then
  # 保持与你原脚本一致：注释第一行，并插入 PRETTY_NAME
  sed -i '1s/^/#/; 1a PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"' /etc/os-release || true
fi

############################################
# 通用：下载 os-agent
############################################
OS_AGENT_URL="https://github.com/home-assistant/os-agent/releases/download/1.7.1/os-agent_1.7.1_linux_aarch64.deb"
log "Downloading os-agent..."
wget -q -O /root/os-agent_1.7.1_linux_aarch64.deb "$OS_AGENT_URL"
log "Saved to /root/os-agent_1.7.1_linux_aarch64.deb"

############################################
# 通用：生成 update-hostname.sh（生产版：无询问直接 reboot）
############################################
log "Creating update-hostname.sh (auto reboot)..."
cat > /root/update-hostname.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# 获取eth0网卡的MAC地址
mac_address="$(cat /sys/class/net/eth0/address 2>/dev/null || true)"

if [ -z "$mac_address" ]; then
  echo "Unable to retrieve MAC address for eth0. Exiting."
  exit 1
fi

# 获取MAC地址的最后8位，并去掉冒号，转换为大写
new_hostname="$(echo "$mac_address" | sed 's/://g' | tail -c 9 | tr 'a-z' 'A-Z')"

echo "Setting hostname to the last 8 characters of MAC address (in uppercase): $new_hostname"

current_hostname="$(cat /etc/hostname 2>/dev/null || hostname)"

# 更新/etc/hostname和/etc/hosts文件中的主机名
sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
sed -i "s/$current_hostname/$new_hostname/g" /etc/hosts

echo "Hostname and hosts file updated successfully."
echo "Rebooting now..."
sleep 2
reboot
EOF

chmod +x /root/update-hostname.sh

############################################
# 执行并自动重启
############################################
log "Running update-hostname.sh (system will reboot)..."
/root/update-hostname.sh

# 理论上不会执行到这里
log "Done."
