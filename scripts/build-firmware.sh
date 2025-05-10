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
# echo "复制files目录到ImageBuilder..."
# cp -rf files "$builder_dir/" || { echo "错误：files目录复制失败"; exit 1; }
 
# 进入编译目录 
# cd "$builder_dir" || exit 1 

mkdir -p files/etc/uci-defaults

cat << "EOF" > files/etc/uci-defaults/99-custom
# 使用 Argon 主题 
uci set luci.main.mediaurlbase='/luci-static/argon' 

# 禁用 IPv6 向导 
uci set wizard.default.ipv6='0' 

# Radio0 设置 (5GHz)
uci set wireless.radio0.mu_beamformer='1' 
uci set wireless.radio0.country='US' 
uci set wireless.radio0.htmode='HE160' 
uci set wireless.radio0.channel='149' 
uci set wireless.default_radio0.ieee80211r='1'   # 802.11r 快速漫游
 
# Radio1 设置 (2.4GHz)
uci set wireless.radio1.mu_beamformer='1' 
uci set wireless.radio1.country='US' 
uci set wireless.default_radio1.ieee80211r='1'   # 802.11r 快速漫游

# UPnP 服务启用
uci set upnpd.config.enabled='1' 
 
# 主机名设置
uci set system.@system[0].hostname='QWRT'

# 节点配置 (Socks5 代理)
uci set passwall2.AVVjwzzU=nodes
uci set passwall2.AVVjwzzU.remarks=' 自动切换'
uci set passwall2.AVVjwzzU.type='Socks' 
uci set passwall2.AVVjwzzU.address='127.0.0.1' 
uci set passwall2.AVVjwzzU.port='1081' 
 
# 全局代理设置
uci set passwall2.@global[0].tcp_node='AVVjwzzU'
 
# 本地 Socks5 服务端配置 
uci set passwall2.oFIfqfES=socks
uci set passwall2.oFIfqfES.enabled='1' 
uci set passwall2.oFIfqfES.port='1081' 
uci set passwall2.oFIfqfES.http_port='0' 
uci set passwall2.oFIfqfES.enable_autoswitch='1' 

uci commit
EOF

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