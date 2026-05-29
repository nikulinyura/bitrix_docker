# Bitrix Docker

Локальная среда для запуска нескольких сайтов Битрикс одновременно.

## Возможности

- Несколько сайтов одновременно
- PHP: 7.4 / 8.1 / 8.2 / 8.3 / 8.4
- Отдельная MySQL для каждого сайта
- phpMyAdmin
- Mailpit (перехват почты)
- Автосоздание сайтов
- Автоудаление сайтов вместе с БД и Docker Volume
- Выбор кодировки БД (utf8mb4 / utf8mb3)
- Выбор установщика (bitrixsetup.php / restore.php)
- Автогенерация nginx-конфигов
- Автогенерация docker-compose.sites.yml
- Cron для Битрикс
- Backup и восстановление БД
- Проверка Битрикс проходит проверки sockets, mail и MySQL

---

# Требования

## ОС

Поддерживается без доработок:

- macOS (Intel / Apple Silicon)
- Linux (Ubuntu, Debian и другие)

Рекомендуется:

- macOS 13+
- Ubuntu 22+

## Рекомендуемые ресурсы

Для 3–10 сайтов:

- CPU: 8+ ядер
- RAM: 16–32 GB
- SSD: 100–200 GB
- Docker Memory: 16–24 GB

## Необходимо установить

- Docker Desktop

Проверка:

```bash 
docker -v docker compose version
````

---

# Установка

Перейти в папку проекта:

``` bash 
cd bitrix-docker
```
Собрать PHP-образы (один раз):

``` bash 
docker build -t bitrix-php:7.4-v1 php/7.4 
docker build -t bitrix-php:8.1-v1 php/8.1 
docker build -t bitrix-php:8.2-v1 php/8.2 
docker build -t bitrix-php:8.3-v1 php/8.3 
docker build -t bitrix-php:8.4-v1 php/8.4
```
Запустить окружение:
``` bash 
make up
```
---

# Создание сайта
``` bash 
make new
```
Скрипт предложит выбрать:

- название сайта
- версию PHP
- кодировку БД
- bitrixsetup.php
- restore.php
- ничего

После создания в папке bitrix-projects появится новая папка сайта.

Структура:

```text 
bitrix-projects/ └── site/     ├── www/     └── README.md
```

Пример README сайта:

text # site.local  URL: http://site.local  Web root: www/  PHP: 8.4  Database: - host: mysql-site - database: bitrix - user: bitrix - password: bitrix  phpMyAdmin: http://localhost:8080  Mailpit: http://localhost:8025  Install: http://site.local/bitrixsetup.php  Restore: http://site.local/restore.php

После создания автоматически:

- создаётся проект
- создаётся nginx-конфиг
- создаётся MySQL
- создаётся cron
- генерируется compose
- Docker перезапускается

---

# Удаление сайта

```bash 
make remove
```
Показывается список сайтов для выбора.

Удаляются:

- проект
- nginx-конфиг
- БД
- Docker Volume
- записи compose
- запись в sites.list

После удаления Docker автоматически перезапускается.

---

# Backup БД

Создать дамп:

```bash 
make backup
```
Выбрать сайт из списка.

Дампы сохраняются в:

```text 
backups/
```
---

# Восстановление БД

```bash 
make restore-db
```
Выбрать:

1. Сайт
2. Дамп

Текущая БД будет очищена и восстановлена из выбранного файла.

---

# Сервисы

Сайт:

text http://site.local

phpMyAdmin:

```text 
http://localhost:8080
```
Логин:

```text 
bitrix
```

Пароль:

```text 
bitrix
```
Почта:

```text 
http://localhost:8025
```
---

# Команды Make

```bash 
make up 
make down 
make restart 
make ps 
make logs  
make new 
make remove  
make backup 
make restore-db  

```