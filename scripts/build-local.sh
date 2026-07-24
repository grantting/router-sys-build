#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

show_help() {
    cat << 'EOF'
用法: ./scripts/build-local.sh [选项]

选项:
  --version VERSION       ImmortalWrt 版本号 (默认: 24.10.3)
  --model MODEL_ID        设备型号 ID (默认: redmi_ax6-stock)
                          支持: redmi_ax6-stock, qihoo_360t7, xiaomi_mi-router-3g
  --packages "PACKAGES"   软件包列表，用引号包裹 (默认: 见 workflow)
  --rootfs-size SIZE      RootFS 分区大小 MB (默认: 300)
  --wifi-ssid SSID        WiFi 名称前缀 (默认: 康达姆机器人)
  --wifi-password PASS    WiFi 密码 (默认: 123*567890)
  --help                  显示此帮助

环境变量也可用: VERSION, MODEL_ID, PACKAGES, ROOTFS_SIZE, WIFI_SSID, WIFI_PASSWORD

示例:
  ./scripts/build-local.sh --version 24.10.3 --model redmi_ax6-stock
  ./scripts/build-local.sh --wifi-ssid MyWiFi --wifi-password MyPass123
  VERSION=24.10.0 MODEL_ID=qihoo_360t7 ./scripts/build-local.sh
EOF
}

VERSION="${VERSION:-24.10.3}"

# 判断包管理器：25.x+ 使用 APK，之前使用 opkg
VERSION_MAJOR=$(echo "$VERSION" | cut -d. -f1)
if [ "$VERSION_MAJOR" -ge 25 ] 2>/dev/null; then
    # APK 版本：opkg 不可用，kiddin9 源不兼容
    DEFAULT_PACKAGES="luci-app-passwall luci-i18n-package-manager-zh-cn luci-i18n-firewall-zh-cn kmod-fs-ext4 kmod-usb-dwc3 kmod-usb3 kmod-tcp-bbr swconfig kmod-nft-tproxy kmod-nft-socket luci-app-vlmcsd luci-app-diskman luci-app-upnp luci-theme-argon luci-i18n-base-zh-cn"
else
    # opkg 版本
    DEFAULT_PACKAGES="luci-app-quickstart luci-app-passwall luci-i18n-package-manager-zh-cn luci-i18n-firewall-zh-cn luci-app-advancedplus kmod-fs-ext4 kmod-usb-dwc3 kmod-usb3 kmod-tcp-bbr swconfig kmod-nft-tproxy kmod-nft-socket opkg luci-app-vlmcsd luci-app-diskman luci-app-upnp luci-app-timedreboot luci-app-taskplan luci-theme-argon luci-app-wizard luci-i18n-base-zh-cn"
fi
MODEL_ID="${MODEL_ID:-redmi_ax6-stock}"
PACKAGES="${PACKAGES:-$DEFAULT_PACKAGES}"
ROOTFS_SIZE="${ROOTFS_SIZE:-120}"
WIFI_SSID="${WIFI_SSID:-康达姆机器人}"
WIFI_PASSWORD="${WIFI_PASSWORD:-123*567890}"

while [ $# -gt 0 ]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --model) MODEL_ID="$2"; shift 2 ;;
        --packages) PACKAGES="$2"; shift 2 ;;
        --rootfs-size) ROOTFS_SIZE="$2"; shift 2 ;;
        --wifi-ssid) WIFI_SSID="$2"; shift 2 ;;
        --wifi-password) WIFI_PASSWORD="$2"; shift 2 ;;
        --help) show_help; exit 0 ;;
        *) echo "未知选项: $1"; show_help; exit 1 ;;
    esac
done

echo "=========================================="
echo "  本地编译 ImmortalWrt 固件"
echo "=========================================="
echo "版本:         $VERSION"
echo "机型:         $MODEL_ID"
echo "RootFS大小:   ${ROOTFS_SIZE}MB"
echo "WiFi SSID:    $WIFI_SSID"
echo "WiFi 密码:    $WIFI_PASSWORD"
echo "=========================================="

# 检查必要命令
for cmd in curl jq wget tar python3 make gcc; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "缺少必要命令: $cmd，请先运行 scripts/install-deps.sh"
        exit 1
    fi
done

# Step 1: 获取目标平台信息
echo ""
echo "=== Step 1/6: 获取目标平台信息 ==="
source scripts/get-platform.sh "$VERSION" "$MODEL_ID"
TARGET_SLASH="$TARGET_PLATFORM_SLASH"
TARGET_HYPHEN="$TARGET_PLATFORM_HYPHEN"
echo "平台: $TARGET_SLASH"

# Step 2: 下载并解压 ImageBuilder
echo ""
echo "=== Step 2/6: 下载并解压 ImageBuilder ==="
bash scripts/download-extract.sh "$VERSION" "$TARGET_SLASH" "$TARGET_HYPHEN"

# Step 3: 配置软件源
echo ""
echo "=== Step 3/6: 配置软件源 ==="
bash scripts/config-repos.sh

# Step 4: 应用自定义 WiFi 配置
echo ""
echo "=== Step 4/6: 应用自定义 WiFi 配置 ==="
python3 << 'PYEOF'
import os, sys
ssid = os.environ.get('WIFI_SSID', '康达姆机器人')
password = os.environ.get('WIFI_PASSWORD', '123*567890')
filepath = 'files/etc/uci-defaults/99-custom'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('康达姆机器人', ssid)
content = content.replace('123*567890', password)
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"WiFi SSID 已替换为: {ssid}")
print(f"WiFi 密码已替换为: {password}")
PYEOF

# Step 5: 生成系统配置文件并复制到 ImageBuilder
echo ""
echo "=== Step 5/6: 生成配置文件并复制到 ImageBuilder ==="
bash scripts/files-general.sh

# 安全地找到 imagebuilder 目录
shopt -s nullglob
BUILDER_DIRS=(immortalwrt-imagebuilder-*)
shopt -u nullglob

if [ ${#BUILDER_DIRS[@]} -eq 0 ]; then
    echo "错误: 未找到 immortalwrt-imagebuilder-* 目录"
    exit 1
fi
BUILDER_DIR="${BUILDER_DIRS[0]}"

echo "复制 files/ 到 ImageBuilder..."
cp -r files "$BUILDER_DIR"

# Step 6: 编译固件
echo ""
echo "=== Step 6/6: 编译固件 ==="
cd "$BUILDER_DIR" || exit 1

echo "开始编译 (使用 $(nproc) 线程)..."
make image \
    PROFILE="$MODEL_ID" \
    PACKAGES="$PACKAGES" \
    FILES="files" \
    ROOTFS_PARTSIZE="$ROOTFS_SIZE" \
    -j$(nproc)

# 验证编译产物
cd "$PROJECT_DIR"
echo ""
echo "=========================================="
echo "  编译完成"
echo "=========================================="
FIRMWARE_DIR="$BUILDER_DIR/bin/targets/$TARGET_SLASH"
if ls $FIRMWARE_DIR/*.bin 1>/dev/null 2>&1; then
    ls -lh $FIRMWARE_DIR/*.bin
elif ls $FIRMWARE_DIR/*.ubi 1>/dev/null 2>&1; then
    ls -lh $FIRMWARE_DIR/*.ubi
elif ls $FIRMWARE_DIR/*.img 1>/dev/null 2>&1; then
    ls -lh $FIRMWARE_DIR/*.img
else
    echo "警告: 未找到固件文件，请检查 $FIRMWARE_DIR"
fi
echo "=========================================="