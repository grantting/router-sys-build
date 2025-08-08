#!/bin/bash 
set -e 

echo "正在配置软件源..."
cd immortalwrt-imagebuilder-* || exit 1 
 
ARCH_PACKAGES=$(grep 'CONFIG_TARGET_ARCH_PACKAGES=' .config | cut -d '"' -f 2)
echo "检测到架构包: $ARCH_PACKAGES"
 
# 禁用签名检查 
sed -i 's/^option check_signature/# option check_signature/' repositories.conf  
 
# 添加源
echo "src/gz kiddin9_packages https://dl.openwrt.ai/releases/24.10/packages/$ARCH_PACKAGES/kiddin9"  >> repositories.conf  

# echo "src/gz openwrt_kenzok8_package https://op.dllkids.xyz/packages/$ARCH_PACKAGES"  >> repositories.conf  
 
# 添加 archive.openwrt.org  22.03 源 
# echo "src/gz openwrt_archive_base https://archive.openwrt.org/releases/packages-22.03/$ARCH_PACKAGES/base"  >> repositories.conf  
# echo "src/gz openwrt_archive_packages https://archive.openwrt.org/releases/packages-22.03/$ARCH_PACKAGES/packages"  >> repositories.conf  
# echo "src/gz openwrt_archive_luci https://archive.openwrt.org/releases/packages-22.03/$ARCH_PACKAGES/luci"  >> repositories.conf  
 
echo "当前软件源配置："
cat repositories.conf  

echo "解决 simple-obfs 冲突..."
if grep -q "CONFIG_PACKAGE_luci-app-passwall=y" .config; then 
    echo "检测到 Passwall，强制使用 simple-obfs-client"
    sed -i '/^CONFIG_PACKAGE_simple-obfs/d' .config
    echo "CONFIG_PACKAGE_simple-obfs-client=y" >> .config 
    
    # 确保相关依赖被选中 
    echo "CONFIG_PACKAGE_iptables-mod-tproxy=y" >> .config
    echo "CONFIG_PACKAGE_libopenssl=y" >> .config 
fi
 
# 解决默认设置冲突 
echo "CONFIG_PACKAGE_default-settings-chn=y" >> .config 
echo "CONFIG_PACKAGE_luci-lua-runtime=n" >> .config  # 显式禁用包

echo "当前配置修改："
grep -E "default-settings" .config 