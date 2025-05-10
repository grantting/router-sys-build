#!/bin/bash 
set -euo pipefail 
 
model_id=$1 
pkg_list=$2 
 
echo "=== 开始编译流程 ===" 
echo "目标设备: $model_id"
echo "软件包列表: $pkg_list"
 
# 定位ImageBuilder目录 
builder_dir=$(find . -maxdepth 1 -type d -name "immortalwrt-imagebuilder-*" | head -n 1)
[ -z "$builder_dir" ] && { echo "错误：未找到ImageBuilder目录"; exit 1; }
 
# 直接复制files目录 
echo "复制files目录到ImageBuilder..."
cp -rf files "$builder_dir/" || { echo "错误：files目录复制失败"; exit 1; }
 
# 进入编译目录 
cd "$builder_dir" || exit 1 

echo "当前工作目录: $(pwd)"
echo "目录内容:"
ls -l

# 检查files目录是否存在并递归列出内容 
if [ -d "files" ]; then 
    echo -e "\nfiles目录内容(递归):"
    find files -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
else 
    echo -e "\n警告：files目录不存在"
fi 

# 执行编译 
echo -e "\n=== 正在编译 (使用$(( $(nproc) + 1 ))线程) ===" 
time make image \
    PROFILE="$model_id" \
    PACKAGES="$pkg_list" \
    FILES="files" \
    -j$(( $(nproc) + 1 )) 
 
# 结果处理 
[ $? -eq 0 ] && {
    echo -e "\n=== 编译成功 ===" 
    find bin/targets -type f \( -name "*.img" -o -name "*.bin" \) -exec ls -lh {} \;
} || {
    echo -e "\n=== 编译失败 ===" 
    exit 1
}