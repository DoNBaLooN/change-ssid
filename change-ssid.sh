#!/bin/sh

# Запрос нового SSID для 2.4 ГГц Wi-Fi
echo -ne "\033[32mEnter new SSID for 2.4 GHz Wi-Fi (default_radio0): \033[0m"
read SSID_2G

# Создание SSID для 5 ГГц
SSID_5G="${SSID_2G}_5G"

# Применение новых SSID
uci set wireless.default_radio0.ssid="$SSID_2G"
uci set wireless.default_radio1.ssid="$SSID_5G"

# Обновление описания системы
uci set system.@system[0].description="$SSID_2G"

# Генерация нового MAC-адреса (локально администрируемый)
RANDMAC=$(hexdump -n5 -e '/1 ":%02X"' /dev/urandom)
NEW_MAC="e8${RANDMAC}"

# Установка нового MAC-адреса для WAN
uci set network.@device[1].macaddr="$NEW_MAC"

# Сохранение изменений
uci commit wireless
uci commit system
uci commit network

# Применение настроек
wifi reload
/etc/init.d/system reload
/etc/init.d/network restart

# Подтверждение
echo -e "\033[32mSSIDs and description updated:\033[0m"
echo "2.4 GHz -> $SSID_2G"
echo "5 GHz   -> $SSID_5G"
echo "Description set to: $SSID_2G"
echo -e "\033[32mNew MAC address for WAN: $NEW_MAC\033[0m"
