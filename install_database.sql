-- =====================================================
-- ПОЛНАЯ УСТАНОВКА БАЗЫ ДАННЫХ ВАШЕ НАЗВАНИЕ
-- =====================================================

-- Создание базы данных (раскомментируйте если нужно)
-- CREATE DATABASE IF NOT EXISTS rustforum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE rustforum;

-- =====================================================
-- ОСНОВНЫЕ ТАБЛИЦЫ
-- =====================================================

-- Таблица пользователей
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255),
    bio TEXT,
    website VARCHAR(255),
    discord VARCHAR(50),
    steam_id VARCHAR(50),
    balance DECIMAL(10,2) DEFAULT 0.00,
    reputation INT DEFAULT 100,
    is_admin BOOLEAN DEFAULT FALSE,
    is_moderator BOOLEAN DEFAULT FALSE,
    email_notifications BOOLEAN DEFAULT TRUE,
    comment_notifications BOOLEAN DEFAULT TRUE,
    download_notifications BOOLEAN DEFAULT FALSE,
    purchase_notifications BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_admin (is_admin),
    INDEX idx_moderator (is_moderator)
);

-- Таблица категорий плагинов
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#007bff',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_active (is_active),
    INDEX idx_sort (sort_order)
);

-- Таблица плагинов
CREATE TABLE plugins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    author_id INT NOT NULL,
    category_id INT,
    file_path VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    version VARCHAR(20) DEFAULT '1.0.0',
    price DECIMAL(10,2) DEFAULT 0.00,
    rust_version VARCHAR(20),
    dependencies TEXT,
    changelog TEXT,
    commands TEXT,
    permissions TEXT,
    configuration TEXT,
    downloads INT DEFAULT 0,
    moderated_by INT,
    moderated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (moderated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_author (author_id),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at),
    INDEX idx_downloads (downloads)
);

-- Таблица тегов
CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    color VARCHAR(7) DEFAULT '#6c757d',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- Таблица связи плагинов и тегов
CREATE TABLE plugin_tags (
    plugin_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (plugin_id, tag_id),
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Таблица комментариев
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plugin_id INT NOT NULL,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_plugin (plugin_id),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
);

-- Таблица рейтингов
CREATE TABLE ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plugin_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_rating (plugin_id, user_id),
    INDEX idx_plugin (plugin_id),
    INDEX idx_user (user_id)
);

-- Таблица загрузок
CREATE TABLE downloads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plugin_id INT NOT NULL,
    user_id INT,
    ip_address VARCHAR(45),
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_plugin (plugin_id),
    INDEX idx_user (user_id),
    INDEX idx_downloaded (downloaded_at)
);

-- Таблица избранного
CREATE TABLE favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plugin_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, plugin_id),
    INDEX idx_user (user_id),
    INDEX idx_plugin (plugin_id)
);

-- Таблица покупок
CREATE TABLE purchases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plugin_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    UNIQUE KEY unique_purchase (user_id, plugin_id),
    INDEX idx_user (user_id),
    INDEX idx_plugin (plugin_id),
    INDEX idx_purchased (purchased_at)
);

-- Таблица транзакций
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_user_id INT,
    to_user_id INT,
    amount DECIMAL(10,2) NOT NULL,
    type ENUM('deposit', 'withdrawal', 'purchase', 'donation', 'refund') NOT NULL,
    message TEXT,
    status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_from_user (from_user_id),
    INDEX idx_to_user (to_user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
);

-- Таблица уведомлений
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id INT,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (type),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at)
);

-- Таблица типов уведомлений
CREATE TABLE notification_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица модерации
CREATE TABLE moderation_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plugin_id INT NOT NULL,
    moderator_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (moderator_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_plugin (plugin_id),
    INDEX idx_moderator (moderator_id),
    INDEX idx_created (created_at)
);

-- Таблица API ключей
CREATE TABLE api_keys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    api_key VARCHAR(64) NOT NULL UNIQUE,
    last_used TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_key (api_key)
);

-- Таблица активности
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
);

-- =====================================================
-- ФОРУМ
-- =====================================================

-- Таблица категорий форума
CREATE TABLE forum_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#007bff',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_active (is_active),
    INDEX idx_sort (sort_order)
);

