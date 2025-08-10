#!/bin/bash 

set -e 

echo "正在配置软件源..."
cd immortalwrt-imagebuilder-* || exit 1 
 
ARCH_PACKAGES=$(grep 'CONFIG_TARGET_ARCH_PACKAGES=' .config | cut -d '"' -f 2)
echo "检测到架构包: $ARCH_PACKAGES"
 
mkdir -p files/etc/opkg       # 创建目录
touch files/etc/opkg/customfeeds.conf   # 创建文件

echo "src/gz kiddin9_packages https://dl.openwrt.ai/releases/24.10/packages/$ARCH_PACKAGES/kiddin9" >> files/etc/opkg/customfeeds.conf

touch files/etc/opkg.conf   # 创建文件

echo "dest root /" >> files/etc/opkg.conf
echo "dest ram /tmp" >> files/etc/opkg.conf
echo "lists_dir ext /var/opkg-lists" >> files/etc/opkg.conf
echo "option overlay_root /overlay" >> files/etc/opkg.conf
