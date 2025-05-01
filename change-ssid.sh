#!/bin/sh

# Ask user for new SSID for 2.4 GHz Wi-Fi in green
echo -ne "\033[32mEnter new SSID for 2.4 GHz Wi-Fi (default_radio0): \033[0m"
read SSID_2G

# Generate SSID for 5 GHz by appending _5G
SSID_5G="${SSID_2G}_5G"

# Set the new SSIDs
uci set wireless.default_radio0.ssid="$SSID_2G"
uci set wireless.default_radio1.ssid="$SSID_5G"

# Set the new description to match the 2.4 GHz SSID
uci set system.@system[0].description="$SSID_2G"

# Save the changes to the config
uci commit wireless
uci commit system

# Reload Wi-Fi to apply changes first
wifi reload

# Reload system to apply description changes
/etc/init.d/system reload

# Show confirmation
echo -e "\033[32mSSIDs and description updated:\033[0m"
echo "2.4 GHz -> $SSID_2G"
echo "5 GHz   -> $SSID_5G"
echo "Description set to: $SSID_2G"