-- Таблица тем форума
CREATE TABLE forum_topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    views INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES forum_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_category (category_id),
    INDEX idx_author (author_id),
    INDEX idx_created (created_at),
    INDEX idx_pinned (is_pinned)
);

-- Таблица постов форума
CREATE TABLE forum_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    topic_id INT NOT NULL,
    author_id INT NOT NULL,
    content TEXT NOT NULL,
    is_solution BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES forum_topics(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_topic (topic_id),
    INDEX idx_author (author_id),
    INDEX idx_created (created_at)
);

-- =====================================================
-- СОАВТОРЫ ПЛАГИНОВ
-- =====================================================

-- Таблица соавторов плагинов
CREATE TABLE plugin_coauthors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plugin_id INT NOT NULL,
    user_id INT NOT NULL,
    share_percentage DECIMAL(5,2) NOT NULL,
    added_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plugin_id) REFERENCES plugins(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (added_by) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_coauthor (plugin_id, user_id),
    INDEX idx_plugin (plugin_id),
    INDEX idx_user (user_id),
    INDEX idx_added_by (added_by)
);

-- =====================================================
-- ЛИЧНЫЕ ЧАТЫ
-- =====================================================

-- Таблица личных чатов между пользователями
CREATE TABLE private_chats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_chat (user1_id, user2_id),
    INDEX idx_user1 (user1_id),
    INDEX idx_user2 (user2_id),
    INDEX idx_last_message (last_message_at)
);

-- Таблица сообщений в личных чатах
CREATE TABLE private_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    chat_id INT NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chat_id) REFERENCES private_chats(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_chat_created (chat_id, created_at),
    INDEX idx_sender (sender_id),
    INDEX idx_unread (is_read)
);

-- =====================================================
-- РЕФЕРАЛЬНАЯ СИСТЕМА
-- =====================================================

-- Таблица рефералов
CREATE TABLE referrals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    referrer_id INT NOT NULL,
    referred_id INT NOT NULL,
    level INT DEFAULT 1,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (referrer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (referred_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_referral (referrer_id, referred_id),
    INDEX idx_referrer (referrer_id),
    INDEX idx_referred (referred_id),
    INDEX idx_level (level)
);

-- Таблица реферальных уровней и наград
CREATE TABLE referral_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level INT NOT NULL,
    min_referrals INT NOT NULL,
    referrer_percent DECIMAL(5,2) NOT NULL,
    referred_bonus_percent DECIMAL(5,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_level (level)
);

-- =====================================================
-- ПРОМОКОДЫ
-- =====================================================

-- Таблица промокодов
CREATE TABLE promo_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    type ENUM('deposit', 'discount', 'bonus') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    min_deposit DECIMAL(10,2) DEFAULT 0.00,
    max_uses INT DEFAULT NULL,
    used_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NULL,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_code (code),
    INDEX idx_active (is_active),
    INDEX idx_expires (expires_at)
);

-- Таблица использования промокодов
CREATE TABLE promo_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promo_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promo_id) REFERENCES promo_codes(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_promo_user (promo_id, user_id),
    INDEX idx_used_at (used_at)
);

-- =====================================================
-- ТЕМЫ ОФОРМЛЕНИЯ
-- =====================================================

-- Таблица тем оформления
CREATE TABLE themes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    css_variables TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ В ТАБЛИЦЕ ПОЛЬЗОВАТЕЛЕЙ
-- =====================================================

-- Добавляем поле реферального кода в таблицу пользователей
ALTER TABLE users ADD COLUMN referral_code VARCHAR(20) UNIQUE;
ALTER TABLE users ADD COLUMN referred_by INT;
ALTER TABLE users ADD COLUMN theme_id INT DEFAULT 1;
ALTER TABLE users ADD COLUMN referral_level INT DEFAULT 1;
ALTER TABLE users ADD COLUMN total_referrals INT DEFAULT 0;
ALTER TABLE users ADD COLUMN active_referrals INT DEFAULT 0;

