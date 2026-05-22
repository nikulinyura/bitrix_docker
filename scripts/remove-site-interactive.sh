#!/bin/bash
set -e

SITES=()

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue
  SITES+=("$SITE")
done < sites.list

if [ ${#SITES[@]} -eq 0 ]; then
  echo "Нет сайтов для удаления"
  exit 0
fi

echo "Выбери сайт для удаления:"
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

if [ -z "${SITES[$INDEX]}" ]; then
  echo "Неверный номер"
  exit 1
fi

SITE="${SITES[$INDEX]}"

echo
echo "Будет удалён сайт: $SITE"
echo "Удалятся файлы, nginx конфиг, БД и volume."
read -p "Точно удалить? Напиши yes: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Отменено"
  exit 0
fi

./scripts/remove-site.sh "$SITE"
