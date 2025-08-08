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

echo '
define KernelPackage/xdp-sockets-diag
  SUBMENU:=$(NETWORK_SUPPORT_MENU)
  TITLE:=PF_XDP sockets monitoring interface support for ss utility
  KCONFIG:= \
	CONFIG_XDP_SOCKETS=y \
	CONFIG_XDP_SOCKETS_DIAG
  FILES:=$(LINUX_DIR)/net/xdp/xsk_diag.ko
  AUTOLOAD:=$(call AutoLoad,31,xsk_diag)
endef

define KernelPackage/xdp-sockets-diag/description
 Support for PF_XDP sockets monitoring interface used by the ss tool
endef

$(eval $(call KernelPackage,xdp-sockets-diag))
' >> package/kernel/linux/modules/netsupport.mk

echo 'CONFIG_PACKAGE_kmod-xdp-sockets-diag=y' >> .config

# 解决默认设置冲突 
echo "CONFIG_PACKAGE_default-settings-chn=y" >> .config 
echo "CONFIG_PACKAGE_luci-lua-runtime=n" >> .config  # 显式禁用包

echo "当前配置修改："
grep -E "default-settings" .config 