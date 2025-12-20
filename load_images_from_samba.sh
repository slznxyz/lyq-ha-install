#!/bin/bash
set -euo pipefail


# ===============================
# 配置区
# ===============================
SAMBA_MOUNT="/mnt/samba"
SAMBA_SHARE="//192.168.123.173/share/dimages"
SMB_USER="478f5561"
SMB_PASS="A123456a"


# ===============================
# 1. 创建挂载目录
# ===============================
echo "📁 创建挂载目录 ${SAMBA_MOUNT}"
mkdir -p "${SAMBA_MOUNT}"


# ===============================
# 2. 挂载 Samba（如果尚未挂载）
# ===============================
if mountpoint -q "${SAMBA_MOUNT}"; then
    echo "✅ Samba 已挂载：${SAMBA_MOUNT}"
else
    echo "🔗 正在挂载 Samba..."
    mount -t cifs "${SAMBA_SHARE}" "${SAMBA_MOUNT}" \
        -o username="${SMB_USER}",password="${SMB_PASS}",iocharset=utf8,vers=3.0
    echo "✅ Samba 挂载完成"
fi


# ===============================
# 3. 检查 tar 文件是否存在
# ===============================
shopt -s nullglob
TAR_FILES=("${SAMBA_MOUNT}"/*.tar)


if [ ${#TAR_FILES[@]} -eq 0 ]; then
    echo "❌ 未在 ${SAMBA_MOUNT} 中找到任何 .tar 镜像文件"
    exit 1
fi


# ===============================
# 4. 导入 Docker 镜像（带进度）
# ===============================
echo "🐳 开始导入 Docker 镜像..."


for f in "${TAR_FILES[@]}"; do
    echo "----------------------------------------"
    echo "👉 正在导入: $f"
    pv "$f" | docker load
done


echo "========================================"
echo "✅ 所有 Docker 镜像已成功导入完成"
