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

cat >> configuration.yaml <<'EOF'
light: !include lights.yaml
EOF

touch lights.yaml;
touch customize.yaml;
touch known_devices.yaml;
touch ui-lovelace.yaml;
mkdir packages;
mkdir www;
#vi configuration.yaml
