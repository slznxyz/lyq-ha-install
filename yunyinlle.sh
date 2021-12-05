#!/bin/bash

docker exec nodered /bin/bash -c "npm install md5;npm install music-metadata;npm install qrcode;npm install safe-decode-uri-component;npm install express-fileupload;npm install pac-proxy-agent;npm install tunnel;";

docker restart nodered;
