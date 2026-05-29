#!/bin/bash
set -e

SITE="$1"

if [ -z "$SITE" ]; then
  echo "Usage: make remove-site name=shop"
  exit 1
fi

COMPOSE="docker compose -f docker-compose.yml -f docker-compose.sites.yml"
VOLUME="bitrix_local_mysql_${SITE}_data"

$COMPOSE stop "php-$SITE" "mysql-$SITE" "cron-$SITE" 2>/dev/null || true
$COMPOSE rm -f "php-$SITE" "mysql-$SITE" "cron-$SITE" 2>/dev/null || true

rm -rf "../bitrix-projects/$SITE"
rm -f "nginx/$SITE.conf"

grep -v "^$SITE " sites.list > sites.list.tmp
mv sites.list.tmp sites.list

./scripts/generate-sites-compose.sh

docker volume rm "$VOLUME" 2>/dev/null || true

$COMPOSE exec nginx nginx -s reload 2>/dev/null || true

docker compose -f docker-compose.yml -f docker-compose.sites.yml down
docker compose -f docker-compose.yml -f docker-compose.sites.yml up -d
echo "Removed site: $SITE"
echo "Removed volume: $VOLUME"
