#!/bin/sh

# Ask user for new SSID for 2.4 GHz Wi-Fi
echo -n "\033[0;31mEnter new SSID for 2.4 GHz Wi-Fi (default_radio0):\033[0m"
read SSID_2G

# Generate SSID for 5 GHz by appending _5G
SSID_5G="${SSID_2G}_5G"

# Set the new SSIDs
uci set wireless.default_radio0.ssid="$SSID_2G"
uci set wireless.default_radio1.ssid="$SSID_5G"

# Save the changes to the config
uci commit wireless

# Reload Wi-Fi to apply changes
wifi reload

# Show confirmation
echo "SSIDs updated:"
echo "2.4 GHz -> $SSID_2G"
echo "5 GHz   -> $SSID_5G"
