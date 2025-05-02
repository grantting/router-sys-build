#!/bin/bash 
set -e 
 
version=$1 
target_slash=$2 
target_hyphen=$3 
 
echo "正在下载ImageBuilder..."
URL="https://immortalwrt.kyarucloud.moe/releases/$version/targets/$target_slash/immortalwrt-imagebuilder-$version-$target_hyphen.Linux-x86_64.tar.zst" 
echo "下载地址: $URL"
 
if ! wget "$URL" -O imagebuilder.tar.zst;  then 
    echo "下载ImageBuilder失败"
    exit 1 
fi 
 
echo "正在解压ImageBuilder..."
if ! tar -I zstd -xf imagebuilder.tar.zst;  then 
    echo "解压ImageBuilder失败"
    exit 1 
fi 
 
rm -f imagebuilder.tar.zst  
echo "ImageBuilder解压完成"
ls -l immortalwrt-imagebuilder-*/