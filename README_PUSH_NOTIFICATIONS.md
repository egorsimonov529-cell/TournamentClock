# 📱 Настройка Push-уведомлений - ПОШАГОВАЯ ИНСТРУКЦИЯ

## Что уже сделано:
✅ Добавлены пакеты: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
✅ Создан `FirebaseNotificationService` для работы с FCM
✅ Добавлен endpoint `/api/v1/notifications/fcm-token` для сохранения токена
✅ Создан `notificationService.js` на бэкенде для отправки push
✅ Интегрированы push-уведомления в регистрацию на турнир и создание новостей
✅ Добавлена таблица `user_fcm_tokens` для хранения FCM токенов

## Что нужно сделать вручную:

### 1️⃣ Создать проект Firebase
1. Открой [Firebase Console](https://console.firebase.google.com/)
2. Нажми "Add project" → введи название (например: `poker-club-erm`) → Create project

### 2️⃣ Добавить Android-приложение
1. В Firebase Console нажми иконку Android `</>`
2. Введи Package Name: `com.pokerclub.erm`
3. Нажми "Register app"
4. **Скачай файл `google-services.json`**
5. Положи файл сюда: `tournament_clock/android/app/google-services.json`

### 3️⃣ Создать Service Account Key (для бэкенда)
1. В Firebase Console нажми ⚙️ **Project Settings**
2. Перейди на вкладку **Service Accounts**
3. В разделе "Admin SDK" нажми "Generate new private key"
4. Подтверди паролем от аккаунта Google
5. **Скачается JSON-файл**
6. Переименуй в `serviceAccountKey.json`
7. Положи сюда: `backend/serviceAccountKey.json`

### 4️⃣ Установить зависимости на бэкенде
Открой CMD в папке `backend` и выполни:
```cmd
cd C:\Users\Lenovo\Desktop\works\MVP_Poker\tournament_clock\backend
npm install firebase-admin
```

### 5️⃣ Установить зависимости Flutter
Открой CMD в папке проекта и выполни:
```cmd
cd C:\Users\Lenovo\Desktop\works\MVP_Poker\tournament_clock
flutter pub get
```

### 6️⃣ Собрать APK
```cmd
flutter build apk --release
```

### 7️⃣ Проверить работу
1. Установи APK на телефон
2. Зарегистрируйся в приложении
3. Зарегистрируйся на турнир → **Админ должен получить push** "Новая регистрация!"
4. Создай новость через админку → **Все пользователи получат push** "Новость клуба"

---

## 🎯 Как работают уведомления:

### Сценарий 1: Игрок регистрируется на турнир
```
Игрок нажимает "Зарегистрироваться" 
→ Бэкенд создаёт запись в DB 
→ Бэкенд отправляет push админу 
→ Админ получает уведомление: "Новая регистрация! Игрок XYZ зарегистрировался на турнир ABC"
```

### Сценарий 2: Админ создаёт новость
```
Админ создаёт новость в админке 
→ Бэкенд создаёт запись в DB 
→ Бэкенд отправляет push всем пользователям 
→ Все получают уведомление: "Новость клуба: [название новости]"
```

### Сценарий 3: Игрок нажимает на уведомление
```
Игрок нажимает на push 
→ Приложение открывается 
→ Переход на соответствующую страницу (турнир/новости)
```

---

## 🔍 Troubleshooting:

### Уведомления не приходят?
1. Проверь лог на телефоне:
   ```cmd
   flutter logs | findstr -i "firebase"
   ```
2. Убедись, что `google-services.json` в правильной папке
3. Проверь интернет на телефоне
4. Пересобери APK: `flutter clean && flutter build apk --release`

### Ошибка на бэкенде?
1. Проверь файл `backend/serviceAccountKey.json` — он должен существовать
2. Перезапусти бэкенд: `npm run dev`
3. Проверь логи бэкенда

### TAP notification не работает?
1. Проверь, что `firebase_messaging.onMessageOpenedApp` слушает события
2. Проверь навигацию в `_handleMessageOpened`

---

## 📝 Важно:
- Файлы `google-services.json` и `serviceAccountKey.json` **СОДЕРЖАТ СЕКРЕТНЫЕ КЛЮЧИ**
- **НЕ коммить их в git!** (они уже в `.gitignore`)
- Храни их в безопасности
- Для продакшена используй Environment Variables
