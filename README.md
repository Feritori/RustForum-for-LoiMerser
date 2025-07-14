# Платформа для плагинов Rust

Современная платформа для обмена, покупки и продажи плагинов для игры Rust с расширенной функциональностью.

## 📋 Содержание

- [🚀 Быстрая установка](#-быстрая-установка)
- [⚙️ Подробная настройка](#️-подробная-настройка)
- [🔧 Настройка сайта](#-настройка-сайта)
- [👨‍💼 Админ-панель](#-админ-панель)
- [📁 Структура файлов](#-структура-файлов)
- [🎨 Настройка дизайна](#-настройка-дизайна)
- [🔒 Безопасность](#-безопасность)
- [📊 Функции](#-функции)
- [🆘 Поддержка](#-поддержка)

## 🚀 Быстрая установка

### Требования
- **PHP 8.2+** с расширениями: mysqli, json, mbstring, gd
- **MySQL 5.7+** или **MariaDB 10.2+**
- **Apache** или **Nginx**
- **Composer** (опционально)

### 1. Загрузка файлов
```bash
# Скачайте архив с сайта или клонируйте репозиторийназва
cd rustforum
```

### 2. Настройка веб-сервера
```apache
# Apache (.htaccess уже настроен)
# Убедитесь, что mod_rewrite включен
# Корневая папка должна указывать на папку public/

# Nginx конфигурация
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/rustforum/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 3. Создание базы данных
```sql
CREATE DATABASE rustforum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'rustforum_user'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON rustforum.* TO 'rustforum_user'@'localhost';
FLUSH PRIVILEGES;
```

### 4. Импорт структуры БД
```bash
mysql -u rustforum_user -p rustforum < install_database.sql
```

### 5. Настройка конфигурации
Отредактируйте файл `includes/config.php`:
```php
<?php
// База данных
define('DB_HOST', 'localhost');
define('DB_NAME', 'rustforum');
define('DB_USER', 'rustforum_user');
define('DB_PASS', 'your_strong_password');

// Настройки сайта
define('SITE_URL', 'https://your-domain.com');
define('SITE_NAME', 'ВАШЕ НАЗВАНИЕ');
define('SITE_DESCRIPTION', 'Лучшая платформа для плагинов Rust');
define('ADMIN_EMAIL', 'admin@your-domain.com');

// Безопасность
define('SECRET_KEY', 'your_random_secret_key_here');
define('SESSION_LIFETIME', 86400); // 24 часа

// Загрузка файлов
define('MAX_FILE_SIZE', 50 * 1024 * 1024); // 50MB
define('ALLOWED_EXTENSIONS', ['cs', 'dll', 'zip', 'rar']);

// Платежи
define('PAYMENT_ENABLED', true);
define('PAYMENT_METHOD', 'manual'); // manual, yookassa, sberbank
define('PREMIUM_PRICE', 399); // Цена премиум подписки в рублях
?>
```

### 6. Настройка прав доступа
```bash
chmod 755 uploads/
chmod 755 assets/
chmod 644 includes/config.php
chown -R www-data:www-data uploads/
chown -R www-data:www-data assets/
```

### 7. Первый запуск
1. Откройте сайт в браузере: `https://your-domain.com`
2. Создайте первого пользователя через регистрацию
3. Войдите в админ-панель: `https://your-domain.com/admin`

## ⚙️ Подробная настройка

### Настройка PHP
Добавьте в `php.ini`:
```ini
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 300
memory_limit = 256M
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log
```

### Настройка MySQL
Добавьте в `my.cnf`:
```ini
[mysqld]
max_allowed_packet = 64M
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
```

### SSL сертификат
```bash
# Установка Let's Encrypt
sudo apt install certbot
sudo certbot --apache -d your-domain.com
```

## 🔧 Настройка сайта

### Изменение названия и описания

#### 1. Основные настройки (`includes/config.php`)
```php
define('SITE_NAME', 'Ваше название сайта');
define('SITE_DESCRIPTION', 'Описание вашего сайта');
define('SITE_KEYWORDS', 'ключевые, слова, сайта');
define('ADMIN_EMAIL', 'admin@your-domain.com');
```

#### 2. Логотип и фавикон
- Замените `assets/images/logo.png` на ваш логотип
- Замените `assets/images/favicon.ico` на вашу иконку
- Размеры: логотип 200x50px, фавикон 32x32px

#### 3. Цветовая схема (`public/css/style.css`)
Найдите и измените CSS переменные:
```css
:root {
    --primary-color: #007bff;     /* Основной цвет */
    --secondary-color: #6c757d;   /* Вторичный цвет */
    --success-color: #28a745;     /* Цвет успеха */
    --danger-color: #dc3545;      /* Цвет ошибки */
    --warning-color: #ffc107;     /* Цвет предупреждения */
    --info-color: #17a2b8;        /* Информационный цвет */
}
```

#### 4. Мета-теги (`templates/header.php`)
Найдите и измените:
```php
<title><?php echo SITE_NAME; ?> - <?php echo $page_title ?? 'Главная'; ?></title>
<meta name="description" content="<?php echo $page_description ?? SITE_DESCRIPTION; ?>">
<meta name="keywords" content="<?php echo $page_keywords ?? SITE_KEYWORDS; ?>">
```

### Настройка платежей

#### Ручная оплата (по умолчанию)
```php
// В includes/config.php
define('PAYMENT_METHOD', 'manual');
define('PAYMENT_DETAILS', 'QIWI: +7XXXXXXXXXX, ЮMoney: 4100XXXXXXXX');
```

#### ЮKassa (рекомендуется)
```php
// В includes/config.php
define('PAYMENT_METHOD', 'yookassa');
define('YOOKASSA_SHOP_ID', 'your_shop_id');
define('YOOKASSA_SECRET_KEY', 'your_secret_key');
```

### Настройка уведомлений

#### Email уведомления
```php
// В includes/config.php
define('SMTP_HOST', 'smtp.your-domain.com');
define('SMTP_PORT', 587);
define('SMTP_USER', 'noreply@your-domain.com');
define('SMTP_PASS', 'your_smtp_password');
define('SMTP_SECURE', 'tls');
```

#### Telegram бот
```php
// В includes/config.php
define('TELEGRAM_BOT_TOKEN', 'your_bot_token');
define('TELEGRAM_CHAT_ID', 'your_chat_id');
```

## 👨‍💼 Админ-панель

### Доступ к админ-панели
- URL: `https://your-domain.com/admin`
- Логин: `admin` (или email первого пользователя)
- Пароль: пароль, который вы указали при регистрации

### Создание администратора
```sql
-- В базе данных измените роль первого пользователя
UPDATE users SET role = 'admin' WHERE id = 1;
```

### Разделы админ-панели

#### 1. Панель управления
- Общая статистика сайта
- Количество пользователей, плагинов, загрузок
- Графики активности
- Последние действия

#### 2. Управление плагинами
- Модерация новых плагинов
- Редактирование существующих
- Удаление плагинов
- Изменение статусов

#### 3. Управление пользователями
- Просмотр всех пользователей
- Изменение ролей
- Блокировка/разблокировка
- Редактирование профилей

#### 4. Достижения
- Создание новых достижений
- Редактирование существующих
- Настройка условий получения
- Просмотр статистики

#### 5. Аналитика
- Детальная статистика
- Графики и диаграммы
- Экспорт данных
- Фильтры по датам

#### 6. SEO
- Управление мета-тегами
- Настройка Open Graph
- Генерация sitemap
- Оптимизация для поисковиков

#### 7. AI Модерация
- Настройка автоматической модерации
- Просмотр логов модерации
- Настройка фильтров
- Статистика работы AI

#### 8. Настройки сайта
- Основные настройки
- Настройка платежей
- Настройка уведомлений
- Управление темами

### Роли пользователей
- **Гость** - только просмотр
- **Пользователь** - загрузка плагинов, комментарии
- **Модератор** - модерация контента
- **Администратор** - полный доступ

## 📁 Структура файлов

```
rustforum/
├── assets/                    # Статические файлы
│   ├── images/               # Изображения (логотип, фавикон)
│   └── fonts/                # Шрифты
├── includes/                 # PHP файлы
│   ├── config.php           # Конфигурация (ИЗМЕНИТЬ!)
│   ├── db.php               # Подключение к БД
│   └── functions.php        # Функции сайта
├── public/                   # Публичные файлы
│   ├── css/                 # Стили
│   │   └── style.css        # Основные стили (ИЗМЕНИТЬ!)
│   ├── js/                  # JavaScript
│   ├── index.php            # Главный файл
│   └── .htaccess            # Настройки Apache
├── templates/                # Шаблоны страниц
│   ├── header.php           # Шапка сайта (ИЗМЕНИТЬ!)
│   ├── footer.php           # Подвал сайта (ИЗМЕНИТЬ!)
│   ├── admin.php            # Админ-панель
│   └── ...                  # Остальные страницы
├── uploads/                  # Загруженные файлы
│   ├── plugins/             # Плагины пользователей
│   ├── avatars/             # Аватары пользователей
│   └── temp/                # Временные файлы
├── install_database.sql      # Структура БД
├── .htaccess                 # Настройки Apache
└── README.md                 # Документация
```

## 🎨 Настройка дизайна

### Изменение темы
1. В админ-панели: Настройки → Темы
2. Выберите тему из 10 доступных
3. Или создайте свою тему в таблице `themes`

### Создание своей темы
```sql
INSERT INTO themes (name, description, css_variables, is_active) VALUES (
    'Моя тема',
    'Описание моей темы',
    '{"--primary-color": "#ff6b6b", "--secondary-color": "#4ecdc4"}',
    1
);
```

### Кастомизация CSS
Отредактируйте `public/css/style.css`:
```css
/* Ваши стили */
.custom-header {
    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
}

.custom-button {
    background-color: var(--primary-color);
    border-radius: 25px;
}
```

### Изменение логотипа
1. Подготовьте логотип размером 200x50px
2. Замените `assets/images/logo.png`
3. Обновите в `templates/header.php`:
```php
<img src="/assets/images/logo.png" alt="<?php echo SITE_NAME; ?>" height="50">
```

## 🔒 Безопасность

### Обязательные настройки
1. **Измените SECRET_KEY** в `includes/config.php`
2. **Используйте HTTPS** на продакшене
3. **Настройте firewall** на сервере
4. **Регулярно обновляйте** PHP и MySQL

### Дополнительная безопасность
```php
// В includes/config.php
define('LOGIN_ATTEMPTS_LIMIT', 5);        // Лимит попыток входа
define('LOGIN_TIMEOUT', 900);             // Таймаут блокировки (15 мин)
define('PASSWORD_MIN_LENGTH', 8);         // Минимальная длина пароля
define('SESSION_REGENERATE', 300);        // Регенерация сессии (5 мин)
```

### Резервное копирование
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u rustforum_user -p rustforum > backup_$DATE.sql
tar -czf backup_$DATE.tar.gz backup_$DATE.sql uploads/ assets/
rm backup_$DATE.sql
```

## 📊 Функции

### Основные функции
- ✅ Регистрация и авторизация пользователей
- ✅ Загрузка и скачивание плагинов
- ✅ Система комментариев и рейтингов
- ✅ Форум с темами и постами
- ✅ Система избранного
- ✅ Уведомления пользователей

### Расширенные функции
- ✅ Система достижений и уровней
- ✅ Премиум подписка (399₽/мес)
- ✅ Подписки на авторов
- ✅ Система соавторов плагинов
- ✅ Личные сообщения между пользователями
- ✅ Реферальная система
- ✅ Промокоды и скидки
- ✅ 10 тем оформления
- ✅ Мобильная адаптация
- ✅ SEO оптимизация
- ✅ AI модерация контента
- ✅ Расширенная аналитика

### Планируемые функции
- 🔄 Интеграция с платежными системами
- 🔄 PWA приложение
- 🔄 Telegram бот
- 🔄 API для разработчиков
- 🔄 Система отзывов
- 🔄 Автоматические переводы

## 🆘 Поддержка

### Частые проблемы

#### 1. Ошибка подключения к БД
```
Проверьте настройки в includes/config.php
Убедитесь, что MySQL запущен
Проверьте права доступа пользователя БД
```

#### 2. Ошибка загрузки файлов
```
Проверьте права доступа папки uploads/
Увеличьте лимиты в php.ini
Проверьте настройки веб-сервера
```

#### 3. Не работает .htaccess
```
Включите mod_rewrite в Apache
Проверьте настройки AllowOverride
Перезапустите Apache
```

#### 4. Ошибки 500
```
Проверьте логи ошибок PHP
Включите display_errors для отладки
Проверьте синтаксис PHP файлов
```

### Полезные команды
```bash
# Проверка прав доступа
ls -la uploads/
ls -la includes/config.php

# Проверка логов
tail -f /var/log/apache2/error.log
tail -f /var/log/php_errors.log

# Очистка кэша
rm -rf uploads/temp/*
rm -rf public/cache/*

# Проверка PHP
php -v
php -m | grep -E "(mysqli|json|mbstring|gd)"
```

### Контакты для поддержки
- **Email**: support@your-domain.com
- **Telegram**: @your_support_bot
- **Discord**: [Сервер поддержки]
- **Документация**: [Wiki проекта]

### Обновления
```bash
# Создание резервной копии
./backup.sh

# Обновление файлов
git pull origin main

# Обновление БД (если есть миграции)
mysql -u rustforum_user -p rustforum < migrations.sql

# Проверка прав доступа
chmod 755 uploads/
chmod 644 includes/config.php
```

---

## 🎯 Быстрый старт

1. **Скачайте файлы** и загрузите на сервер
2. **Создайте БД** и импортируйте `install_database.sql`
3. **Настройте** `includes/config.php`
4. **Установите права** доступа
5. **Откройте сайт** и зарегистрируйтесь
6. **Войдите в админку** и настройте сайт

**Готово!** Ваш сайт для плагинов Rust работает! 🚀

---

**ВАШЕ НАЗВАНИЕ** - лучшая платформа для плагинов Rust! 

*Версия 2.0 | Последнее обновление: <?php echo date('d.m.Y'); ?>* 