#!/bin/bash 

set -e 

echo "正在配置软件源..."
mkdir -p files

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

BUILDER_VERSION=$(echo "${BUILDER_DIR[0]}" | sed 's/immortalwrt-imagebuilder-\([0-9.]*\)-.*/\1/')
echo "检测到 ImageBuilder 版本: $BUILDER_VERSION"

BUILDER_MAJOR=$(echo "$BUILDER_VERSION" | cut -d. -f1)
if [ "$BUILDER_MAJOR" -ge 25 ] 2>/dev/null; then
    echo "注意: ImmortalWrt $BUILDER_VERSION 使用 APK 包管理器，跳过 opkg 配置"
else
    KIDDIN9_VERSION=$(echo "$BUILDER_VERSION" | sed 's/\.[0-9]*$//')
    echo "kiddin9 源版本: $KIDDIN9_VERSION"

    mkdir -p files/etc/opkg
    touch files/etc/opkg/customfeeds.conf

    echo "src/gz kiddin9_packages https://dl.openwrt.ai/releases/$KIDDIN9_VERSION/packages/$ARCH_PACKAGES/kiddin9" >> files/etc/opkg/customfeeds.conf

    touch files/etc/opkg.conf

    echo "dest root /" >> files/etc/opkg.conf
    echo "dest ram /tmp" >> files/etc/opkg.conf
    echo "lists_dir ext /var/opkg-lists" >> files/etc/opkg.conf
    echo "option overlay_root /overlay" >> files/etc/opkg.conf
fi
