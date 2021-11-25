#!/bin/bash

docker pull koenkk/zigbee2mqtt;

docker run -d --restart=unless-stopped   --net=host --name=z2m8123 -it -v /etc/localtime:/etc/localtime:ro -v /opt/hassio/z2m8123:/app/data --device=/dev/ttyUSB0 -p 8099:8099 koenkk/zigbee2mqtt;

sleep 2

docker stop z2m8123;

mv /opt/hassio/z2m8123/configuration.yaml /opt/hassio/z2m8123/configuration.yaml.bak;

cat >> /opt/hassio/z2m8123/configuration.yaml <<'EOF'
# Home Assistant integration (MQTT discovery)
homeassistant: true


# allow new devices to join
permit_join: false


# MQTT settings
mqtt:
  # MQTT base topic for zigbee2mqtt MQTT messages
  base_topic: z2m8123
  # MQTT server URL
  server: 'mqtt://localhost:1883'
  # MQTT server authentication, uncomment if required:
  user: pi
  password: raspberry


# Serial settings
serial:
  # Location of USB sniffer
  port: /dev/ttyUSB0
advanced:
  log_level: error
  channel: 25
  pan_id: 0x1a88
## 6759
  ext_pan_id: [0xF3, 0x3D, 0xC4, 0xE4, 0xD2, 0xC8, 0xC3, 0x8B]  
  network_key: [1, 8, 8, 7, 8, 11, 11, 11, 0, 2, 4, 6, 8, 10, 12, 13]
  last_seen: 'ISO_8601_local'
  homeassistant_discovery_topic: 'hass-zigbee'
  # Optional: Home Assistant status topic (default: shown below)
  homeassistant_status_topic: 'slznok019/status'

frontend:
  port: 8099
EOF

docker restart z2m8123
