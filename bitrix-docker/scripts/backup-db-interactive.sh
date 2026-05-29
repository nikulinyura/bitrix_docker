#!/bin/bash
set -e

SITES=()

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue
  SITES+=("$SITE")
done < sites.list

if [ ${#SITES[@]} -eq 0 ]; then
  echo "Нет сайтов для backup"
  exit 0
fi

echo "Выбери сайт для дампа БД:"
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

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="backups/${SITE}_${DATE}.sql"

echo "Создаю дамп: $FILE"

docker compose -f docker-compose.yml -f docker-compose.sites.yml exec -T mysql-$SITE \
  mysqldump -ubitrix -pbitrix bitrix > "$FILE"

echo "Готово:"
echo "$FILE"
