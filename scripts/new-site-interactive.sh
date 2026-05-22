#!/bin/bash
set -e

echo "Создание нового Bitrix сайта"
echo

read -p "Название сайта латиницей, например shop: " SITE

if [ -z "$SITE" ]; then
  echo "Название не указано"
  exit 1
fi

echo
echo "Выбери PHP:"
echo "1) 7.4"
echo "2) 8.1"
echo "3) 8.2"
echo "4) 8.4"
read -p "Номер [4]: " PHP_CHOICE

case "$PHP_CHOICE" in
  1) PHP_VERSION="7.4" ;;
  2) PHP_VERSION="8.1" ;;
  3) PHP_VERSION="8.2" ;;
  *) PHP_VERSION="8.4" ;;
esac

echo
echo "Выбери кодировку БД:"
echo "1) utf8mb4 — новый вариант"
echo "2) utf8 / utf8mb3 — старые проекты"
read -p "Номер [1]: " CHARSET_CHOICE

case "$CHARSET_CHOICE" in
  2) CHARSET="utf8mb3" ;;
  *) CHARSET="utf8mb4" ;;
esac

echo
echo "Что положить в корень сайта?"
echo "1) bitrixsetup.php"
echo "2) restore.php"
echo "3) ничего"
read -p "Номер [3]: " INSTALLER_CHOICE

case "$INSTALLER_CHOICE" in
  1) INSTALLER="bitrixsetup" ;;
  2) INSTALLER="restore" ;;
  *) INSTALLER="none" ;;
esac

./scripts/new-site.sh "$SITE" "$PHP_VERSION" "$CHARSET" "$INSTALLER"
