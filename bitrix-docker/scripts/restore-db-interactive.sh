#!/bin/bash
set -e

SITES=()

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue
  SITES+=("$SITE")
done < sites.list

if [ ${#SITES[@]} -eq 0 ]; then
  echo "Нет сайтов"
  exit 0
fi

echo "Выбери сайт для восстановления БД:"
echo

i=1
for SITE in "${SITES[@]}"; do
  echo "$i) $SITE"
  i=$((i+1))
done

echo
read -p "Номер сайта: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
  echo "Нужно ввести номер"
  exit 1
fi

INDEX=$((CHOICE-1))
SITE="${SITES[$INDEX]}"

if [ -z "$SITE" ]; then
  echo "Неверный номер"
  exit 1
fi

echo
echo "Доступные дампы:"
echo

FILES=(backups/*.sql)

if [ ! -e "${FILES[0]}" ]; then
  echo "В папке backups нет .sql файлов"
  exit 1
fi

i=1
for FILE in "${FILES[@]}"; do
  echo "$i) $FILE"
  i=$((i+1))
done

echo
read -p "Номер файла: " FILE_CHOICE

if ! [[ "$FILE_CHOICE" =~ ^[0-9]+$ ]]; then
  echo "Нужно ввести номер"
  exit 1
fi

FILE_INDEX=$((FILE_CHOICE-1))
FILE="${FILES[$FILE_INDEX]}"

if [ -z "$FILE" ]; then
  echo "Неверный номер файла"
  exit 1
fi

echo
echo "Будет восстановлена БД сайта: $SITE"
echo "Файл: $FILE"
echo "Текущая БД будет перезаписана."
read -p "Точно продолжить? Напиши yes: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Отменено"
  exit 0
fi

echo "Очищаю БД..."
docker compose -f docker-compose.yml -f docker-compose.sites.yml exec -T mysql-$SITE \
  mysql -uroot -proot -e "DROP DATABASE IF EXISTS bitrix; CREATE DATABASE bitrix CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL PRIVILEGES ON bitrix.* TO 'bitrix'@'%'; FLUSH PRIVILEGES;"

echo "Импортирую дамп..."
docker compose -f docker-compose.yml -f docker-compose.sites.yml exec -T mysql-$SITE \
  mysql -ubitrix -pbitrix bitrix < "$FILE"

echo "Готово"
