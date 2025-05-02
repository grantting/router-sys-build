#!/bin/bash 
set -e 
 
input_pkgs=$1 
 
echo "正在处理软件包列表..."
# 分割输入参数 
IFS=' ' read -ra PKG_ARRAY <<< "$input_pkgs"
 
# 分离包含和排除的包 
INCLUDED=()
EXCLUDED=()
 
for pkg in "${PKG_ARRAY[@]}"; do 
    if [[ $pkg == -pkg* ]]; then 
        EXCLUDED+=("${pkg#-pkg}")
    else 
        INCLUDED+=("$pkg")
    fi 
done 
 
# 合并为字符串 
INCLUDED_STR=$(IFS=' '; echo "${INCLUDED[*]}")
EXCLUDED_STR=$(IFS=' '; echo "${EXCLUDED[*]}")
 
echo "最终包含的包: $INCLUDED_STR"
echo "排除的包: $EXCLUDED_STR"
 
# 输出到环境变量 
echo "packages_included=$INCLUDED_STR" >> $GITHUB_OUTPUT 
echo "packages_excluded=$EXCLUDED_STR" >> $GITHUB_OUTPUT 