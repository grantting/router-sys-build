#!/bin/bash 
set -euo pipefail 
 
input_pkgs=${1:-""}
 
echo "正在处理软件包列表..."
# 初始化数组 
INCLUDED=()
EXCLUDED=()
 
# 安全分割输入参数 
IFS=' ' read -ra PKG_ARRAY <<< "${input_pkgs}"
 
for pkg in "${PKG_ARRAY[@]}"; do 
    case "$pkg" in 
        -pkg*)
            EXCLUDED+=("${pkg#-pkg}")
            ;;
        -*)
            EXCLUDED+=("${pkg#-}")
            ;;
        *)
            INCLUDED+=("$pkg")
            ;;
    esac 
done 
 
# 验证输出 
echo "有效输入参数: ${input_pkgs}"
echo "最终包含的包: ${INCLUDED[*]}"
echo "实际排除的包: ${EXCLUDED[*]}"
 
# 格式化输出 
{
    echo "packages_included=${INCLUDED[*]@Q}";
    echo "packages_excluded=${EXCLUDED[*]@Q}";
} >> "${GITHUB_OUTPUT}" 
