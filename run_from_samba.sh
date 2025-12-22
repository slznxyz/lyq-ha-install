#!/usr/bin/env bash
set -euo pipefail

SAMBA_MOUNT="/mnt/samba"
SAMBA_SHARE="//192.168.123.200/share/311_401"
SMB_USER="478f5561"
SMB_PASS="A123456a"

LOCAL_DIR="/mnt/data"
ROOT_SCRIPT="/root/all_in_one_prod.sh"
LOG_DIR="/root"
RUN_LOG="${LOG_DIR}/all_in_one_prod.$(date +%F_%H%M%S).log"

echo "==> [1/6] 准备目录"
mkdir -p "${SAMBA_MOUNT}"
mkdir -p "${LOCAL_DIR}"

echo "==> [2/6] 挂载 Samba（如已挂载会跳过）"
if mountpoint -q "${SAMBA_MOUNT}"; then
  echo "    已挂载：${SAMBA_MOUNT}"
else
  # 安装 cifs 工具（若未安装）
  if ! command -v mount.cifs >/dev/null 2>&1; then
    echo "    安装 cifs-utils..."
    apt-get update -y
    apt-get install -y cifs-utils
  fi

  mount -t cifs "${SAMBA_SHARE}" "${SAMBA_MOUNT}" \
    -o "username=${SMB_USER},password=${SMB_PASS},iocharset=utf8,vers=3.0"
  echo "    挂载完成：${SAMBA_SHARE} -> ${SAMBA_MOUNT}"
fi

echo "==> [3/6] 检查 Samba 内文件"
if ! ls -1 "${SAMBA_MOUNT}"/*.sh >/dev/null 2>&1; then
  echo "❌ 在 ${SAMBA_MOUNT} 下未找到任何 .sh 文件，请确认共享路径是否正确：${SAMBA_SHARE}"
  exit 1
fi

if [[ ! -f "${SAMBA_MOUNT}/all_in_one_prod.sh" ]]; then
  echo "❌ 未找到 ${SAMBA_MOUNT}/all_in_one_prod.sh"
  echo "   目录下现有文件："
  ls -lah "${SAMBA_MOUNT}"
  exit 1
fi

echo "==> [4/6] 复制所有 .sh 到 ${LOCAL_DIR}"
cp -av "${SAMBA_MOUNT}"/*.sh "${LOCAL_DIR}/"

echo "==> [5/6] 复制 all_in_one_prod.sh 到 /root 并赋权"
cp -av "${SAMBA_MOUNT}/all_in_one_prod.sh" "${ROOT_SCRIPT}"
chmod +x "${ROOT_SCRIPT}"

echo "==> [6/6] 后台运行 all_in_one_prod.sh（不受 PuTTY/SSH 断开影响）"
echo "    日志：${RUN_LOG}"

# 用 setsid + nohup，彻底脱离终端会话；同时写日志
# bash -lc 确保用 login shell 语义加载 PATH 等（更稳）
setsid nohup bash -lc "cd /root && '${ROOT_SCRIPT}'" \
  >"${RUN_LOG}" 2>&1 < /dev/null &

PID=$!
disown || true

echo "✅ 已启动：PID=${PID}"
echo "👉 查看实时日志：tail -f '${RUN_LOG}'"
echo "👉 查看进程：ps -fp ${PID} || pgrep -af all_in_one_prod.sh"
