#!/bin/bash
set -e

INI_PATH="/usr/share/hassio/share/frpc.ini"
LOG_PATH="/usr/share/hassio/share/frpc.log"

# 读取 hostname 并强制转小写
HOSTNAME_RAW="$(cat /etc/hostname | tr -d '\n')"
HOSTNAME="$(echo "$HOSTNAME_RAW" | tr '[:upper:]' '[:lower:]')"

echo "📛 原始 hostname: $HOSTNAME_RAW"
echo "🔤 使用的小写 hostname: $HOSTNAME"
echo

# ===== 询问 remote_port（两次确认）=====
while true; do
  read -rp "请输入 ssh 的 remote_port（例如 16105）: " REMOTE_PORT_1
  read -rp "请再次确认 remote_port: " REMOTE_PORT_2

  if [[ "$REMOTE_PORT_1" != "$REMOTE_PORT_2" ]]; then
    echo "❌ 两次输入的 remote_port 不一致，请重新输入。"
    echo
    continue
  fi

  if ! [[ "$REMOTE_PORT_1" =~ ^[0-9]+$ ]]; then
    echo "❌ remote_port 必须是数字，请重新输入。"
    echo
    continue
  fi

  if (( REMOTE_PORT_1 < 1 || REMOTE_PORT_1 > 65535 )); then
    echo "❌ remote_port 必须在 1–65535 范围内。"
    echo
    continue
  fi

  REMOTE_PORT="$REMOTE_PORT_1"
  break
done

echo "✅ remote_port 已确认：$REMOTE_PORT"
echo

# ===== 自动生成 meta_token（20位 A-Za-z0-9）=====
# 说明：用 /dev/urandom 生成随机字节，过滤成 A-Za-z0-9，再截取 20 位
META_TOKEN="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)"

# ===== 确保目录存在 =====
mkdir -p "$(dirname "$INI_PATH")"

# ===== 生成 frpc.ini（完整保留所有 # 注释）=====
cat > "$INI_PATH" <<EOF
# [common] is integral section
[common]
# A literal address or host name for IPv6 must be enclosed
# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
server_addr = vip.slzn.fun
server_port = 17000
log_file = /share/frpc.log
log_level = info
log_max_days = 3
# for privilege mode
user = ${HOSTNAME}
meta_token = ${META_TOKEN}
[ssh]
privilege_mode = true
type = tcp
local_ip = 127.0.0.1
local_port = 22
use_encryption = true
use_gzip = false
remote_port = ${REMOTE_PORT}

[hass_web]
type = http
privilege_mode = true
local_ip = 127.0.0.1
local_port = 8123
#remote_port = 80
subdomain = ${HOSTNAME}
use_encryption = true
use_gzip = true
#host_header_rewrite =
# ${HOSTNAME}.vip.slzn.fun

[v2y_web]
type = http
privilege_mode = true
local_ip = 127.0.0.1
local_port = 2017
#remote_port = 80
subdomain = ${HOSTNAME}v2y
use_encryption = true
use_gzip = true
#host_header_rewrite =
EOF

# ===== 创建空日志文件 =====
touch "$LOG_PATH"

# ===== 结尾打印你要的字段 =====
echo "🎉 frpc.ini 已生成：$INI_PATH"
echo "📝 frpc.log 已创建：$LOG_PATH"
echo
echo "========= 生成结果 ========="
echo "user        = ${HOSTNAME}"
echo "remote_port = ${REMOTE_PORT}"
echo "meta_token  = ${META_TOKEN}"
echo "# ${HOSTNAME}.vip.slzn.fun"
echo "${HOSTNAME}v2y"
echo "==========================="
