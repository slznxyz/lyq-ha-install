#!/bin/bash

echo
echo "hass docker update initial script"
echo

pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip3 install qiniu asgiref
#exit
