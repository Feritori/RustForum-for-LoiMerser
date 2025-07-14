# 🔐 Информация для администратора

## 👨‍💼 Доступ к админ-панели

### URL админ-панели
```
https://your-domain.com/admin
```

### Создание первого администратора
1. Зарегистрируйтесь на сайте как обычный пользователь
2. Войдите в базу данных MySQL:
```bash
mysql -u rustforum_user -p rustforum
```

3. Измените роль первого пользователя:
```sql
UPDATE users SET role = 'admin' WHERE id = 1;
```

4. Войдите в админ-панель используя:
- **Логин:** ваш email или username
- **Пароль:** пароль, который вы указали при регистрации

### Создание дополнительных администраторов
```sql
-- Изменить роль существующего пользователя
UPDATE users SET role = 'admin' WHERE username = 'username';

-- Создать нового администратора
INSERT INTO users (username, email, password, role, created_at) VALUES (
    'admin2',
    'admin2@domain.com',
    '$2y$10$' || SUBSTRING(SHA2(CONCAT('password123', RAND()), 256), 1, 22),
    'admin',
    NOW()
);
```

## 🔧 Критически важные настройки

### 1. Секретный ключ (ОБЯЗАТЕЛЬНО ИЗМЕНИТЬ!)
**Файл:** `includes/config.php`
```php
define('SECRET_KEY', 'your_random_secret_key_here');
```
**Генерируйте случайный ключ длиной 32 символа!**

### 2. Настройки базы данных
**Файл:** `includes/config.php`
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'rustforum');
define('DB_USER', 'rustforum_user');
define('DB_PASS', 'your_strong_password');
```

### 3. URL сайта
**Файл:** `includes/config.php`
```php
define('SITE_URL', 'https://your-domain.com');
```

### 4. Платежные реквизиты
**Файл:** `includes/config.php`
```php
define('PAYMENT_METHOD', 'manual');
define('PAYMENT_DETAILS', 'QIWI: +7XXXXXXXXXX, ЮMoney: 4100XXXXXXXX');
```

## 📊 Структура базы данных

### Основные таблицы
- `users` - пользователи
- `plugins` - плагины
- `categories` - категории
- `comments` - комментарии
- `achievements` - достижения
- `premium_subscriptions` - премиум подписки
- `author_subscriptions` - подписки на авторов
- `transactions` - транзакции
- `themes` - темы оформления

### Просмотр структуры
```sql
-- Показать все таблицы
SHOW TABLES;

-- Показать структуру таблицы
DESCRIBE users;
DESCRIBE plugins;
```

## 🛠 Полезные SQL запросы

### Статистика сайта
```sql
-- Количество пользователей
SELECT COUNT(*) as total_users FROM users;

-- Количество плагинов
SELECT COUNT(*) as total_plugins FROM plugins;

-- Количество премиум пользователей
SELECT COUNT(*) as premium_users FROM premium_subscriptions WHERE status = 'active';

-- Топ авторов по плагинам
SELECT u.username, COUNT(p.id) as plugins_count 
FROM users u 
JOIN plugins p ON u.id = p.author_id 
GROUP BY u.id 
ORDER BY plugins_count DESC 
LIMIT 10;
```

### Управление пользователями
```sql
-- Заблокировать пользователя
UPDATE users SET status = 'banned' WHERE id = 123;

-- Разблокировать пользователя
UPDATE users SET status = 'active' WHERE id = 123;

-- Изменить роль пользователя
UPDATE users SET role = 'moderator' WHERE id = 123;

-- Удалить пользователя (осторожно!)
DELETE FROM users WHERE id = 123;
```

### Управление плагинами
```sql
-- Одобрить плагин
UPDATE plugins SET status = 'approved' WHERE id = 123;

-- Отклонить плагин
UPDATE plugins SET status = 'rejected' WHERE id = 123;

-- Удалить плагин
DELETE FROM plugins WHERE id = 123;
```

## 🔒 Безопасность

### Обязательные действия
1. **Измените SECRET_KEY** - критично!
2. **Используйте HTTPS** - обязательно
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
define('SESSION_REGENERATE', 300);        // Регенерация сессии (5 мин)
```

### Мониторинг безопасности
```sql
-- Последние попытки входа
SELECT * FROM login_attempts ORDER BY created_at DESC LIMIT 10;

-- Заблокированные пользователи
SELECT * FROM users WHERE status = 'banned';

-- Подозрительная активность
SELECT * FROM activity_logs WHERE action = 'failed_login' ORDER BY created_at DESC LIMIT 10;
```

## 📈 Мониторинг и аналитика

### Ключевые метрики
```sql
-- Активность за последние 7 дней
SELECT DATE(created_at) as date, COUNT(*) as activity
FROM activity_logs 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(created_at)
ORDER BY date;

-- Популярные плагины
SELECT p.title, p.downloads, u.username
FROM plugins p 
JOIN users u ON p.author_id = u.id 
ORDER BY p.downloads DESC 
LIMIT 10;

-- Доходы от премиум подписок
SELECT SUM(amount) as total_revenue 
FROM transactions 
WHERE type = 'premium_subscription' 
AND status = 'completed';
```

### Логи и отладка
```bash
# Логи Apache
tail -f /var/log/apache2/error.log

# Логи PHP
tail -f /var/log/php_errors.log

# Логи MySQL
tail -f /var/log/mysql/error.log
```

## 🎨 Настройка дизайна

### Изменение темы
```sql
-- Активировать тему
UPDATE themes SET is_active = 1 WHERE id = 1;

-- Создать новую тему
INSERT INTO themes (name, description, css_variables, is_active) VALUES (
    'Моя тема',
    'Описание темы',
    '{"--primary-color": "#ff6b6b", "--secondary-color": "#4ecdc4"}',
    1
);
```

### Настройка цветов
**Файл:** `public/css/style.css`
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

## 🆘 Экстренные действия

### Восстановление доступа к админке
```sql
-- Создать нового администратора
INSERT INTO users (username, email, password, role, created_at) VALUES (
    'emergency_admin',
    'emergency@domain.com',
    '$2y$10$' || SUBSTRING(SHA2(CONCAT('emergency_password', RAND()), 256), 1, 22),
    'admin',
    NOW()
);
```

### Резервное копирование
```bash
# Создать резервную копию БД
mysqldump -u rustforum_user -p rustforum > backup_$(date +%Y%m%d_%H%M%S).sql

# Создать резервную копию файлов
tar -czf backup_files_$(date +%Y%m%d_%H%M%S).tar.gz uploads/ assets/ includes/
```

### Восстановление из резервной копии
```bash
# Восстановить БД
mysql -u rustforum_user -p rustforum < backup_20231201_120000.sql

# Восстановить файлы
tar -xzf backup_files_20231201_120000.tar.gz
```

## 📞 Контакты для поддержки

### Техническая поддержка
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
rm -rf public/cache/*

# Проверка PHP
php -v
php -m | grep -E "(mysqli|json|mbstring|gd)"
```

---

## ✅ Чек-лист безопасности

- [ ] Изменен SECRET_KEY
- [ ] Настроен HTTPS
- [ ] Установлены правильные права доступа
- [ ] Создан администратор
- [ ] Настроены платежные реквизиты
- [ ] Проверены логи ошибок
- [ ] Создана резервная копия
- [ ] Настроен мониторинг

**Важно:** Регулярно проверяйте логи и обновляйте систему!

---

*ВАШЕ НАЗВАНИЕ v2.0 - Административная информация* 