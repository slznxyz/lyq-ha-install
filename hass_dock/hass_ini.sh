#!/bin/bash

echo
echo "hass docker initial script"
echo

pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/;
pip3 install qiniu asgiref;
wget -q -O - https://install.hacs.xyz | bash -
git clone https://github.com.cnpmjs.org/shaonianzhentan/ha_file_explorer --depth=1
cp -r ./ha_file_explorer/custom_components/ha_file_explorer custom_components
rm -rf ha_file_explorer;

touch lights.yaml;

cat >> configuration.yaml <<'EOF'
light: !include lights.yaml
EOF

touch /opt/hassio/homeassistant/customize.yaml;
touch /opt/hassio/homeassistant/known_devices.yaml;
touch /opt/hassio/homeassistant/ui-lovelace.yaml;
mkdir /opt/hassio/homeassistant/packages;
mkdir /opt/hassio/homeassistant/www;
nano /opt/hassio/homeassistant/configuration.yaml
