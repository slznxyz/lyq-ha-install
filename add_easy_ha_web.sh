#!/bin/bash

# frpc.ini 文件路径
FRPC_INI="/usr/share/hassio/share/frpc.ini"

# 循环直到用户确认输入一致
while true; do
    read -p "请输入子域名（xxxxxxx）： " subdomain1
    read -p "请再次输入子域名确认： " subdomain2

    if [ "$subdomain1" = "$subdomain2" ]; then
        echo "确认成功，使用子域名：$subdomain1"
        break
    else
        echo "两次输入不一致，请重新输入。"
    fi
done

# 追加 [easy_ha_web] 配置到 frpc.ini
cat <<EOF >> "$FRPC_INI"

[easy_ha_web]
type = http
privilege_mode = true
local_ip = 127.0.0.1
local_port = 8123
#remote_port = 80
subdomain = $subdomain1
use_encryption = true
use_gzip = true
#host_header_rewrite =
# $subdomain1.vip.slzn.fun
EOF

docker restart addon_d6bcf3bc_frp_client
echo "[easy_ha_web] 已追加到 $FRPC_INI 文件末尾。"