-- Добавляем внешние ключи
ALTER TABLE users ADD FOREIGN KEY (referred_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE users ADD FOREIGN KEY (theme_id) REFERENCES themes(id) ON DELETE SET NULL;

-- Добавляем индексы
ALTER TABLE users ADD INDEX idx_referral_code (referral_code);
ALTER TABLE users ADD INDEX idx_referred_by (referred_by);
ALTER TABLE users ADD INDEX idx_theme (theme_id);

-- =====================================================
-- БАЗОВЫЕ ДАННЫЕ
-- =====================================================

-- Вставляем базовые категории плагинов
INSERT INTO categories (name, description, icon, color, sort_order) VALUES
('Экономика', 'Плагины для экономики сервера', 'fas fa-coins', '#28a745', 1),
('Администрирование', 'Инструменты для администраторов', 'fas fa-shield-alt', '#dc3545', 2),
('Игровой процесс', 'Улучшения игрового процесса', 'fas fa-gamepad', '#007bff', 3),
('Безопасность', 'Системы безопасности и античит', 'fas fa-lock', '#6f42c1', 4),
('Интеграции', 'Интеграции с внешними сервисами', 'fas fa-plug', '#fd7e14', 5),
('Утилиты', 'Полезные утилиты и инструменты', 'fas fa-tools', '#20c997', 6),
('Развлечения', 'Развлекательные плагины', 'fas fa-smile', '#e83e8c', 7),
('Другое', 'Прочие плагины', 'fas fa-ellipsis-h', '#6c757d', 8);

-- Вставляем базовые теги
INSERT INTO tags (name, color) VALUES
('Экономика', '#28a745'),
('Админ', '#dc3545'),
('Игровой процесс', '#007bff'),
('Безопасность', '#6f42c1'),
('Интеграция', '#fd7e14'),
('Утилита', '#20c997'),
('Развлечения', '#e83e8c'),
('Новый', '#ffc107'),
('Популярный', '#e83e8c'),
('Обновленный', '#17a2b8');

-- Вставляем базовые категории форума
INSERT INTO forum_categories (name, description, icon, color, sort_order) VALUES
('Общие обсуждения', 'Общие вопросы и обсуждения', 'fas fa-comments', '#007bff', 1),
('Техническая поддержка', 'Помощь с плагинами и настройкой', 'fas fa-wrench', '#28a745', 2),
('Предложения', 'Предложения по улучшению платформы', 'fas fa-lightbulb', '#ffc107', 3),
('Баги и ошибки', 'Сообщения об ошибках', 'fas fa-bug', '#dc3545', 4),
('Новости', 'Новости и анонсы', 'fas fa-newspaper', '#17a2b8', 5),
('Хакатоны и события', 'Обсуждение событий и хакатонов', 'fas fa-calendar', '#e83e8c', 6);

-- Вставляем базовые реферальные уровни
INSERT INTO referral_levels (level, min_referrals, referrer_percent, referred_bonus_percent, description) VALUES
(1, 0, 2.00, 2.00, 'Базовый уровень - 2% с пополнений реферала'),
(2, 10, 5.00, 5.00, 'Продвинутый уровень - 5% с пополнений реферала');

-- Вставляем базовые темы
INSERT INTO themes (name, display_name, css_variables, is_default) VALUES
('light', 'Светлая', '--primary-color: #007bff; --secondary-color: #6c757d; --background-color: #ffffff; --text-color: #212529; --border-color: #dee2e6; --card-bg: #ffffff; --navbar-bg: #343a40; --navbar-text: #ffffff;', TRUE),
('dark', 'Тёмная', '--primary-color: #0d6efd; --secondary-color: #6c757d; --background-color: #212529; --text-color: #f8f9fa; --border-color: #495057; --card-bg: #343a40; --navbar-bg: #000000; --navbar-text: #ffffff;', FALSE),
('neon', 'Неоновая', '--primary-color: #00ff41; --secondary-color: #ff00ff; --background-color: #0a0a0a; --text-color: #00ff41; --border-color: #00ff41; --card-bg: #1a1a1a; --navbar-bg: #000000; --navbar-text: #00ff41;', FALSE),
('cyan', 'Циановая', '--primary-color: #00ffff; --secondary-color: #008b8b; --background-color: #001a1a; --text-color: #00ffff; --border-color: #00ffff; --card-bg: #002626; --navbar-bg: #000000; --navbar-text: #00ffff;', FALSE),
('purple', 'Фиолетовая', '--primary-color: #8a2be2; --secondary-color: #9370db; --background-color: #1a0a2e; --text-color: #e6e6fa; --border-color: #8a2be2; --card-bg: #2a1a3e; --navbar-bg: #000000; --navbar-text: #8a2be2;', FALSE),
('sunset', 'Закатная', '--primary-color: #ff6b35; --secondary-color: #f7931e; --background-color: #2c1810; --text-color: #fff5e6; --border-color: #ff6b35; --card-bg: #3c2810; --navbar-bg: #1a0f0a; --navbar-text: #ff6b35;', FALSE);

-- Добавляем 10 новых тем оформления
INSERT INTO themes (name, description, css_variables, is_active) VALUES
('Classic Light', 'Классическая светлая тема', '--primary-color: #007bff; --secondary-color: #6c757d; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #f8f9fa; --dark-color: #343a40; --body-bg: #ffffff; --text-color: #212529; --card-bg: #ffffff; --navbar-bg: #343a40; --border-color: #dee2e6;', 1),
('Dark Pro', 'Современная темная тема', '--primary-color: #0d6efd; --secondary-color: #6c757d; --success-color: #198754; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #0dcaf0; --light-color: #f8f9fa; --dark-color: #212529; --body-bg: #1a1a1a; --text-color: #ffffff; --card-bg: #2d2d2d; --navbar-bg: #000000; --border-color: #404040;', 1),
('Neon Cyber', 'Неоновая киберпанк тема', '--primary-color: #00ffff; --secondary-color: #ff00ff; --success-color: #00ff00; --danger-color: #ff0066; --warning-color: #ffff00; --info-color: #0099ff; --light-color: #1a1a1a; --dark-color: #000000; --body-bg: #0a0a0a; --text-color: #00ffff; --card-bg: #1a1a1a; --navbar-bg: #000000; --border-color: #00ffff;', 1),
('Ocean Blue', 'Морская синяя тема', '--primary-color: #0066cc; --secondary-color: #4d94ff; --success-color: #00cc99; --danger-color: #ff6666; --warning-color: #ffcc00; --info-color: #66ccff; --light-color: #e6f3ff; --dark-color: #003366; --body-bg: #f0f8ff; --text-color: #003366; --card-bg: #ffffff; --navbar-bg: #0066cc; --border-color: #b3d9ff;', 1),
('Forest Green', 'Лесная зеленая тема', '--primary-color: #2d5016; --secondary-color: #4a7c59; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #f0f8f0; --dark-color: #1a3d1a; --body-bg: #f8fff8; --text-color: #1a3d1a; --card-bg: #ffffff; --navbar-bg: #2d5016; --border-color: #c8e6c9;', 1),
('Sunset Orange', 'Закатная оранжевая тема', '--primary-color: #ff6600; --secondary-color: #ff9933; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #fff5f0; --dark-color: #cc5200; --body-bg: #fffaf5; --text-color: #cc5200; --card-bg: #ffffff; --navbar-bg: #ff6600; --border-color: #ffd6b3;', 1),
('Purple Dream', 'Фиолетовая мечта', '--primary-color: #6a0dad; --secondary-color: #9b59b6; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #f8f0ff; --dark-color: #4a0d7a; --body-bg: #faf5ff; --text-color: #4a0d7a; --card-bg: #ffffff; --navbar-bg: #6a0dad; --border-color: #e6d9ff;', 1),
('Steel Gray', 'Стальная серая тема', '--primary-color: #4a4a4a; --secondary-color: #6c757d; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #f8f9fa; --dark-color: #2d2d2d; --body-bg: #f5f5f5; --text-color: #2d2d2d; --card-bg: #ffffff; --navbar-bg: #4a4a4a; --border-color: #d9d9d9;', 1),
('Candy Pink', 'Конфетная розовая тема', '--primary-color: #ff69b4; --secondary-color: #ffb6c1; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #fff0f5; --dark-color: #cc5588; --body-bg: #fffafb; --text-color: #cc5588; --card-bg: #ffffff; --navbar-bg: #ff69b4; --border-color: #ffd6e7;', 1),
('Golden Luxury', 'Золотая люксовая тема', '--primary-color: #ffd700; --secondary-color: #daa520; --success-color: #28a745; --danger-color: #dc3545; --warning-color: #ffc107; --info-color: #17a2b8; --light-color: #fffbf0; --dark-color: #b8860b; --body-bg: #fffef7; --text-color: #b8860b; --card-bg: #ffffff; --navbar-bg: #ffd700; --border-color: #ffe6b3;', 1);

-- Вставляем типы уведомлений
INSERT INTO notification_types (type, description) VALUES
('plugin_status', 'Изменение статуса плагина'),
('plugin_comment', 'Новый комментарий к плагину'),
('plugin_rating', 'Новая оценка плагина'),
('plugin_download', 'Загрузка плагина'),
('plugin_purchase', 'Покупка плагина'),
('donation', 'Получение доната'),
('private_message', 'Личное сообщение от пользователя'),
('referral_bonus', 'Реферальный бонус'),
('promo_bonus', 'Бонус по промокоду');

-- Создаем администратора по умолчанию
INSERT INTO users (username, email, password, is_admin, is_moderator, referral_code) VALUES
('admin', 'admin@your-domain.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', TRUE, TRUE, 'ADMIN001');

-- Генерируем реферальные коды для существующих пользователей
UPDATE users SET referral_code = CONCAT('REF', LPAD(id, 6, '0')) WHERE referral_code IS NULL;

-- =====================================================
-- СООБЩЕНИЕ О УСПЕШНОЙ УСТАНОВКЕ
-- =====================================================

-- Выводим информацию о созданных таблицах
SELECT 'База данных ВАШЕ НАЗВАНИЕ успешно создана!' as message;
SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = DATABASE();
SELECT 'Пароль администратора по умолчанию: password' as admin_info; 

-- Система достижений
CREATE TABLE achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100) DEFAULT 'fas fa-trophy',
    category ENUM('activity', 'plugins', 'community', 'special') DEFAULT 'activity',
    points INT DEFAULT 10,
    requirements JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    progress INT DEFAULT 0,
    completed_at TIMESTAMP NULL,
    is_claimed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_achievement (user_id, achievement_id)
);

