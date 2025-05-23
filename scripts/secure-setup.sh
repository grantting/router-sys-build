#!/bin/sh 
 
# 创建文件夹和文件 
mkdir -p /files/etc/uci-defaults 
cat > /files/etc/uci-defaults/99-custom << 'EOF'
#!/bin/bash 
 
# Apply configuration changes using UCI 
uci batch <<- 'UCI_EOF'
set network.lan.ipaddr='10.0.0.1' 
set luci.main.mediaurlbase='/luci-static/argon' 
set wizard.default.ipv6='0' 
set wireless.radio0.mu_beamformer='1' 
set wireless.radio1.mu_beamformer='1' 
set wireless.radio0.country='US' 
set wireless.radio1.country='US' 
set wireless.radio0.htmode='HE160' 
set wireless.default_radio0.ieee80211r='1' 
set wireless.default_radio1.ieee80211r='1' 
set wireless.radio0.channel='149' 
set upnpd.config.enabled='1' 
set system.@system[0].hostname='DWRT'
add passwall2 nodes 
set passwall2.@nodes[-1]='AVVjwzzU'
set passwall2.@nodes[-1].remarks='自动切换'
set passwall2.@nodes[-1].type='Socks'
set passwall2.@nodes[-1].address='127.0.0.1'
set passwall2.@nodes[-1].port='1081'
set passwall2.@global[0].tcp_node='AVVjwzzU'
add passwall2 socks 
set passwall2.@socks[-1].enabled='1'
set passwall2.@socks[-1].port='1081'
UCI_EOF 
 
# Commit changes 
uci commit 
 
# Change root password 
root_password="root"
if [ -n "$root_password" ]; then 
(echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null 
fi 
 
echo "All configurations applied successfully!"
EOF 
 
# 设置文件可执行权限 
chmod +x /files/etc/uci-defaults/99-custom 