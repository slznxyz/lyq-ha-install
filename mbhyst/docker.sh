#!/bin/bash


echo
echo "Docker install script for Hassbian"
echo


echo "Running apt-get preparation"
sudo apt-get update
sudo apt-get upgrade -y


sudo apt install -y apt-transport-https ca-certificates curl software-properties-common


echo "add the GPG key for the official Docker repository to your system"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -


echo "Add the Docker repository to APT sources"
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"


echo "Redo apt update"
sudo apt update
sudo apt install -y avahi-daemon avahi-discover libnss-mdns libavahi-compat-libdnssd-dev g++ gcc jq socat


echo "Make sure you are about to install from the Docker repo instead of the default debian repo"
apt-cache policy docker-ce


sleep 5


echo "Install Docker now"
#sudo apt install docker-ce -y
sudo apt-get install docker-ce=5:24.0.7-1~debian.11~bullseye docker-ce-cli=5:24.0.7-1~debian.11~bullseye containerd.io


echo
echo "Installation done."
echo
