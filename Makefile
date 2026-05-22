COMPOSE=docker compose -f docker-compose.yml -f docker-compose.sites.yml

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=100

nginx-reload:
	$(COMPOSE) exec nginx nginx -s reload

nginx-test:
	$(COMPOSE) exec nginx nginx -t

php-shell:
	$(COMPOSE) exec php-site1 bash

mysql-shell:
	$(COMPOSE) exec mysql-site1 mysql -ubitrix -pbitrix_password bitrix

new-site:
	./scripts/new-site.sh $(name) $(php)

help:
help:
	@echo ""
	@echo "Bitrix Docker commands"
	@echo "----------------------"
	@echo "make up                         - start containers"
	@echo "make down                       - stop containers"
	@echo "make restart                    - restart containers"
	@echo "make ps                         - show containers"
	@echo "make logs                       - show logs"
	@echo ""
	@echo "make new-site name=shop php=8.4 - create new site"
	@echo "make remove-site name=shop      - remove site + db + configs"
	@echo ""
	@echo "make nginx-reload               - reload nginx"
	@echo "make php-shell                  - shell into php-site1"
	@echo "make mysql-shell                - mysql shell"
	@echo ""
	@echo "phpMyAdmin: http://localhost:8080"
	@echo "Mailpit:    http://localhost:8025"
	@echo ""

remove-site:
	./scripts/remove-site.sh $(name)

new:
	./scripts/new-site-interactive.sh

remove:
	./scripts/remove-site-interactive.sh
