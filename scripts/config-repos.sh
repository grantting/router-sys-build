#!/bin/bash 
set -e 

echo "正在配置软件源..."

# 安全地找到 imagebuilder 目录
shopt -s nullglob
BUILDER_DIRS=(immortalwrt-imagebuilder-*)
shopt -u nullglob

if [ ${#BUILDER_DIRS[@]} -eq 0 ]; then
    echo "错误: 未找到 immortalwrt-imagebuilder-* 目录，请先运行 download-extract.sh"
    exit 1
fi
BUILDER_DIR="${BUILDER_DIRS[0]}"

cd "$BUILDER_DIR" || exit 1

if [ ! -f .config ]; then
    echo "错误: .config 文件不存在于 $(pwd)"
    exit 1
fi

ARCH_PACKAGES=$(grep 'CONFIG_TARGET_ARCH_PACKAGES=' .config | cut -d '"' -f 2)
echo "检测到架构包: $ARCH_PACKAGES"

# 从目录名提取信息（例如 immortalwrt-imagebuilder-25.12.1-ipq807x-generic）
# 版本号: 25.12.1
BUILDER_VERSION=$(echo "$BUILDER_DIR" | sed 's/^immortalwrt-imagebuilder-\([0-9.]*\)-.*/\1/')
# 目标板: ipq807x
BUILDER_BOARD=$(echo "$BUILDER_DIR" | sed 's/^immortalwrt-imagebuilder-[0-9.]*-\([a-z0-9]*\)-.*/\1/')
# 子目标: generic
BUILDER_SUBTARGET=$(echo "$BUILDER_DIR" | sed 's/^immortalwrt-imagebuilder-[0-9.]*-[a-z0-9]*-//')
echo "检测到 ImageBuilder 版本: $BUILDER_VERSION, 目标: $BUILDER_BOARD/$BUILDER_SUBTARGET"
 
RELEASE_URL="https://downloads.immortalwrt.org/releases/$BUILDER_VERSION"
PACKAGES_URL="$RELEASE_URL/packages/$ARCH_PACKAGES"

if [ -f repositories.conf ]; then
    sed -i 's/^option check_signature/# option check_signature/' repositories.conf
else
    echo "警告: repositories.conf 不存在，正在生成..."
    cat > repositories.conf << EOF
src/gz openwrt_core $RELEASE_URL/targets/$BUILDER_BOARD/$BUILDER_SUBTARGET/packages
src/gz openwrt_base $PACKAGES_URL/base
src/gz openwrt_packages $PACKAGES_URL/packages
src/gz openwrt_luci $PACKAGES_URL/luci
src/gz openwrt_routing $PACKAGES_URL/routing
src/gz openwrt_telephony $PACKAGES_URL/telephony
option check_signature
EOF
fi
 
# 检查版本：25.x+ 使用 APK 包管理器，kiddin9 源仅提供 .ipk 包，不兼容
BUILDER_MAJOR=$(echo "$BUILDER_VERSION" | cut -d. -f1)
if [ "$BUILDER_MAJOR" -ge 25 ] 2>/dev/null; then
    echo "注意: ImmortalWrt $BUILDER_VERSION 使用 APK 包管理器"
    echo "kiddin9 源 (dl.openwrt.ai) 仅提供 .ipk 包，与 APK 不兼容，已跳过"
    echo "如需第三方包，请使用 APK 兼容的源"
else
    KIDDIN9_VERSION=$(echo "$BUILDER_VERSION" | sed 's/\.[0-9]*$//')
    echo "src/gz kiddin9_packages https://dl.openwrt.ai/releases/$KIDDIN9_VERSION/packages/$ARCH_PACKAGES/kiddin9" >> repositories.conf
fi

echo "当前软件源配置："
cat repositories.conf  

# 解决默认设置冲突 
echo "CONFIG_PACKAGE_default-settings-chn=y" >> .config 
echo "CONFIG_PACKAGE_luci-lua-runtime=n" >> .config

echo "当前配置修改："
grep -E "default-settings" .config
