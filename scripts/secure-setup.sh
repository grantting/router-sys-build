#!/bin/sh 
set -e 
 
# Create directory structure 
mkdir -p files/etc/uci-defaults
 
# Generate custom configuration 
cat << "EOF" > files/etc/uci-defaults/99-custom

#!/bin/sh 
 
# Network settings 
uci set network.lan.ipaddr='10.0.0.1' 
uci commit network 
 
# LUCI theme settings 
uci set luci.main.mediaurlbase='/luci-static/argon' 
uci commit luci 
 
# Wireless settings 
uci set wireless.radio0.mu_beamformer='1' 
uci set wireless.radio1.mu_beamformer='1' 
uci set wireless.radio0.country='US' 
uci set wireless.radio1.country='US' 
uci set wireless.radio0.htmode='HE160' 
uci set wireless.default_radio0.ieee80211r='1' 
uci set wireless.default_radio1.ieee80211r='1' 
uci set wireless.radio0.channel='149' 
uci commit wireless 
 
# UPnP settings 
uci set upnpd.config.enabled='1' 
uci commit upnpd 
 
# System settings 
uci set system.@system[0].hostname='OpenWRT'
uci commit system 
 
# Passwall settings 
uci add passwall nodes 
uci set passwall.@nodes[-1]='AVVjwzzU'
uci set passwall.@nodes[-1].remarks='自动切换'
uci set passwall.@nodes[-1].type='Socks'
uci set passwall.@nodes[-1].address='127.0.0.1'
uci set passwall.@nodes[-1].port='1081'
uci set passwall.@global[0].tcp_node='AVVjwzzU'
uci add passwall socks 
uci set passwall.@socks[-1].enabled='1'
uci set passwall.@socks[-1].port='1081'
uci commit passwall 
 
exit 0
EOF

# Set execute permission 
chmod 0755 files/etc/uci-defaults/99-custom 
 
# Change root password securely 
root_password="root" 
if [ -n "$root_password" ]; then 
  echo "Changing root password..."
  if ! (echo "$root_password"; sleep 1; echo "$root_password") | passwd root >/dev/null 2>&1; then 
    echo "Failed to change root password." >&2 
    exit 1 
  fi 
  echo "Root password changed successfully."
fi 
 
echo "Configuration completed"
exit 0 