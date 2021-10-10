#!/bin/bash

docker pull eclipse-mosquitto;

mkdir -p /opt/hassio/mosquitto/config && mkdir -p /opt/hassio/mosquitto/data && mkdir -p /opt/hassio/mosquitto/log && touch /opt/hassio/mosquitto/config/mosquitto.conf;

sleep 2

cat >> /opt/hassio/mosquitto/config/mosquitto.conf <<'EOF'
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
EOF

chmod -R 755 /opt/hassio/mosquitto && chmod -R 777 /opt/hassio/mosquitto/log;

docker run -d --privileged -p 1883:1883 -p 9001:9001 --net=host --restart=always -it --name mosquitto -v /etc/localtime:/etc/localtime:ro -v /opt/hassio/mosquitto/config:/mosquitto/config/ -v /opt/hassio/mosquitto/data:/mosquitto/data -v /opt/hassio/mosquitto/log/:/mosquitto/log eclipse-mosquitto

sleep 5

cat >> /opt/hassio/mosquitto/config/mosquitto.conf <<'EOF'
allow_anonymous false
password_file /mosquitto/config/pwfile.conf
EOF

docker exec mosquitto /bin/bash -c "touch /mosquitto/config/pwfile.conf;chmod -R 755 /mosquitto/config/pwfile.conf;mosquitto_passwd -b /mosquitto/config/pwfile.conf pi raspberry;exit";

docker restart mosquitto
