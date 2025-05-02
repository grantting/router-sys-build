#!/bin/bash 
set -e 
 
echo "正在安装系统依赖..."
sudo apt-get update -y 
sudo apt-get install -y \
    jq zstd build-essential libncurses5-dev libncursesw5-dev \
    zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python3 \
    libelf-dev 
echo "依赖安装完成"