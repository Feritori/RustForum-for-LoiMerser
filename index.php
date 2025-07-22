<?php
require_once '../includes/config.php';
require_once '../includes/functions.php';

// Обработка POST запросов
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'register':
            $username = trim($_POST['username'] ?? '');
            $email = trim($_POST['email'] ?? '');
            $password = $_POST['password'] ?? '';
            $referral_code = trim($_POST['referral_code'] ?? '');
            
            if ($username && $email && $password) {
                $result = registerUser($username, $email, $password, $referral_code);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'] . ' Теперь вы можете войти в систему.';
                    header('Location: /public/index.php?page=login');
                    exit;
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Заполните все обязательные поля';
            }
            break;
            
        case 'login':
            $username = $_POST['username'] ?? '';
            $password = $_POST['password'] ?? '';
            
            if (loginUser($username, $password)) {
                $_SESSION['message'] = 'Добро пожаловать!';
                header('Location: /');
                exit;
            } else {
                $_SESSION['error'] = 'Неверное имя пользователя или пароль.';
            }
            break;
            
        case 'logout':
            logoutUser();
            header('Location: /public/logout.php');
            exit;
            
        case 'add_plugin':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            // Проверка файла
            if (!isset($_FILES['plugin_file']) || $_FILES['plugin_file']['error'] !== UPLOAD_ERR_OK) {
                $_SESSION['error'] = 'Необходимо загрузить файл .zip или .rar';
                break;
            }
            $ext = strtolower(pathinfo($_FILES['plugin_file']['name'], PATHINFO_EXTENSION));
            if (!in_array($ext, ['zip', 'rar'])) {
                $_SESSION['error'] = 'Разрешены только файлы .zip или .rar';
                break;
            }
            
            $title = $_POST['title'] ?? '';
            $description = $_POST['description'] ?? '';
            $category_id = $_POST['category_id'] ?? '';
            $version = $_POST['version'] ?? '1.0.0';
            $price = $_POST['price'] ?? 0;
            $rust_version = $_POST['rust_version'] ?? '';
            $dependencies = $_POST['dependencies'] ?? '';
            $changelog = $_POST['changelog'] ?? '';
            $tags = $_POST['tags'] ?? [];
            
            $file_path = null;
            if (isset($_FILES['plugin_file']) && $_FILES['plugin_file']['error'] === UPLOAD_ERR_OK) {
                $file_path = uploadFile($_FILES['plugin_file']);
            }
            
            $plugin_id = addPlugin($title, $description, $_SESSION['user_id'], $category_id, $file_path, $tags, $version, $price, $rust_version, $dependencies, $changelog, $commands, $permissions, $configuration);
            
            if ($plugin_id) {
                // Обновляем дополнительные поля
                $stmt = $pdo->prepare("UPDATE plugins SET version = ?, price = ?, rust_version = ?, dependencies = ?, changelog = ? WHERE id = ?");
                $stmt->execute([$version, $price, $rust_version, $dependencies, $changelog, $plugin_id]);
                
                $_SESSION['message'] = 'Плагин успешно добавлен и отправлен на модерацию!';
                header('Location: /');
                exit;
            } else {
                $_SESSION['error'] = 'Ошибка добавления плагина.';
            }
            break;
            
        case 'add_comment':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_GET['id'] ?? '';
            $text = $_POST['comment_text'] ?? '';
            
            if (addComment($plugin_id, $_SESSION['user_id'], $text)) {
                $_SESSION['message'] = 'Комментарий добавлен!';
            } else {
                $_SESSION['error'] = 'Ошибка добавления комментария.';
            }
            break;
            
        case 'rate_plugin':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_GET['id'] ?? '';
            $rating = $_POST['rating'] ?? 0;
            
            if (addRating($plugin_id, $_SESSION['user_id'], $rating)) {
                $_SESSION['message'] = 'Оценка добавлена!';
            } else {
                $_SESSION['error'] = 'Ошибка добавления оценки.';
            }
            break;
            
        case 'add_favorite':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? $_GET['id'] ?? '';
            
            if (addToFavorites($_SESSION['user_id'], $plugin_id)) {
                $_SESSION['message'] = 'Добавлено в избранное!';
            } else {
                $_SESSION['error'] = 'Ошибка добавления в избранное.';
            }
            break;
            
        case 'remove_favorite':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? $_GET['id'] ?? '';
            
            if (removeFromFavorites($_SESSION['user_id'], $plugin_id)) {
                $_SESSION['message'] = 'Удалено из избранного!';
            } else {
                $_SESSION['error'] = 'Ошибка удаления из избранного.';
            }
            break;
            
        case 'purchase_plugin':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_GET['id'] ?? '';
            
            if (purchasePlugin($_SESSION['user_id'], $plugin_id)) {
                $_SESSION['message'] = 'Плагин успешно куплен!';
            } else {
                $_SESSION['error'] = 'Ошибка покупки плагина. Возможно, недостаточно средств или плагин уже куплен.';
            }
            break;
            
        case 'donate':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_GET['id'] ?? '';
            $amount = $_POST['amount'] ?? 0;
            $message = $_POST['message'] ?? '';
            
            $plugin = getPluginById($plugin_id);
            if ($plugin && $plugin['author_id'] != $_SESSION['user_id']) {
                if (addDonation($_SESSION['user_id'], $plugin['author_id'], $amount, $message)) {
                    $_SESSION['message'] = 'Донат успешно отправлен!';
                } else {
                    $_SESSION['error'] = 'Ошибка отправки доната. Возможно, недостаточно средств.';
                }
            } else {
                $_SESSION['error'] = 'Невозможно отправить донат.';
            }
            break;
            
        case 'approve_plugin':
            if (!isAdmin() && !isModerator()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? '';
            $comment = $_POST['moderation_comment'] ?? '';
            
            if (updatePluginStatus($plugin_id, 'approved', $_SESSION['user_id'], $comment)) {
                $_SESSION['message'] = 'Плагин одобрен!';
            } else {
                $_SESSION['error'] = 'Ошибка одобрения плагина.';
            }
            header('Location: /public/index.php?page=admin');
            exit;
            
        case 'reject_plugin':
            if (!isAdmin() && !isModerator()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? '';
            $comment = $_POST['moderation_comment'] ?? '';
            
            if (updatePluginStatus($plugin_id, 'rejected', $_SESSION['user_id'], $comment)) {
                $_SESSION['message'] = 'Плагин отклонен!';
            } else {
                $_SESSION['error'] = 'Ошибка отклонения плагина.';
            }
            header('Location: /public/index.php?page=admin');
            exit;
            
        case 'delete_comment':
            if (!isAdmin() && !isModerator()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $comment_id = $_POST['comment_id'] ?? '';
            
            $stmt = $pdo->prepare("DELETE FROM comments WHERE id = ?");
            if ($stmt->execute([$comment_id])) {
                $_SESSION['message'] = 'Комментарий удален!';
            } else {
                $_SESSION['error'] = 'Ошибка удаления комментария.';
            }
            break;
            
        case 'mark_notification_read':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $notification_id = $_POST['notification_id'] ?? '';
            
            if (markNotificationAsRead($notification_id)) {
                $_SESSION['message'] = 'Уведомление отмечено как прочитанное!';
            } else {
                $_SESSION['error'] = 'Ошибка обновления уведомления.';
            }
            break;
            
        case 'mark_all_notifications_read':
            if (isLoggedIn()) {
                markAllNotificationsAsRead($_SESSION['user_id']);
            }
            exit;
            
        case 'update_profile':
            if (isLoggedIn()) {
                $result = updateUserProfile($_SESSION['user_id'], $_POST);
                if ($result) {
                    $success_message = 'Профиль успешно обновлен';
                } else {
                    $error_message = 'Ошибка обновления профиля';
                }
            }
            break;
            
        case 'upload_avatar':
            if (isLoggedIn() && isset($_FILES['avatar'])) {
                $result = uploadAvatar($_SESSION['user_id'], $_FILES['avatar']);
                if ($result['success']) {
                    $success_message = 'Аватар успешно загружен';
                } else {
                    $error_message = $result['message'];
                }
            }
            break;
            
        case 'change_password':
            if (isLoggedIn()) {
                $result = changePassword($_SESSION['user_id'], $_POST['current_password'], $_POST['new_password']);
                if ($result['success']) {
                    $success_message = $result['message'];
                } else {
                    $error_message = $result['message'];
                }
            }
            break;
            
        case 'update_notifications':
            if (isLoggedIn()) {
                $result = updateNotificationSettings($_SESSION['user_id'], $_POST);
                if ($result) {
                    $success_message = 'Настройки уведомлений обновлены';
                } else {
                    $error_message = 'Ошибка обновления настроек';
                }
            }
            break;
            
        case 'update_privacy':
            if (isLoggedIn()) {
                $result = updatePrivacySettings($_SESSION['user_id'], $_POST);
                if ($result) {
                    $success_message = 'Настройки приватности обновлены';
                } else {
                    $error_message = 'Ошибка обновления настроек';
                }
            }
            break;
            
        case 'create_api_key':
            if (isLoggedIn()) {
                $result = createApiKey($_SESSION['user_id'], $_POST['key_name']);
                if ($result['success']) {
                    $success_message = 'API ключ создан: ' . $result['api_key'];
                } else {
                    $error_message = $result['message'];
                }
            }
            break;
            
        case 'delete_api_key':
            if (isLoggedIn()) {
                $result = deleteApiKey($_SESSION['user_id'], $_POST['key_id']);
                if ($result) {
                    $success_message = 'API ключ удален';
                } else {
                    $error_message = 'Ошибка удаления API ключа';
                }
            }
            break;
            
        case 'withdraw':
            if (isLoggedIn()) {
                $result = withdrawFunds($_SESSION['user_id'], $_POST['amount'], $_POST['method'], $_POST['account']);
                if ($result['success']) {
                    $success_message = $result['message'];
                } else {
                    $error_message = $result['message'];
                }
            }
            break;
            
        case 'update_plugin':
            if (isLoggedIn()) {
                $result = updatePlugin($_POST['plugin_id'], $_SESSION['user_id'], $_POST);
                if ($result) {
                    $success_message = 'Плагин успешно обновлен';
                } else {
                    $error_message = 'Ошибка обновления плагина';
                }
            }
            break;
            
        case 'update_files':
            if (isLoggedIn()) {
                $result = updatePluginFiles($_POST['plugin_id'], $_SESSION['user_id'], $_FILES);
                if ($result) {
                    $success_message = 'Файлы плагина обновлены';
                } else {
                    $error_message = 'Ошибка обновления файлов';
                }
            }
            break;
            
        case 'delete_plugin':
            if (!isAdmin() && !isModerator()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? '';
            
            if (deletePlugin($plugin_id, $_SESSION['user_id'])) {
                $_SESSION['message'] = 'Плагин удален!';
            } else {
                $_SESSION['error'] = 'Ошибка удаления плагина.';
            }
            header('Location: /public/index.php?page=admin');
            exit;
            break;
            
        case 'duplicate_plugin':
            if (isLoggedIn()) {
                $new_plugin_id = duplicatePlugin($_POST['plugin_id'], $_SESSION['user_id']);
                if ($new_plugin_id) {
                    $success_message = 'Плагин успешно скопирован';
                    header("Location: /public/index.php?page=edit_plugin&id=$new_plugin_id");
                    exit;
                } else {
                    $error_message = 'Ошибка копирования плагина';
                }
            }
            break;
        case 'create_topic':
            if (isLoggedIn()) {
                $category_id = $_POST['category_id'] ?? '';
                $title = trim($_POST['title'] ?? '');
                $content = trim($_POST['content'] ?? '');
                if ($category_id && $title && $content) {
                    $topic_id = createForumTopic($category_id, $_SESSION['user_id'], $title, $content);
                    if ($topic_id) {
                        $_SESSION['message'] = 'Тема успешно создана!';
                        header('Location: /public/index.php?page=topic&id=' . $topic_id);
                        exit;
                    } else {
                        $_SESSION['error'] = 'Ошибка создания темы.';
                    }
                } else {
                    $_SESSION['error'] = 'Заполните все поля.';
                }
            } else {
                $_SESSION['error'] = 'Необходимо войти в систему';
            }
            break;
        case 'add_post':
            if (isLoggedIn()) {
                $topic_id = $_GET['id'] ?? '';
                $content = trim($_POST['content'] ?? '');
                if ($topic_id && $content) {
                    if (addForumPost($topic_id, $_SESSION['user_id'], $content)) {
                        $_SESSION['message'] = 'Ответ добавлен!';
                        header('Location: /public/index.php?page=topic&id=' . $topic_id);
                        exit;
                    } else {
                        $_SESSION['error'] = 'Ошибка добавления ответа.';
                    }
                } else {
                    $_SESSION['error'] = 'Заполните сообщение.';
                }
            } else {
                $_SESSION['error'] = 'Необходимо войти в систему';
            }
            break;
            
        case 'add_coauthor':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? '';
            $user_identifier = trim($_POST['user_identifier'] ?? '');
            $share_percentage = floatval($_POST['share_percentage'] ?? 0);
            
            if ($plugin_id && $user_identifier && $share_percentage > 0) {
                $result = addPluginCoauthor($plugin_id, $user_identifier, $share_percentage, $_SESSION['user_id']);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'];
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Заполните все поля корректно';
            }
            break;
            
        case 'remove_coauthor':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plugin_id = $_POST['plugin_id'] ?? '';
            $coauthor_id = $_POST['coauthor_id'] ?? '';
            
            if ($plugin_id && $coauthor_id) {
                $result = removePluginCoauthor($plugin_id, $coauthor_id, $_SESSION['user_id']);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'];
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Ошибка удаления соавтора';
            }
            break;
            
        case 'start_chat':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $username = trim($_POST['username'] ?? '');
            
            if ($username) {
                $user = findUserByUsername($username);
                if ($user) {
                    if ($user['id'] == $_SESSION['user_id']) {
                        $_SESSION['error'] = 'Нельзя начать чат с самим собой';
                    } else {
                        $chat = getOrCreatePrivateChat($_SESSION['user_id'], $user['id']);
                        if ($chat) {
                            header('Location: /public/index.php?page=chat&id=' . $chat['id']);
                            exit;
                        } else {
                            $_SESSION['error'] = 'Ошибка создания чата';
                        }
                    }
                } else {
                    $_SESSION['error'] = 'Пользователь не найден';
                }
            } else {
                $_SESSION['error'] = 'Введите логин пользователя';
            }
            break;
            
        case 'send_private_message':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $chat_id = $_POST['chat_id'] ?? '';
            $message = trim($_POST['message'] ?? '');
            
            if ($chat_id && $message) {
                if (sendPrivateMessage($chat_id, $_SESSION['user_id'], $message)) {
                    $_SESSION['message'] = 'Сообщение отправлено!';
                } else {
                    $_SESSION['error'] = 'Ошибка отправки сообщения.';
                }
            } else {
                $_SESSION['error'] = 'Заполните сообщение.';
            }
            break;
            
        // Новые действия для достижений
        case 'claim_achievement':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $achievement_id = $_POST['achievement_id'] ?? '';
            
            if ($achievement_id) {
                $stmt = $pdo->prepare("UPDATE user_achievements SET is_claimed = 1 WHERE user_id = ? AND achievement_id = ? AND completed_at IS NOT NULL");
                if ($stmt->execute([$_SESSION['user_id'], $achievement_id])) {
                    $_SESSION['message'] = 'Достижение получено!';
                } else {
                    $_SESSION['error'] = 'Ошибка получения достижения.';
                }
            }
            break;
            
        // Премиум подписка
        case 'create_subscription':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $plan = $_POST['plan'] ?? 'monthly';
            $payment_method = $_POST['payment_method'] ?? 'manual';
            
            if (createPremiumSubscription($_SESSION['user_id'], $plan, $payment_method)) {
                $_SESSION['message'] = 'Премиум подписка успешно оформлена!';
            } else {
                $_SESSION['error'] = 'Ошибка оформления подписки.';
            }
            break;
            
        // Подписки на авторов
        case 'subscribe':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $author_id = $_POST['author_id'] ?? '';
            
            if ($author_id) {
                $result = subscribeToAuthor($_SESSION['user_id'], $author_id);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'];
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Не указан автор для подписки.';
            }
            break;
            
        case 'unsubscribe':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $author_id = $_POST['author_id'] ?? '';
            
            if ($author_id) {
                $result = unsubscribeFromAuthor($_SESSION['user_id'], $author_id);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'];
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Не указан автор для отписки.';
            }
            break;
            
        case 'search_authors':
            if (!isLoggedIn()) {
                echo json_encode(['success' => false, 'message' => 'Необходимо войти в систему']);
                exit;
            }
            
            $query = trim($_POST['query'] ?? '');
            
            if ($query) {
                $stmt = $pdo->prepare("SELECT u.*, 
                                      (SELECT COUNT(*) FROM plugins WHERE author_id = u.id AND status = 'approved') as plugins_count
                                      FROM users u 
                                      WHERE (u.username LIKE ? OR u.email LIKE ?) 
                                      AND u.id != ? 
                                      AND u.id NOT IN (SELECT author_id FROM author_subscriptions WHERE subscriber_id = ?)
                                      LIMIT 10");
                $stmt->execute(["%$query%", "%$query%", $_SESSION['user_id'], $_SESSION['user_id']]);
                $authors = $stmt->fetchAll();
                
                echo json_encode(['success' => true, 'authors' => $authors]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Введите запрос для поиска']);
            }
            exit;
            
        // Аналитика
        case 'record_event':
            if (!isLoggedIn()) {
                echo json_encode(['success' => false, 'message' => 'Необходимо войти в систему']);
                exit;
            }
            
            $event_type = $_POST['event_type'] ?? '';
            $event_data = $_POST['event_data'] ?? [];
            
            if ($event_type) {
                if (recordAnalyticsEvent($event_type, $event_data, $_SESSION['user_id'])) {
                    echo json_encode(['success' => true]);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Ошибка записи события']);
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'Не указан тип события']);
            }
            exit;
            
        // AI модерация
        case 'moderate_content':
            if (!isAdmin() && !isModerator()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $content_type = $_POST['content_type'] ?? '';
            $content_id = $_POST['content_id'] ?? '';
            $final_decision = $_POST['final_decision'] ?? '';
            $moderator_comment = $_POST['moderator_comment'] ?? '';
            
            if ($content_type && $content_id && $final_decision) {
                $stmt = $pdo->prepare("UPDATE ai_moderation_logs SET 
                                      final_decision = ?, moderator_id = ?, moderator_comment = ?, processed_at = NOW() 
                                      WHERE content_type = ? AND content_id = ?");
                if ($stmt->execute([$final_decision, $_SESSION['user_id'], $moderator_comment, $content_type, $content_id])) {
                    
                    // Обновляем статус контента
                    if ($content_type === 'plugin') {
                        updatePluginStatus($content_id, $final_decision, $_SESSION['user_id'], $moderator_comment);
                    } elseif ($content_type === 'comment') {
                        $stmt = $pdo->prepare("UPDATE comments SET is_approved = ? WHERE id = ?");
                        $stmt->execute([$final_decision === 'approve' ? 1 : 0, $content_id]);
                    }
                    
                    $_SESSION['message'] = 'Модерация завершена!';
                } else {
                    $_SESSION['error'] = 'Ошибка обновления модерации.';
                }
            } else {
                $_SESSION['error'] = 'Заполните все поля.';
            }
            break;
            
        // SEO обновление
        case 'update_seo':
            if (!isAdmin()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $page_type = $_POST['page_type'] ?? '';
            $page_id = $_POST['page_id'] ?? '';
            $meta_data = [
                'title' => $_POST['title'] ?? '',
                'description' => $_POST['description'] ?? '',
                'keywords' => $_POST['keywords'] ?? '',
                'og_title' => $_POST['og_title'] ?? '',
                'og_description' => $_POST['og_description'] ?? '',
                'og_image' => $_POST['og_image'] ?? '',
                'canonical_url' => $_POST['canonical_url'] ?? ''
            ];
            
            if ($page_type) {
                if (updateSEOMeta($page_type, $page_id, $meta_data)) {
                    $_SESSION['message'] = 'SEO мета-теги обновлены!';
                } else {
                    $_SESSION['error'] = 'Ошибка обновления SEO.';
                }
            } else {
                $_SESSION['error'] = 'Не указан тип страницы.';
            }
            break;
            
        // Генерация sitemap
        case 'generate_sitemap':
            if (!isAdmin()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $sitemap = generateSitemap();
            $sitemap_path = __DIR__ . '/../sitemap.xml';
            
            if (file_put_contents($sitemap_path, $sitemap)) {
                $_SESSION['message'] = 'Sitemap успешно сгенерирован!';
            } else {
                $_SESSION['error'] = 'Ошибка генерации sitemap.';
            }
            break;
            
        case 'delete_chat':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $chat_id = $_POST['chat_id'] ?? '';
            
            if ($chat_id) {
                $result = deletePrivateChat($chat_id, $_SESSION['user_id']);
                if ($result['success']) {
                    $_SESSION['message'] = $result['message'];
                    header('Location: /public/index.php?page=messages');
                    exit;
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Ошибка удаления чата';
            }
            break;
            
        case 'apply_promo':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $promo_code = trim($_POST['promo_code'] ?? '');
            $amount = floatval($_POST['amount'] ?? 0);
            
            if ($promo_code) {
                $result = validatePromoCode($promo_code, $_SESSION['user_id'], $amount);
                if ($result['valid']) {
                    $apply_result = applyPromoCode($result['promo']['id'], $_SESSION['user_id'], $amount);
                    if ($apply_result['success']) {
                        $_SESSION['message'] = "Промокод применен! Получен бонус {$apply_result['bonus']} ₽";
                    } else {
                        $_SESSION['error'] = $apply_result['message'];
                    }
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Введите промокод';
            }
            break;
            
        case 'set_theme':
            if (!isLoggedIn()) {
                $_SESSION['error'] = 'Необходимо войти в систему';
                break;
            }
            
            $theme_id = intval($_POST['theme_id'] ?? 0);
            
            if ($theme_id) {
                if (setUserTheme($_SESSION['user_id'], $theme_id)) {
                    $_SESSION['message'] = 'Тема оформления изменена';
                } else {
                    $_SESSION['error'] = 'Ошибка изменения темы';
                }
            } else {
                $_SESSION['error'] = 'Выберите тему';
            }
            break;
            
        case 'create_referral_level':
            if (!isAdmin()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $level = intval($_POST['level'] ?? 0);
            $min_referrals = intval($_POST['min_referrals'] ?? 0);
            $referrer_percent = floatval($_POST['referrer_percent'] ?? 0);
            $referred_bonus_percent = floatval($_POST['referred_bonus_percent'] ?? 0);
            $description = trim($_POST['description'] ?? '');
            
            if ($level && $min_referrals >= 0 && $referrer_percent >= 0 && $referred_bonus_percent >= 0) {
                try {
                    $stmt = $pdo->prepare("INSERT INTO referral_levels (level, min_referrals, referrer_percent, referred_bonus_percent, description) 
                                          VALUES (?, ?, ?, ?, ?) 
                                          ON DUPLICATE KEY UPDATE 
                                          min_referrals = VALUES(min_referrals),
                                          referrer_percent = VALUES(referrer_percent),
                                          referred_bonus_percent = VALUES(referred_bonus_percent),
                                          description = VALUES(description)");
                    $stmt->execute([$level, $min_referrals, $referrer_percent, $referred_bonus_percent, $description]);
                    $_SESSION['message'] = 'Реферальный уровень сохранен';
                } catch (Exception $e) {
                    $_SESSION['error'] = 'Ошибка сохранения уровня';
                }
            } else {
                $_SESSION['error'] = 'Заполните все поля корректно';
            }
            break;
            
        case 'create_promo':
            if (!isAdmin()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $code = strtoupper(trim($_POST['code'] ?? ''));
            $type = $_POST['type'] ?? '';
            $value = floatval($_POST['value'] ?? 0);
            $min_deposit = floatval($_POST['min_deposit'] ?? 0);
            $max_uses = intval($_POST['max_uses'] ?? 0);
            $expires_at = $_POST['expires_at'] ?? null;
            
            if ($code && $type && $value > 0) {
                $data = [
                    'code' => $code,
                    'type' => $type,
                    'value' => $value,
                    'min_deposit' => $min_deposit,
                    'max_uses' => $max_uses > 0 ? $max_uses : null,
                    'expires_at' => $expires_at ?: null,
                    'created_by' => $_SESSION['user_id']
                ];
                
                $result = createPromoCode($data);
                if ($result['success']) {
                    $_SESSION['message'] = 'Промокод создан';
                } else {
                    $_SESSION['error'] = $result['message'];
                }
            } else {
                $_SESSION['error'] = 'Заполните все обязательные поля';
            }
            break;
            
        case 'update_promo':
            if (!isAdmin()) {
                $_SESSION['error'] = 'Недостаточно прав';
                break;
            }
            
            $promo_id = intval($_POST['promo_id'] ?? 0);
            $is_active = isset($_POST['is_active']) ? 1 : 0;
            
            if ($promo_id) {
                try {
                    $stmt = $pdo->prepare("UPDATE promo_codes SET is_active = ? WHERE id = ?");
                    $stmt->execute([$is_active, $promo_id]);
                    $_SESSION['message'] = 'Промокод обновлен';
                } catch (Exception $e) {
                    $_SESSION['error'] = 'Ошибка обновления промокода';
                }
            } else {
                $_SESSION['error'] = 'Неверный ID промокода';
            }
            break;
    }
}

// Определение страницы
$page = $_GET['page'] ?? 'home';

// Обработка поиска по тегам
if (isset($_GET['tags']) && is_array($_GET['tags'])) {
    $page = 'home';
    $_GET['tag_search'] = implode(',', $_GET['tags']);
}

// Подключение шапки
$file = __DIR__ . '/../templates/header.php';
if (file_exists($file)) {
    include $file;
} else {
    echo '<div style="color:red">Файл header.php не найден!</div>';
}

// Отображение сообщений
if (isset($_SESSION['message'])) {
    echo '<div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>' . $_SESSION['message'] . '
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>';
    unset($_SESSION['message']);
}

if (isset($_SESSION['error'])) {
    echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i>' . $_SESSION['error'] . '
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>';
    unset($_SESSION['error']);
}

// Подключение страниц
switch ($page) {
    case 'home':
        include __DIR__ . '/../templates/home.php';
        break;
    case 'login':
        include __DIR__ . '/../templates/login.php';
        break;
    case 'register':
        include __DIR__ . '/../templates/register.php';
        break;
    case 'resource':
        include __DIR__ . '/../templates/resource.php';
        break;
    case 'add_plugin':
        include __DIR__ . '/../templates/add_plugin.php';
        break;
    case 'profile':
        include __DIR__ . '/../templates/profile.php';
        break;
    case 'admin':
        include __DIR__ . '/../templates/admin.php';
        break;
    case 'favorites':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/favorites.php';
        break;
    case 'my_plugins':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/my_plugins.php';
        break;
    case 'transactions':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/transactions.php';
        break;
    case 'notifications':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/notifications.php';
        break;
    case 'settings':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/settings.php';
        break;
    case 'plugins':
        include __DIR__ . '/../templates/plugins.php';
        break;
    case 'forum':
        include __DIR__ . '/../templates/forum.php';
        break;
    case 'faq':
        include __DIR__ . '/../templates/faq.php';
        break;
    case 'rules':
        include __DIR__ . '/../templates/rules.php';
        break;
    case 'examples':
        include __DIR__ . '/../templates/examples.php';
        break;
    case 'api':
        include __DIR__ . '/../templates/api.php';
        break;
    case 'about':
        include __DIR__ . '/../templates/about.php';
        break;
    case 'contacts':
        include __DIR__ . '/../templates/contacts.php';
        break;
    case 'privacy':
        include __DIR__ . '/../templates/privacy.php';
        break;
    case 'terms':
        include __DIR__ . '/../templates/terms.php';
        break;
    case 'dmca':
        include __DIR__ . '/../templates/dmca.php';
        break;
    case 'policy':
        include __DIR__ . '/../templates/policy.php';
        break;
    case 'forum_category':
        if (file_exists(__DIR__ . '/../templates/forum_category.php')) {
            include __DIR__ . '/../templates/forum_category.php';
        } else {
            echo '<div class="alert alert-warning">Страница категории форума в разработке</div>';
        }
        break;
    case 'topic':
        if (file_exists(__DIR__ . '/../templates/topic.php')) {
            include __DIR__ . '/../templates/topic.php';
        } else {
            echo '<div class="alert alert-warning">Страница темы форума в разработке</div>';
        }
        break;
    case 'new_topic':
        if (file_exists(__DIR__ . '/../templates/new_topic.php')) {
            include __DIR__ . '/../templates/new_topic.php';
        } else {
            echo '<div class="alert alert-warning">Создание темы в разработке</div>';
        }
        break;
    case 'coauthors':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/coauthors.php';
        break;
    case 'messages':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/messages.php';
        break;
    case 'chat':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/chat.php';
        break;
    case 'referrals':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/referrals.php';
        break;
    case 'promo':
        if (!isLoggedIn()) {
            echo '<div class="alert alert-danger">Необходимо войти в систему</div>';
            break;
        }
        include __DIR__ . '/../templates/promo.php';
        break;
    default:
        include __DIR__ . '/../templates/home.php';
        break;
}

// Подключение подвала
include __DIR__ . '/../templates/footer.php';
