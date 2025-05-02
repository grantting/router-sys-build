#!/bin/bash 
set -e 
 
version=$1 
model_id=$2 
 
echo "正在获取目标平台信息..."
JSON_URL="https://immortalwrt.kyarucloud.moe/releases/$version/.overview.json" 
echo "从以下地址获取JSON: $JSON_URL"
 
if ! curl -sL "$JSON_URL" -o overview.json;  then 
    echo "下载overview.json 失败"
    exit 1 
fi 
 
TARGET=$(jq -r --arg model "$model_id" '
    .profiles[] | select(.id == $model) | .target 
' overview.json) 
 
if [ -z "$TARGET" ]; then 
    echo "错误：未找到机型 $model_id"
    exit 1 
fi 
 
echo "target_platform_slash=$TARGET" >> $GITHUB_OUTPUT 
FORMATTED_TARGET=$(echo $TARGET | tr '/' '-')
echo "target_platform_hyphen=$FORMATTED_TARGET" >> $GITHUB_OUTPUT 
echo "获取平台信息成功: $TARGET"