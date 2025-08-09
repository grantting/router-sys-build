#!/bin/sh

# opkg 配置文件
mkdir -p files/etc/opkg/

# 配置自定义软件源 
cat > files/etc/opkg/customfeeds.conf  <<EOF 
src/gz kiddin9_packages https://dl.openwrt.ai/releases/24.10/packages/\$ARCH_PACKAGES/kiddin9  
EOF 
 
# 配置opkg基本设置
cat > files/etc/opkg.conf  <<EOF
dest root /
dest ram /tmp
lists_dir ext /var/opkg-lists 
option overlay_root /overlay
EOF
