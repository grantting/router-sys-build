#!/bin/sh 
 
# Create directory structure 
mkdir -p files/etc/uci-defaults 
 
# Generate custom configuration 
cat << "EOF" > files/etc/uci-defaults/99-custom 
#!/bin/sh 
 
# Network settings 
set network.lan.ipaddr='10.0.0.1' 
commit network 
 
# LUCI theme settings 
set luci.main.mediaurlbase='/luci-static/argon' 
commit luci 
 
# Disable IPv6 in setup wizard 
set wizard.default.ipv6='0' 
commit wizard 
 
# Wireless settings 
set wireless.radio0.mu_beamformer='1' 
set wireless.radio1.mu_beamformer='1' 
 
set wireless.radio0.country='US' 
set wireless.radio1.country='US' 
 
set wireless.radio0.htmode='HE160' 
 
set wireless.default_radio0.ieee80211r='1' 
set wireless.default_radio1.ieee80211r='1' 
 
set wireless.radio0.channel='149' 
commit wireless 
 
# UPnP settings 
set upnpd.config.enabled='1' 
commit upnpd 
 
# System settings 
set system.@system[0].hostname='OpenWRT'
commit system 
 
# Passwall settings 
set passwall.@nodes[0]='AVVjwzzU'
set passwall.@nodes[0].remarks='自动切换'
set passwall.@nodes[0].type='Socks'
set passwall.@nodes[0].address='127.0.0.1'
set passwall.@nodes[0].port='1081'
 
# Passwall 全局设置（引用节点）
set passwall.@global[0].tcp_node='AVVjwzzU'
 
# Passwall SOCKS 代理配置（改用标准 @socks[0] 格式）
set passwall.@socks[0]='oFIfqfES'
set passwall.@socks[0].enabled='1'
set passwall.@socks[0].port='1081'
set passwall.@socks[0].http_port='0'
set passwall.@socks[0].enable_autoswitch='1'
commit passwall 
 
exit 0 
EOF 
 
# Set execute permission for the script 
chmod 0755 files/etc/uci-defaults/99-custom 
 
# Change root password 
root_password="root"
if [ -n "$root_password" ]; then 
  echo "Changing root password..."
  (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null 2>&1 
  if [ $? -eq 0 ]; then 
    echo "Root password changed successfully."
  else 
    echo "Failed to change root password." >&2 
    exit 1 
  fi 
fi 
 
echo "All configurations applied successfully!"
exit 0 