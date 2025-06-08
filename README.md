# 🚗 AutoParts - Платформа для продажи автозапчастей

![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)

## 📝 Описание проекта

AutoParts - это современная платформа для продажи автозапчастей, разработанная с использованием MERN стека (MongoDB, Express.js, React.js, Node.js). Проект предоставляет удобный интерфейс для поиска, выбора и покупки автозапчастей.

## ✨ Основные возможности

- 🔐 Аутентификация и авторизация пользователей
- 🔍 Поиск запчастей по категориям и параметрам
- 🛒 Корзина покупок
- 💳 Интеграция с платежной системой Braintree
- 📱 Адаптивный пользовательский интерфейс
- 🔄 Управление заказами

## 🛠 Технологический стек

### Backend
- Node.js
- Express.js
- MongoDB с Mongoose
- JWT для аутентификации
- Braintree для платежей
- Express Formidable для работы с формами

### Frontend
- React.js
- React Icons
- Современный UI/UX дизайн

## 🚀 Установка и запуск

### Требования
- Node.js
- MongoDB
- npm или yarn

### Установка зависимостей

# Установка серверных зависимостей
npm install

# Установка клиентских зависимостей
cd client
npm install


### Настройка окружения
Создайте файл .env в корневой директории:

PORT=8000
DEV_MODE=development
MONGO_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
BRAINTREE_MERCHANT_ID=your_merchant_id
BRAINTREE_PUBLIC_KEY=your_public_key
BRAINTREE_PRIVATE_KEY=your_private_key


### Запуск приложения

# Запуск сервера
npm run server

# Запуск клиента
npm run client

# Запуск сервера и клиента одновременно
npm run dev


## 📚 API Endpoints

### Аутентификация
- POST /api/v1/auth/register - Регистрация пользователя
- POST /api/v1/auth/login - Вход в систему

### Категории
- GET /api/v1/category - Получение всех категорий
- POST /api/v1/category - Создание категории
- GET /api/v1/category/:slug - Получение категории по slug

### Продукты
- GET /api/v1/product - Получение всех продуктов
- POST /api/v1/product - Создание продукта
- GET /api/v1/product/:slug - Получение продукта по slug

## 💾 Структура проекта


autoparts/
├── client/                 # React клиент
├── config/                 # Конфигурационные файлы
├── controllers/           # Контроллеры
├── helpers/              # Вспомогательные функции
├── middlewares/          # Middleware функции
├── models/               # Mongoose модели
├── routes/               # API маршруты
├── server.js            # Точка входа сервера
├── package.json         # Зависимости проекта
└── .env                 # Переменные окружения


## 🧪 Тестирование

Проект включает различные типы тестов:
- Unit тесты
- Integration тесты
- API тесты

## 📊 Диаграммы проекта

В проекте используются следующие диаграммы:
- [Flowchart](flowchart.puml) - Блок-схема приложения
- [Entity Relationship](entityrelationship.puml) - ER-диаграмма
- [Mindmap](mindmap.puml) - Интеллект-карта проекта
- [Sequence UML](sequence.puml) - Диаграмма последовательности
- [Class UML](class.puml) - Диаграмма классов
- [Test Sequence](test_sequence.puml) - Диаграмма тестов

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта! Пожалуйста, ознакомьтесь с нашими правилами:
1. Форкните репозиторий
2. Создайте ветку для ваших изменений
3. Внесите изменения
4. Создайте Pull Request



⭐ Не забудьте поставить звезду репозиторию, если он вам понравился!
