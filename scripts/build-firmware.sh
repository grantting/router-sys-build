#!/bin/bash 
set -euo pipefail 
 
model_id=$1 
pkg_list=$2  # 直接使用传入的完整包列表（包含排除项）


echo "当前工作目录: $(pwd)"
echo "目录内容:"
ls -l
 

echo "=== 开始编译固件 ===" 
cd immortalwrt-imagebuilder-* || { 
    echo "错误：找不到ImageBuilder目录" 
    exit 1 
} 
 
echo "当前设备: $model_id"
echo "使用包列表: $pkg_list"
 
 # 调试：确认进入后的目录
echo "当前编译目录: $(pwd)"
echo "编译前目录内容:"
ls -l

# 直接编译（保留原有排除语法）
echo "=== 执行编译命令 ===" 
make image \
    PROFILE="$model_id" \
    PACKAGES="$pkg_list" \
    FILES="files" \
    -j$(nproc)
 
echo "=== 固件编译完成 ===" 