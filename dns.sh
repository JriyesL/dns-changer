#!/bin/bash
CONFIG_FILE="$HOME/.config/dns_swapper.conf"
XBOX_DNS="111.88.96.50 111.88.96.51"
mkdir -p "$(dirname "$CONFIG_FILE")"
if [ -f "$CONFIG_FILE" ]; then
    CUSTOM_DNS=$(cat "$CONFIG_FILE")
fi
echo -e "\e[1;31m--- ВЫБОР DNS ---\e[0m"
echo "1) Xbox-dns.ru"
echo "2) Стандартный (DHCP)"
if [ ! -z "$CUSTOM_DNS" ]; then
    echo "3) Свой DNS ($CUSTOM_DNS)"
fi
echo "4) Настроить свой DNS"
echo "-------------------"
read -p "Выберите [1-4]: " CHOICE
apply_dns() {
    VALUE=$1
    CONN=$(nmcli -t -f NAME connection show --active | head -n 1)
    if [ -z "$CONN" ]; then
        echo "Ошибка: Активное соединение не найдено"
        exit 1
    fi
    if [ "$VALUE" == "DHCP" ]; then
        nmcli connection modify "$CONN" ipv4.dns ""
        nmcli connection modify "$CONN" ipv4.ignore-auto-dns no
        notify-send "DNS" "Стандартный DNS включен"
    else
        nmcli connection modify "$CONN" ipv4.dns "$VALUE"
        nmcli connection modify "$CONN" ipv4.ignore-auto-dns yes
        notify-send "DNS" "DNS изменен: $VALUE"
    fi
    nmcli connection up "$CONN"
}
case $CHOICE in
    1) apply_dns "$XBOX_DNS" ;;
    2) apply_dns "DHCP" ;;
    3) [[ ! -z "$CUSTOM_DNS" ]] && apply_dns "$CUSTOM_DNS" || echo "Сначала настройте вариант 4" ;;
    4) 
        read -p "Введите основной DNS: " d1
        read -p "Введите доп. DNS (можно пропустить): " d2
        NEW_DNS="$d1 $d2"
        echo "$NEW_DNS" > "$CONFIG_FILE"
        echo "Сохранено: $NEW_DNS"
        apply_dns "$NEW_DNS"
        ;;
    *) echo "Отмена" ;;
esac