-- Премиум подписка
CREATE TABLE premium_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_type ENUM('monthly', 'yearly') DEFAULT 'monthly',
    status ENUM('active', 'cancelled', 'expired') DEFAULT 'active',
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    payment_method VARCHAR(100),
    amount DECIMAL(10,2) DEFAULT 399.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Подписки на авторов
CREATE TABLE author_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    author_id INT NOT NULL,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscriber_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subscription (subscriber_id, author_id)
);

-- Расширенная аналитика
CREATE TABLE analytics_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer VARCHAR(500),
    page_url VARCHAR(500),
    session_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_event (user_id, event_type)
);

CREATE TABLE analytics_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    duration INT NULL,
    page_views INT DEFAULT 0,
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_type ENUM('desktop', 'mobile', 'tablet') DEFAULT 'desktop',
    browser VARCHAR(100),
    os VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- AI модерация
CREATE TABLE ai_moderation_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content_type ENUM('plugin', 'comment', 'forum_post', 'user') NOT NULL,
    content_id INT NOT NULL,
    user_id INT NULL,
    ai_score DECIMAL(3,2) NOT NULL,
    ai_decision ENUM('approve', 'reject', 'review') NOT NULL,
    ai_reason TEXT,
    moderator_id INT NULL,
    final_decision ENUM('approve', 'reject', 'pending') NULL,
    moderator_comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (moderator_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_content (content_type, content_id),
    INDEX idx_ai_score (ai_score)
);

