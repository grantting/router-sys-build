#!/bin/bash 
set -e 

echo "正在配置软件源..."

# 安全地找到 imagebuilder 目录
shopt -s nullglob
BUILDER_DIR=(immortalwrt-imagebuilder-*)
shopt -u nullglob

if [ ${#BUILDER_DIR[@]} -eq 0 ]; then
    echo "错误: 未找到 immortalwrt-imagebuilder-* 目录，请先运行 download-extract.sh"
    exit 1
fi

cd "${BUILDER_DIR[0]}" || exit 1

if [ ! -f .config ]; then
    echo "错误: .config 文件不存在于 $(pwd)"
    exit 1
fi

ARCH_PACKAGES=$(grep 'CONFIG_TARGET_ARCH_PACKAGES=' .config | cut -d '"' -f 2)
echo "检测到架构包: $ARCH_PACKAGES"

# 从目录名提取版本号（例如 immortalwrt-imagebuilder-25.12.0-... -> 25.12.0）
BUILDER_VERSION=$(echo "${BUILDER_DIR[0]}" | sed 's/immortalwrt-imagebuilder-\([0-9.]*\)-.*/\1/')
echo "检测到 ImageBuilder 版本: $BUILDER_VERSION"
 
# 禁用签名检查（如果 repositories.conf 存在）
if [ -f repositories.conf ]; then
    sed -i 's/^option check_signature/# option check_signature/' repositories.conf  
else
    echo "警告: repositories.conf 不存在，正在创建..."
    cat > repositories.conf << 'EOF'
src/gz openwrt_core
src/gz openwrt_base
src/gz openwrt_packages
src/gz openwrt_luci
src/gz openwrt_routing
src/gz openwrt_telephony
EOF
fi
 
# 添加 kiddin9 源（使用动态版本号）
KIDDIN9_VERSION=$(echo "$BUILDER_VERSION" | sed 's/\.[0-9]*$//')
echo "src/gz kiddin9_packages https://dl.openwrt.ai/releases/$KIDDIN9_VERSION/packages/$ARCH_PACKAGES/kiddin9" >> repositories.conf  

echo "当前软件源配置："
cat repositories.conf  

# 解决默认设置冲突 
echo "CONFIG_PACKAGE_default-settings-chn=y" >> .config 
echo "CONFIG_PACKAGE_luci-lua-runtime=n" >> .config  # 显式禁用包

echo "当前配置修改："
grep -E "default-settings" .config
