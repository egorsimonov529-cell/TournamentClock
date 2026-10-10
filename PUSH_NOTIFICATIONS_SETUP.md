# Настройка Push-уведомлений (FCM)

## Шаг 1: Создание проекта Firebase

1. Перейди на [Firebase Console](https://console.firebase.google.com/)
2. Создай новый проект (или используй существующий)
3. Назови его, например: `poker-club-erm`

## Шаг 2: Добавление Android-приложения

1. В Firebase Console нажми "Add app" → Android
2. Введи Package Name: `com.pokerclub.erm`
3. Скачай файл `google-services.json`
4. Положи файл в: `tournament_clock/android/app/google-services.json`

## Шаг 3: Добавление iOS-приложения (опционально)

1. В Firebase Console нажми "Add app" → iOS
2. Введи Bundle ID (например: `com.pokerclub.erm`)
3. Скачай файл `GoogleService-Info.plist`
4. Положи файл в: `tournament_clock/ios/Runner/GoogleService-Info.plist`

## Шаг 4: Создание Service Account Key (для бэкенда)

1. В Firebase Console перейди в **Project Settings** (шестерёнка слева)
2. Перейди на вкладку **Service Accounts**
3. Нажми "Generate new private key" в разделе **Admin SDK**
4. Сохрани JSON-файл
5. Переименуй файл в `serviceAccountKey.json`
6. Положи файл в: `backend/serviceAccountKey.json`

## Шаг 5: Установка зависимостей

### Flutter:
```bash
cd tournament_clock
flutter pub get
```

### Backend:
```bash
cd backend
npm install firebase-admin
```

## Шаг 6: Настройка Android

Файл `android/app/build.gradle.kts` уже обновлён:
- Добавлен плагин `com.google.gms.google-services`
- Добавлен classpath для google-services

## Шаг 7: Сборка и запуск

```bash
cd tournament_clock
flutter build apk --release
```

Установи APK на телефон и протестируй уведомления.

## Тестирование

1. Зарегистрируй пользователя
2. Зарегистрируй его на турнир
3. Админ должен получить push-уведомление "Новая регистрация!"
4. Создай новость через админ-панель
5. Все пользователи должны получить push-уведомление "Новость клуба"

## Решение проблем

### Уведомления не приходят:
- Проверь, что `google-services.json` в правильной папке
- Проверь, что Package Name совпадает с тем, что в Firebase
- Проверь интернет-соединение на устройстве
- Проверь логи: `flutter logs | grep -i firebase`

### Ошибка "Firebase App not initialized":
- Убедись, что `Firebase.initializeApp()` вызывается в `main.dart`
- Проверь, что `google-services.json` существует

### Ошибка на бэкенде "serviceAccountKey.json not found":
- Убедись, что файл `backend/serviceAccountKey.json` существует
- Проверь, что JSON валидный
- Проверь логи бэкенда для подробностей