-- Дополнительные поля для пользователей
ALTER TABLE users 
ADD COLUMN premium_until TIMESTAMP NULL,
ADD COLUMN total_points INT DEFAULT 0,
ADD COLUMN level INT DEFAULT 1,
ADD COLUMN experience INT DEFAULT 0,
ADD COLUMN subscription_count INT DEFAULT 0,
ADD COLUMN followers_count INT DEFAULT 0,
ADD COLUMN last_activity TIMESTAMP NULL,
ADD COLUMN timezone VARCHAR(50) DEFAULT 'Europe/Moscow',
ADD COLUMN language VARCHAR(10) DEFAULT 'ru',
ADD COLUMN notification_preferences JSON;

-- Дополнительные поля для плагинов
ALTER TABLE plugins 
ADD COLUMN ai_score DECIMAL(3,2) NULL,
ADD COLUMN ai_checked BOOLEAN DEFAULT FALSE,
ADD COLUMN premium_only BOOLEAN DEFAULT FALSE,
ADD COLUMN featured BOOLEAN DEFAULT FALSE,
ADD COLUMN trending_score DECIMAL(5,2) DEFAULT 0.00,
ADD COLUMN seo_title VARCHAR(255),
ADD COLUMN seo_description TEXT,
ADD COLUMN seo_keywords TEXT,
ADD COLUMN view_count INT DEFAULT 0,
ADD COLUMN unique_visitors INT DEFAULT 0;

