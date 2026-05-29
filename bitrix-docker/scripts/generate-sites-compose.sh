#!/bin/bash
set -e

COMPOSE_FILE="docker-compose.sites.yml"

HOSTS="mysql-site1"
VERBOSE="site1"
NGINX_ALIASES=""

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue

  HOSTS="$HOSTS,mysql-$SITE"
  VERBOSE="$VERBOSE,$SITE"
  NGINX_ALIASES="$NGINX_ALIASES
        - $SITE.local"
done < sites.list

cat > "$COMPOSE_FILE" <<YAML
services:
  nginx:
    networks:
      default:
        aliases:$NGINX_ALIASES

  phpmyadmin:
    environment:
      PMA_ARBITRARY: 1
      PMA_HOSTS: $HOSTS
      PMA_VERBOSE: $VERBOSE
      UPLOAD_LIMIT: 1024M
YAML

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue

  if [ "$CHARSET" = "utf8" ] || [ "$CHARSET" = "utf8mb3" ]; then
    MYSQL_CHARSET="utf8"
    MYSQL_COLLATION="utf8_general_ci"
  else
    MYSQL_CHARSET="utf8mb4"
    MYSQL_COLLATION="utf8mb4_unicode_ci"
  fi

  cat >> "$COMPOSE_FILE" <<YAML

  php-$SITE:
    image: bitrix-php:$PHP_VERSION-v1
    platform: linux/arm64
    volumes:
      - ../bitrix-projects/$SITE/www:/var/www/$SITE/www
      - ./php/custom.ini:/usr/local/etc/php/conf.d/custom.ini
      - ./php/msmtprc:/etc/msmtprc

  mysql-$SITE:
    image: mysql:8.0
    platform: linux/arm64
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: bitrix
      MYSQL_USER: bitrix
      MYSQL_PASSWORD: bitrix
    command: --character-set-server=$MYSQL_CHARSET --collation-server=$MYSQL_COLLATION --default-time-zone=+03:00 --innodb-strict-mode=0 --sql-mode=""
    volumes:
      - mysql_${SITE}_data:/var/lib/mysql

  cron-$SITE:
    image: bitrix-php:$PHP_VERSION-v1
    platform: linux/arm64
    volumes:
      - ../bitrix-projects/$SITE/www:/var/www/$SITE/www
      - ./php/custom.ini:/usr/local/etc/php/conf.d/custom.ini
      - ./php/msmtprc:/etc/msmtprc
    command: ["sh", "-lc", "while true; do php -f /var/www/$SITE/www/bitrix/modules/main/tools/cron_events.php; sleep 60; done"]
    depends_on:
      - mysql-$SITE
      - php-$SITE
YAML

done < sites.list

cat >> "$COMPOSE_FILE" <<YAML

volumes:
YAML

while read -r SITE PHP_VERSION CHARSET INSTALLER; do
  [[ -z "$SITE" ]] && continue
  [[ "$SITE" == \#* ]] && continue

  cat >> "$COMPOSE_FILE" <<YAML
  mysql_${SITE}_data:
YAML

done < sites.list

echo "Generated $COMPOSE_FILE"
