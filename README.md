# Bitrix Docker

Локальная среда для запуска нескольких Bitrix сайтов одновременно.

## Возможности

- Несколько сайтов одновременно
- PHP: 7.4 / 8.1 / 8.2 / 8.4
- Отдельная MySQL для каждого сайта
- phpMyAdmin
- Mailpit (перехват почты)
- Автосоздание сайтов
- Автоудаление сайтов + БД + volume
- Выбор кодировки БД (utf8mb4 / utf8mb3)
- Выбор установщика: bitrixsetup.php / restore.php
- Автогенерация nginx и docker-compose
- Cron для Bitrix
- Проверка Bitrix проходит sockets/mail/mysql

## Требования

### ОС

Поддерживается без доработок:

- macOS (Intel / Apple Silicon M1 M2 M3 M4 M5)
- Linux (Ubuntu, Debian и др.)

Рекомендуется:

- macOS 13+
- Ubuntu 22+

---

### Обязательно установить

- Docker Desktop
- Docker Compose (обычно входит в Docker Desktop)

Проверка:

```bash
docker -v
docker compose version

## Установка

1. Установить Docker Desktop

Проверить:

```bash
docker -v
docker compose version
```

2. Собрать PHP образы:

```bash
docker build -t bitrix-php:7.4-v1 php/7.4
docker build -t bitrix-php:8.1-v1 php/8.1
docker build -t bitrix-php:8.2-v1 php/8.2
docker build -t bitrix-php:8.4-v1 php/8.4
```

3. Запуск:

```bash
make up
```

## Создание сайта

```bash
make new
```

Выбор:
- имя
- PHP
- кодировка БД
- restore.php / bitrixsetup.php / ничего

В /bitrix-projects/ пояаится папка сайта www и README.md с нужными ссылками и реквизитами
----------------------------------
# site.local

URL:
http://site.local

Web root:
www/

PHP:
8.4

Database:
- host: mysql-site
- database: bitrix
- user: bitrix
- password: bitrix

phpMyAdmin:
http://localhost:8080

Mailpit:
http://localhost:8025

Install:
http://site.local/bitrixsetup.php

Restore:
http://site.local/restore.php
--------------------------------------------

## Удаление сайта

```bash
make remove
```
Выдается список сайтов для выбора

Удаляются:
- проект
- БД
- volume
- nginx
- compose
- sites.list

## Сервисы

Сайт:

http://site.local

phpMyAdmin:

http://localhost:8080

Логин: bitrix  
Пароль: bitrix

Почта:

http://localhost:8025

## Команды Make

```bash
make up          # запуск
make down        # остановка
make restart     # перезапуск
make ps          # контейнеры
make logs        # логи
make new         # создать сайт
make remove      # удалить сайт
make new-site    # создание через параметры
make remove-site # удаление через параметры
```
