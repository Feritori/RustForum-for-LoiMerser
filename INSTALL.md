# 🚀 Быстрая установка ВАШЕ НАЗВАНИЕ

## 📋 Что нужно изменить после установки

### 1. Название и описание сайта
**Файл:** `includes/config.php`
```php
// Строки 15-18
define('SITE_NAME', 'Ваше название сайта');
define('SITE_DESCRIPTION', 'Описание вашего сайта');
define('SITE_KEYWORDS', 'ключевые, слова, сайта');
define('ADMIN_EMAIL', 'admin@your-domain.com');
```

### 2. Логотип сайта
**Файл:** `assets/images/logo.png`
- Размер: 200x50px
- Формат: PNG с прозрачным фоном
- Замените на ваш логотип

### 3. Фавикон (иконка сайта)
**Файл:** `assets/images/favicon.ico`
- Размер: 32x32px
- Формат: ICO
- Замените на вашу иконку

### 4. Цветовая схема
**Файл:** `public/css/style.css`
```css
/* Строки 3-10 */
:root {
    --primary-color: #007bff;     /* Основной цвет */
    --secondary-color: #6c757d;   /* Вторичный цвет */
    --success-color: #28a745;     /* Цвет успеха */
    --danger-color: #dc3545;      /* Цвет ошибки */
    --warning-color: #ffc107;     /* Цвет предупреждения */
    --info-color: #17a2b8;        /* Информационный цвет */
}
```

### 5. Мета-теги
**Файл:** `templates/header.php`
```php
/* Строки 15-20 */
<title><?php echo SITE_NAME; ?> - <?php echo $page_title ?? 'Главная'; ?></title>
<meta name="description" content="<?php echo $page_description ?? SITE_DESCRIPTION; ?>">
<meta name="keywords" content="<?php echo $page_keywords ?? SITE_KEYWORDS; ?>">
```

## 🔐 Доступ к админ-панели

### Первый вход
1. Зарегистрируйтесь на сайте как обычный пользователь
2. Войдите в базу данных и измените роль:
```sql
UPDATE users SET role = 'admin' WHERE id = 1;
```
3. Войдите в админ-панель: `https://your-domain.com/admin`

### Логин и пароль
- **Логин:** ваш email или username
- **Пароль:** пароль, который вы указали при регистрации

## ⚙️ Обязательные настройки

### 1. База данных (`includes/config.php`)
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'rustforum');
define('DB_USER', 'rustforum_user');
define('DB_PASS', 'your_strong_password');
```

### 2. URL сайта (`includes/config.php`)
```php
define('SITE_URL', 'https://your-domain.com');
```

### 3. Секретный ключ (`includes/config.php`)
```php
define('SECRET_KEY', 'your_random_secret_key_here');
```
**Важно:** Сгенерируйте случайный ключ длиной 32 символа!

### 4. Платежные реквизиты (`includes/config.php`)
```php
define('PAYMENT_METHOD', 'manual');
define('PAYMENT_DETAILS', 'QIWI: +7XXXXXXXXXX, ЮMoney: 4100XXXXXXXX');
```

## 🎨 Настройка дизайна

### Выбор темы
1. Войдите в админ-панель
2. Перейдите в "Настройки" → "Темы"
3. Выберите одну из 10 доступных тем

### Создание своей темы
```sql
INSERT INTO themes (name, description, css_variables, is_active) VALUES (
    'Моя тема',
    'Описание моей темы',
    '{"--primary-color": "#ff6b6b", "--secondary-color": "#4ecdc4"}',
    1
);
```

## 📊 Настройка функций

### 1. Достижения
- В админ-панели: "Достижения" → "Управление"
- Создайте новые достижения или отредактируйте существующие

### 2. Премиум подписка
- Цена по умолчанию: 399₽/месяц
- Измените в `includes/config.php`:
```php
define('PREMIUM_PRICE', 399);
```

### 3. SEO настройки
- В админ-панели: "SEO" → "Мета-теги"
- Настройте мета-теги для каждой страницы

### 4. AI модерация
- В админ-панели: "AI Модерация" → "Настройки"
- Включите/выключите автоматическую модерацию

## 🔒 Безопасность

### Обязательные действия
1. **Измените SECRET_KEY** - критично для безопасности
2. **Используйте HTTPS** - обязательно на продакшене
3. **Настройте права доступа**:
```bash
chmod 755 uploads/
chmod 644 includes/config.php
chown -R www-data:www-data uploads/
```

### Дополнительная защита
```php
// В includes/config.php
define('LOGIN_ATTEMPTS_LIMIT', 5);        // Лимит попыток входа
define('LOGIN_TIMEOUT', 900);             // Таймаут блокировки (15 мин)
define('PASSWORD_MIN_LENGTH', 8);         // Минимальная длина пароля
```

## 📱 Мобильная адаптация

### Настройки
- Мобильная адаптация включена по умолчанию
- Все страницы адаптивны
- Touch-friendly интерфейс

### Проверка
1. Откройте сайт на мобильном устройстве
2. Проверьте навигацию и формы
3. Убедитесь, что все элементы кликабельны

## 🆘 Решение проблем

### Ошибка подключения к БД
```
Проверьте настройки в includes/config.php
Убедитесь, что MySQL запущен
Проверьте права доступа пользователя БД
```

### Ошибка загрузки файлов
```
Проверьте права доступа папки uploads/
Увеличьте лимиты в php.ini:
upload_max_filesize = 50M
post_max_size = 50M
```

### Не работает .htaccess
```
Включите mod_rewrite в Apache
Проверьте настройки AllowOverride
Перезапустите Apache
```

### Ошибки 500
```
Проверьте логи ошибок PHP
Включите display_errors для отладки
Проверьте синтаксис PHP файлов
```

## 📞 Поддержка

### Контакты
- **Email**: support@your-domain.com
- **Telegram**: @your_support_bot
- **Discord**: [Сервер поддержки]

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
```

---

## ✅ Чек-лист установки

- [ ] Загружены файлы на сервер
- [ ] Создана база данных
- [ ] Импортирована структура БД
- [ ] Настроен `includes/config.php`
- [ ] Установлены права доступа
- [ ] Изменено название сайта
- [ ] Заменен логотип
- [ ] Настроена цветовая схема
- [ ] Создан администратор
- [ ] Проверена работа сайта
- [ ] Настроена тема оформления
- [ ] Проверена мобильная версия

**Готово!** Ваш сайт для плагинов Rust работает! 🚀

---

*ВАШЕ НАЗВАНИЕ v2.0 - Лучшая платформа для плагинов Rust* 