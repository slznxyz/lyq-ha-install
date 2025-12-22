cat > /root/bootstrap_from_samba.sh <<'EOF'
#!/bin/bash
set -euo pipefail

#####################################
# Samba 配置
#####################################
SAMBA_SHARE="//192.168.123.200/share/311_401"
SAMBA_MOUNT="/mnt/samba311401"
LOCAL_DIR="/mnt/data"

SMB_USER="478f5561"
SMB_PASS="A123456a"

#####################################
# 1. 必须 root
#####################################
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ 请使用 root 执行：sudo bash $0"
  exit 1
fi

log() { echo "[`date '+%F %T'`] $*"; }

#####################################
# 2. 安装 cifs-utils（必须先有）
#####################################
log "📦 检查并安装 cifs-utils"
if ! command -v mount.cifs >/dev/null 2>&1; then
  apt update
  apt install -y cifs-utils
else
  log "✅ cifs-utils 已安装"
fi

#####################################
# 3. 创建目录
#####################################
log "📁 创建目录"
mkdir -p "${SAMBA_MOUNT}"
mkdir -p "${LOCAL_DIR}"

#####################################
# 4. 挂载 Samba
#####################################
if mountpoint -q "${SAMBA_MOUNT}"; then
  log "✅ Samba 已挂载：${SAMBA_MOUNT}"
else
  log "🔗 正在挂载 Samba..."
  mount -t cifs "${SAMBA_SHARE}" "${SAMBA_MOUNT}" \
    -o username="${SMB_USER}",password="${SMB_PASS}",iocharset=utf8,vers=3.0
  log "✅ Samba 挂载完成"
fi

#####################################
# 5. 拷贝所有 .sh 到 /mnt/data
#####################################
log "📦 拷贝 *.sh 到 ${LOCAL_DIR}"
cp -av "${SAMBA_MOUNT}"/*.sh "${LOCAL_DIR}/"

#####################################
# 6. 单独拷贝 all_in_one_prod.sh 到 /root
#####################################
if [ ! -f "${SAMBA_MOUNT}/all_in_one_prod.sh" ]; then
  echo "❌ Samba 中未找到 all_in_one_prod.sh"
  exit 1
fi

cp -av "${SAMBA_MOUNT}/all_in_one_prod.sh" /root/
chmod +x /root/all_in_one_prod.sh

#####################################
# 7. 后台运行（SSH 断开不影响）
#####################################
log "🚀 后台启动 all_in_one_prod.sh"

nohup bash /root/all_in_one_prod.sh \
  > /root/all_in_one_prod.log 2>&1 &

log "✅ 已后台运行"
log "📄 日志文件：/root/all_in_one_prod.log"
log "👉 现在可以直接关闭 PuTTY"
EOF
