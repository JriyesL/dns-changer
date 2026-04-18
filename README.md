## Localization Guide

*Note: This repository is primarily in Russian, but you can easily translate the script for your own use.*

To localize the script interface to English (or any other language), you simply need to change the text inside the `echo`, `read -p`, and `notify-send` commands in the installation code. 

**Key strings to translate:**
* `"--- ВЫБОР DNS ---"` -> `"--- DNS SELECTION ---"`
* `"1) Xbox-dns.ru"` -> (Leave as is or change to your preferred default)
* `"2) Стандартный (DHCP)"` -> `"2) Default (DHCP)"`
* `"3) Свой DNS"` -> `"3) Custom DNS"`
* `"4) Настроить свой DNS"` -> `"4) Set custom DNS"`
* `"Выберите [1-4]: "` -> `"Choose [1-4]: "`
* Notification strings in `notify-send` (e.g., `"Стандартный DNS включен"` -> `"Default DNS enabled"`).

---

# DNS-Changer

Простой и удобный bash-скрипт для быстрого переключения DNS-серверов в Linux. Скрипт предоставляет интерактивное меню прямо в терминале и позволяет переключаться между предустановленными адресами, стандартным DHCP или вашим собственным DNS, а также [Xbox-dns.ru](https://xbox-dns.ru/) (Для пользователей из России позволяет пользоваться некоторыми иностранным сервисам)

## Совместимость

Скрипт использует стандартные утилиты Linux и максимально универсален:
* **Сетевой менеджер:** Требуется **NetworkManager** (утилита `nmcli`). Это стандартный менеджер сети почти во всех современных десктопных дистрибутивах Linux (Ubuntu, Fedora, Arch, Linux Mint и др.) Было проверено на CachyOS.
* **Оболочка (Shell):** Скрипт написан на `bash`, но команда установки автоматически прописывает алиасы (команды для быстрого запуска) для **Bash**, **Zsh** и **Fish**.
* **Уведомления:** Используется `notify-send` для показа системных уведомлений при успешной смене DNS.

## Быстрая установка

Чтобы установить скрипт, просто скопируйте этот блок и вставьте в свой терминал. 

Команда автоматически создаст папку `~/scripts`, сохранит туда скрипт, сделает его исполняемым и пропишет алиас для вашего терминала.

```bash
bash -c "mkdir -p ~/scripts && echo '#!/bin/bash
CONFIG_FILE=\"\$HOME/.config/dns_swapper.conf\"
XBOX_DNS=\"111.88.96.50 111.88.96.51\"
mkdir -p \"\$(dirname \"\$CONFIG_FILE\")\"
if [ -f \"\$CONFIG_FILE\" ]; then
    CUSTOM_DNS=\$(cat \"\$CONFIG_FILE\")
fi
echo -e \"\e[1;31m--- ВЫБОР DNS ---\e[0m\"
echo \"1) Xbox-dns.ru\"
echo \"2) Стандартный (DHCP)\"
if [ ! -z \"\$CUSTOM_DNS\" ]; then
    echo \"3) Свой DNS (\$CUSTOM_DNS)\"
fi
echo \"4) Настроить свой DNS\"
echo \"-------------------\"
read -p \"Выберите [1-4]: \" CHOICE
apply_dns() {
    VALUE=\$1
    CONN=\$(nmcli -t -f NAME connection show --active | head -n 1)
    if [ -z \"\$CONN\" ]; then
        echo \"Ошибка: Активное соединение не найдено\"
        exit 1
    fi
    if [ \"\$VALUE\" == \"DHCP\" ]; then
        nmcli connection modify \"\$CONN\" ipv4.dns \"\"
        nmcli connection modify \"\$CONN\" ipv4.ignore-auto-dns no
        notify-send \"DNS\" \"Стандартный DNS включен\"
    else
        nmcli connection modify \"\$CONN\" ipv4.dns \"\$VALUE\"
        nmcli connection modify \"\$CONN\" ipv4.ignore-auto-dns yes
        notify-send \"DNS\" \"DNS изменен: \$VALUE\"
    fi
    nmcli connection up \"\$CONN\"
}
case \$CHOICE in
    1) apply_dns \"\$XBOX_DNS\" ;;
    2) apply_dns \"DHCP\" ;;
    3) [[ ! -z \"\$CUSTOM_DNS\" ]] && apply_dns \"\$CUSTOM_DNS\" || echo \"Сначала настройте вариант 4\" ;;
    4) 
        read -p \"Введите основной DNS: \" d1
        read -p \"Введите доп. DNS (можно пропустить): \" d2
        NEW_DNS=\"\$d1 \$d2\"
        echo \"\$NEW_DNS\" > \"\$CONFIG_FILE\"
        echo \"Сохранено: \$NEW_DNS\"
        apply_dns \"\$NEW_DNS\"
        ;;
    *) echo \"Отмена\" ;;
esac' > ~/scripts/dns.sh && chmod +x ~/scripts/dns.sh && (echo \"alias dns='~/scripts/dns.sh'\" >> ~/.bashrc; [ -f ~/.zshrc ] && echo \"alias dns='~/scripts/dns.sh'\" >> ~/.zshrc; [ -d ~/.config/fish ] && echo \"alias dns '~/scripts/dns.sh'\" >> ~/.config/fish/config.fish) && echo 'ГОТОВО. Напишите dns в терминале.'"
```
## Использование

Для использования скрипта можете просто написать
```bash
dns
```
или открыть в проводнике. Появится меню выбора. Введите нужную цифру и нажмите Enter.

## Замена на свою команду

- Спуститесь в самый низ файла и найдите строку, которую добавил скрипт. Она выглядит так:
-         `alias dns='~/scripts/dns.sh'`
- Просто замените слово dns перед знаком равно на вашу команду. Должно получиться, например, так:
          `alias switchdns='~/scripts/dns.sh'`

## Удаление

Для простого удаления скрипта напишите:
```bash
bash -c "rm ~/scripts/dns.sh; sed -i '/alias dns/d' ~/.bashrc; [ -f ~/.zshrc ] && sed -i '/alias dns/d' ~/.zshrc; [ -f ~/.config/fish/config.fish ] && sed -i '/alias dns/d' ~/.config/fish/config.fish; echo 'Удалено'"
```
