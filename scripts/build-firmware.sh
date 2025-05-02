#!/bin/bash 
set -euo pipefail 
 
model_id=$1 
included_pkgs=$2 
excluded_pkgs=$3 
 
echo "=== 开始编译固件 ===" 
cd immortalwrt-imagebuilder-* || { echo "错误：找不到ImageBuilder目录"; exit 1; }
 
# 初始化环境 
mkdir -p dl 
echo "当前目录: $(pwd)"
echo "目录内容:"
ls -l 
 
# 处理排除包（安全方式）
if [ -n "$excluded_pkgs" ]; then 
    echo "正在排除以下包: $excluded_pkgs"
    find dl -name "*.ipk" | while read file; do 
        for pkg in $excluded_pkgs; do 
            if [[ "$file" == *"$pkg"* ]]; then 
                echo "删除冲突文件: $file"
                rm -f "$file"
            fi 
        done 
    done 
fi 
 
# 清理缓存 
echo "清理构建缓存..."
rm -rf tmp 
 
# 开始编译 
echo "=== 编译参数 ===" 
echo "设备: $model_id"
echo "包含包: $included_pkgs"
echo "排除包: $excluded_pkgs"
 
make image \
    PROFILE="$model_id" \
    PACKAGES="$included_pkgs" \
    FILES=files/ \
    DISABLED_SERVICES="" \
    -j$(nproc)
 
echo "=== 固件编译完成 ===" 