-- Дополнительные поля для комментариев
ALTER TABLE comments 
ADD COLUMN ai_score DECIMAL(3,2) NULL,
ADD COLUMN ai_checked BOOLEAN DEFAULT FALSE,
ADD COLUMN is_edited BOOLEAN DEFAULT FALSE,
ADD COLUMN edited_at TIMESTAMP NULL,
ADD COLUMN edit_reason VARCHAR(255);

-- Лента активности
CREATE TABLE activity_feed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_type VARCHAR(100) NOT NULL,
    target_type VARCHAR(50) NULL,
    target_id INT NULL,
    data JSON,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_activity (user_id, created_at),
    INDEX idx_activity_type (activity_type)
);

-- SEO мета-теги
CREATE TABLE seo_meta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    page_type VARCHAR(100) NOT NULL,
    page_id INT NULL,
    title VARCHAR(255),
    description TEXT,
    keywords TEXT,
    og_title VARCHAR(255),
    og_description TEXT,
    og_image VARCHAR(500),
    canonical_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_page (page_type, page_id)
);

-- Базовые достижения
INSERT INTO achievements (name, description, icon, category, points, requirements) VALUES
('Первый плагин', 'Загрузите свой первый плагин', 'fas fa-upload', 'plugins', 50, '{"plugins_count": 1}'),
('Популярный автор', 'Получите 100 загрузок ваших плагинов', 'fas fa-star', 'plugins', 100, '{"total_downloads": 100}'),
('Активный участник', 'Оставьте 10 комментариев', 'fas fa-comments', 'community', 30, '{"comments_count": 10}'),
('Эксперт', 'Получите средний рейтинг 4.5+ на ваших плагинах', 'fas fa-crown', 'plugins', 200, {"avg_rating": 4.5}'),
('Социальная бабочка', 'Подпишитесь на 5 авторов', 'fas fa-users', 'community', 25, {"subscriptions_count": 5}'),
('Критик', 'Оставьте 20 оценок плагинам', 'fas fa-thumbs-up', 'community', 40, {"ratings_count": 20}),
('Ветеран', 'На сайте более 30 дней', 'fas fa-calendar', 'activity', 75, {"days_registered": 30}),
('Богач', 'Заработайте 1000 рублей на плагинах', 'fas fa-coins', 'plugins', 150, {"total_earnings": 1000}),
('Трендсеттер', 'Создайте плагин, который стал трендовым', 'fas fa-fire', 'special', 300, {"trending_plugin": true}),
('Премиум пользователь', 'Оформите премиум подписку', 'fas fa-gem', 'special', 100, {"premium_subscription": true});

-- SEO мета-теги для основных страниц
INSERT INTO seo_meta (page_type, title, description, keywords) VALUES
('home', 'ВАШЕ НАЗВАНИЕ - Лучшая платформа для плагинов Rust', 'Найдите качественные плагины для Rust, делитесь своими разработками и развивайте сообщество. Маркетплейс плагинов, форум и многое другое.', 'Rust, плагины, плагины Rust, форум, маркетплейс, разработка'),
('plugins', 'Плагины Rust - Каталог плагинов ВАШЕ НАЗВАНИЕ', 'Большой каталог плагинов для Rust. Фильтры по категориям, рейтингам и функциям. Скачивайте бесплатно или покупайте премиум плагины.', 'плагины Rust, скачать плагины, Rust plugins, моды Rust'),
('forum', 'Форум Rust - Обсуждения и помощь ВАШЕ НАЗВАНИЕ', 'Форум сообщества Rust. Обсуждения плагинов, помощь новичкам, обмен опытом и новости игровой индустрии.', 'форум Rust, обсуждения, помощь, сообщество'),
('marketplace', 'Маркетплейс плагинов Rust - Покупка и продажа', 'Маркетплейс плагинов для Rust. Покупайте качественные плагины у проверенных авторов или продавайте свои разработки.', 'маркетплейс, покупка плагинов, продажа плагинов, Rust marketplace'); 