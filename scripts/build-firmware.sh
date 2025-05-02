#!/bin/bash 
set -e 
 
model_id=$1 
included_pkgs=$2 
excluded_pkgs=$3 
 
echo "开始编译固件..."
cd immortalwrt-imagebuilder-* || exit 1 
 
# 清理排除的包 
if [ -n "$excluded_pkgs" ]; then 
    for pkg in $excluded_pkgs; do 
        find dl/ -name "*${pkg}*.ipk" -delete 
        echo "已排除包: $pkg"
    done 
fi 
 
# 清理构建缓存 
rm -rf tmp/
echo "已清理构建缓存"
 
echo "正在编译..."
make image \
    PROFILE="$model_id" \
    PACKAGES="$included_pkgs" \
    FILES=files/ \
    DISABLED_SERVICES="" \
    -j$(nproc)
 
echo "固件编译完成"