#!/bin/sh

# Ask for new SSID for 2.4 GHz Wi-Fi
echo -ne "\033[32mEnter new SSID for 2.4 GHz Wi-Fi (default_radio0): \033[0m"
read SSID_2G

# Generate SSID for 5 GHz
SSID_5G="${SSID_2G}_5G"

# Apply new SSIDs
uci set wireless.default_radio0.ssid="$SSID_2G"
uci set wireless.default_radio1.ssid="$SSID_5G"

# Update system description
uci set system.@system[0].description="$SSID_2G"

# Generate new MAC address (locally administered)
RANDMAC=$(hexdump -n5 -e '/1 ":%02X"' /dev/urandom)
NEW_MAC="e8${RANDMAC}"

# Set new MAC address for WAN
uci set network.@device[1].macaddr="$NEW_MAC"

# Commit changes
uci commit wireless
uci commit system
uci commit network

# Apply settings
wifi reload
/etc/init.d/system reload
/etc/init.d/network restart

# Confirmation
echo -e "\033[32mSSIDs and system description updated:\033[0m"
echo "2.4 GHz -> $SSID_2G"
echo "5 GHz   -> $SSID_5G"
echo "System description set to: $SSID_2G"
echo -e "\033[32mNew MAC address for WAN: $NEW_MAC\033[0m"

# Restart podkop service
echo -e "\033[34mRestarting podkop service...\033[0m"
/etc/init.d/podkop restart

# Wait before DNS check
echo -e "\033[34mWaiting 15 seconds for podkop to initialize...\033[0m"
sleep 15

# Check podkop functionality
echo -e "\033[34mPerforming DNS check to verify podkop status...\033[0m"
TEST_DOMAIN=$(grep 'TEST_DOMAIN=' /usr/bin/podkop | cut -d'"' -f2)

if [ -z "$TEST_DOMAIN" ]; then
  echo -e "\033[31mError: Failed to extract TEST_DOMAIN from /usr/bin/podkop\033[0m"
else
  NSLOOKUP_OUTPUT=$(nslookup -timeout=2 "$TEST_DOMAIN" 127.0.0.42 2>&1)
  if echo "$NSLOOKUP_OUTPUT" | grep -q "Address:.*198\.18\."; then
    echo -e "\033[32mPodkop is working: $TEST_DOMAIN resolved to 198.18.x.x\033[0m"
  else
    echo -e "\033[31mPodkop is NOT working: $TEST_DOMAIN did not resolve to 198.18.x.x\033[0m"
  fi
fi
