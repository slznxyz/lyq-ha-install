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
#light: !include lights.yaml
rest:
  - scan_interval: 3600
    resource_template: http://tool.bitefu.net/jiari/?d={{ now().strftime('%Y%m%d') }}
    sensor:   
      - name: cn_workdays
        value_template: >-
          {% if value == '0' %}
            工作日
          {% elif value == '1' %}
            假日
          {% elif value == '2' %}
            节日
          {% else %}
            unknown
          {% endif %}
EOF

touch lights.yaml;
touch customize.yaml;
touch known_devices.yaml;
touch ui-lovelace.yaml;
mkdir packages;
mkdir www;
#vi configuration.yaml
wget https://raw.githubusercontent.com/slznxyz/lyq-ha-install/main/start_yunyinle.sh
wget https://github.com/slznxyz/lyq-ha-install/raw/main/haslayer/dio.zip;
unzip -d /config/custom_components/slrelay dio.zip;
rm -rf dio.zip;
exit
