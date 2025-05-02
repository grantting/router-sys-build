#!/bin/bash 
set -euo pipefail 
 
model_id=$1 
pkg_list=$2  # 接收完整的包列表字符串（包含排除项）
 
echo "=== 开始编译固件 ===" 
cd immortalwrt-imagebuilder-* || { echo "错误：找不到ImageBuilder目录"; exit 1; }
 
# 初始化环境 
mkdir -p dl 
echo "当前工作目录: $(pwd)"
echo "原始包列表: $pkg_list"
 
# 分离出需要删除的IPK文件（用于可视化日志）
excluded_pkgs=$(echo "$pkg_list" | grep -o -- '-[^ ]*' | sed 's/-//g')
if [ -n "$excluded_pkgs" ]; then 
    echo "正在清理以下包的缓存文件: $excluded_pkgs"
    find dl -name "*.ipk" | while read file; do 
        for pkg in $excluded_pkgs; do 
            if [[ "$file" == *"$pkg"* ]]; then 
                echo "删除冲突文件: $file"
                rm -f "$file"
            fi 
        done 
    done 
fi 
 
# 清理构建缓存 
echo "清理构建缓存..."
rm -rf tmp 
 
# 开始编译（直接将完整包列表传入） 
echo "=== 执行编译命令 ===" 
echo "make image PROFILE=\"$model_id\" PACKAGES=\"$pkg_list\""
 
make image \
    PROFILE="$model_id" \
    PACKAGES="$pkg_list" \
    FILES=files/ \
    DISABLED_SERVICES="" \
    -j$(nproc)
 
echo "=== 固件编译完成 ===" 