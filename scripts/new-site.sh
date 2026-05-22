#!/bin/bash
set -e

SITE="$1"
CHARSET="${3:-utf8mb4}"
INSTALLER="${4:-none}"
PHP_VERSION="${2:-8.4}"

if [ -z "$SITE" ]; then
  echo "Usage: make new-site name=shop php=8.4"
  exit 1
fi

PROJECTS_DIR="../bitrix-projects"
HOST="$SITE.local"

if grep -q "^$SITE " sites.list; then
  echo "Site already exists: $SITE"
  exit 1
fi

mkdir -p "$PROJECTS_DIR/$SITE/www"

echo "$SITE $PHP_VERSION $CHARSET $INSTALLER" >> sites.list

cat > "$PROJECTS_DIR/$SITE/README.md" <<README
# $HOST

URL:
http://$HOST

Web root:
www/

PHP:
$PHP_VERSION

Database:
- host: mysql-$SITE
- database: bitrix
- user: bitrix
- password: bitrix

phpMyAdmin:
http://localhost:8080

Mailpit:
http://localhost:8025

Install:
http://$HOST/bitrixsetup.php

Restore:
http://$HOST/restore.php
README

if [ "$INSTALLER" = "bitrixsetup" ] && [ -f "installers/bitrixsetup.php" ]; then
  cp installers/bitrixsetup.php "$PROJECTS_DIR/$SITE/www/bitrixsetup.php"
fi

if [ "$INSTALLER" = "restore" ] && [ -f "installers/restore.php" ]; then
  cp installers/restore.php "$PROJECTS_DIR/$SITE/www/restore.php"
fi

cat > "nginx/$SITE.conf" <<NGINX
server {
    listen 80;
    server_name $HOST;

    root /var/www/$SITE/www;
    index index.php index.html;

    charset utf-8;
    client_max_body_size 1024M;

    location / {
        try_files \$uri \$uri/ /bitrix/urlrewrite.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php-$SITE:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
NGINX

if ! grep -q "$HOST" /etc/hosts; then
  echo "127.0.0.1 $HOST" | sudo tee -a /etc/hosts
fi

./scripts/generate-sites-compose.sh

docker compose -f docker-compose.yml -f docker-compose.sites.yml down
docker compose -f docker-compose.yml -f docker-compose.sites.yml up -d
echo "Created $SITE"
echo "URL: http://$HOST"
echo "DB host: mysql-$SITE"
echo "DB name: bitrix"
echo "DB user: bitrix"
echo "DB pass: bitrix"
