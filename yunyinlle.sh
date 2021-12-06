#!/bin/bash
opkg update;
opkg install git-http;
opkg install ca-bundle;
cd /opt/hassio/nodered;
git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git;
chmod -R 777 /opt/hassio/nodered/NeteaseCloudMusicApi
cd NeteaseCloudMusicApi;
cp app.js app.js.bak;
sed -i 's/3000/3500/' app.js;
docker exec nodered /bin/bash -c "npm install md5;npm install music-metadata;npm install qrcode;npm install safe-decode-uri-component;npm install express-fileupload;npm install pac-proxy-agent;npm install tunnel;";
docker restart nodered;
