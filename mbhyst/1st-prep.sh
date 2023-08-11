#!/bin/bash

echo
echo "Install APT update & mosaquitto"
echo

#echo "Run update & install docker"
apt update;
apt upgrade -y;
apt install mosquitto-clients avahi-daemon -y;
curl -L https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-aarch64 -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;
curl -fsSL get.docker.com | sh;

touch /root/chkipadd.sh;
cat >> /root/chkipadd.sh <<'EOF'
#!/bin/bash

if ip addr show eth0 | grep "inet " > /dev/null 2>&1 ; then
        echo "eth0: Get ip address success."
else
        echo "eth0: Get ip address failed, retry..."
        ifconfig eth0 down && ifconfig eth0 up
fi
EOF

chmod 755 chkipadd.sh;

mv /etc/rc.local /etc/rc.local.bak;
cat >> /etc/rc.local <<'EOF'
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
#perl /usr/sbin/balethirq.pl
#bash /etc/custom_service/start_service.sh
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

perl /usr/sbin/balethirq.pl
bash /etc/custom_service/start_service.sh
bash /root/chkipadd.sh
exit 0
EOF

nmtui;
