# ⚡ Быстрый старт ВАШЕ НАЗВАНИЕ

## 🚀 Установка за 5 минут

### 1. Загрузите файлы на сервер
### 2. Создайте БД и импортируйте `install_database.sql`
### 3. Настройте `includes/config.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'rustforum');
define('DB_USER', 'rustforum_user');
define('DB_PASS', 'your_password');
define('SITE_URL', 'https://your-domain.com');
define('SITE_NAME', 'Ваше название сайта');
define('SECRET_KEY', 'your_random_32_char_key');
```

### 4. Установите права:
```bash
chmod 755 uploads/
chmod 644 includes/config.php
```

### 5. Зарегистрируйтесь на сайте
### 6. Сделайте себя администратором:
```sql
UPDATE users SET role = 'admin' WHERE id = 1;
```

### 7. Войдите в админку: `https://your-domain.com/admin`

## 🔧 Что изменить

### Название сайта
**Файл:** `includes/config.php`
```php
define('SITE_NAME', 'Ваше название');
define('SITE_DESCRIPTION', 'Описание сайта');
```

### Логотип
**Файл:** `assets/images/logo.png` (200x50px)

### Цвета
**Файл:** `public/css/style.css`
```css
:root {
    --primary-color: #007bff;
    --secondary-color: #6c757d;
}
```

### Платежи
**Файл:** `includes/config.php`
```php
define('PAYMENT_DETAILS', 'QIWI: +7XXXXXXXXXX, ЮMoney: 4100XXXXXXXX');
```

## 📊 Основные функции

- ✅ Регистрация и авторизация
- ✅ Загрузка плагинов
- ✅ Система комментариев
- ✅ Форум
- ✅ Достижения
- ✅ Премиум подписка (399₽/мес)
- ✅ Подписки на авторов
- ✅ 10 тем оформления
- ✅ Мобильная адаптация
- ✅ SEO оптимизация
- ✅ AI модерация
- ✅ Аналитика

## 🔐 Доступ к админке

- **URL:** `https://your-domain.com/admin`
- **Логин:** ваш email/username
- **Пароль:** пароль при регистрации

## 📞 Поддержка

- **Email:** support@your-domain.com
- **Telegram:** @your_support_bot
- **Документация:** README.md, INSTALL.md, ADMIN_INFO.md

---

**Готово!** Ваш сайт для плагинов Rust работает! 🚀

*ВАШЕ НАЗВАНИЕ v2.0 - Быстрый старт* 