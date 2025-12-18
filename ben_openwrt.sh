
#!/bin/bash




get_random_mac ()
{
    # MAC地址第一段可在 02 06 0A 0E 中任选一个
    if [ "$SHELL" == "/bin/bash" ];then
        #MACADDR=$(printf "%02X:%02X:%02X:%02X:%02X:%02X\n" $[RANDOM%255] $[RANDOM%255] $[RANDOM%255] $[RANDOM%255] $[RANDOM%255] $[RANDOM%255])
        MACADDR=$(printf "06:%02X:%02X:%02X:%02X:%02X\n" $[RANDOM%255] $[RANDOM%255] $[RANDOM%255] $[RANDOM%255] $[RANDOM%255])
    else
        uuid=$(cat /proc/sys/kernel/random/uuid)
        mac1="0E"
        #mac1=${uuid:24:2}
        mac2=${uuid:26:2}
        mac3=${uuid:28:2}
        mac4=${uuid:30:2}
        mac5=${uuid:32:2}
        mac6=${uuid:34:2}
        MACADDR=$(echo "$mac1:$mac2:$mac3:$mac4:$mac5:$mac6" | tr '[a-z]' '[A-Z]')
    fi
}




IMG_NAME=unifreq/openwrt-aarch64
IMG_TAG=latest
PREV_IMG_TAG=latest
#PREV_IMG_TAG=r21.10.01




MACNET=$(docker network ls | grep macnet | wc -l)
PARENT="eth0"
SUBNET="192.168.110.0/24"
GATEWAY="192.168.110.1"
IP="192.168.110.231"
if [ $MACNET -eq 0 ];then
        docker network create -d macvlan -o parent="$PARENT" --subnet "$SUBNET" --gateway "$GATEWAY" --subnet=fe80::1/16 --gateway=fe80::1 macnet
fi




docker stop openwrt-${PREV_IMG_TAG} 2>/dev/null
docker rm openwrt-${PREV_IMG_TAG} 2>/dev/null




get_random_mac
echo $MACADDR
KERNEL_VERSION=$(uname -r)
docker run --name openwrt \
        --restart always \
        --network macnet \
        --mac-address $MACADDR \
        --ip $IP \
        -d --privileged=true \
        --ulimit nofile=16384:65536  \
        -v /lib/modules/${KERNEL_VERSION}:/lib/modules/${KERNEL_VERSION} \
        $IMG_NAME:$IMG_TAG
