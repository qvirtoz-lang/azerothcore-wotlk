# 🚀 AzerothCore WotLK — Встановлення на Windows

Ось повна інструкція з встановлення та налаштування сервера World of Warcraft: The War Within Logs (WotLK) на Windows.

---

## 📋 Вимоги до системи

| Компонент | Версія |
|-----------|--------|
| ОС | Windows 10/11 (64-bit) |
| Visual Studio | 2019/2022 Community/Education/Professional |
| CMake | 3.16+ |
| MySQL/MariaDB | Версія 5.x або 8.x |
| RAM | Мінімум 4GB (рекомендовано 8GB+) |

---

## 🔧 Крок 1: Встановлення вимог

### 1. Visual Studio

**Безкоштовна версія:** [Visual Studio Community 2022](https://visualstudio.microsoft.com/ru/downloads/#community-preview)

1. Завантажте інсталятор
2. Запустіть `VSCommunityInstaller.exe`
3. Оберіть: **Workloads → Desktop development with C++** ✅
4. Натисніть **"Install"** і зачекайте (можливо 15-30 хв)

### 2. CMake

Якщо ще не встановлено: [CMake](https://cmake.org/download/)

- Версія: 3.16 або новіша
- Під час установки оберіть **"Add CMake to the system PATH for all users"**

> ✅ **У вас вже встановлено CMake 4.4.3** — можна пропустити!

---

## 🏗️ Крок 2: Збірка сервера

### Варіант А: Автоматична збірка (рекомендовано)

Відкрийте **CMD від імені адміністратора** і зайдіть у папку:

```cmd
cd D:\AzerothCore\build-scripts
build-windows.bat
```

Скрипт автоматично:
- Перевірить встановлення Visual Studio та CMake
- Налаштує CMake конфігурацію
- Збереже `.sln` файл (Visual Studio solution)
- Побудує сервер у режимах: **Debug**, **Release**, **RelWithDebInfo**

### Варіант Б: Ручна збірка через Visual Studio IDE

1. Відкрийте `D:\AzerothCore\build\AzerothCore.sln` у Visual Studio
2. Перемкніть конфігурацію на **x64 → Release** (або Debug)
3. Натисніть **Build → Build Solution** (Ctrl+Shift+B)

> ⚠️ Збірка може тривати 5-15 хвилин в перший раз!

---

## 🎮 Крок 3: Запуск сервера

### Локальний запуск (без бази даних):

```cmd
cd D:\AzerothCore\apps\server\bin\x64\Release
acore_server.exe --no-db --config-file conf/acore.json
```

### З базу даним:

1. **Створіть базу даних MySQL:**
   ```sql
   CREATE DATABASE `azerothcore_wotlk` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'azerothcore'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
   GRANT ALL PRIVILEGES ON azerothcore_wotlk.* TO 'azerothcore'@'localhost';
   FLUSH PRIVILEGES;
   ```

2. **Налаштуйте конфігурацію:**

   Відкрийте `D:\AzerothCore\apps\server\conf\acore.json` і змініть:

   ```json
   {
     "Database": {
       "ServerHost": "localhost",
       "Port": 3306,
       "Username": "azerothcore",
       "Password": "YourStrongPassword123!",
       "Name": "azerothcore_wotlk"
     }
   }
   ```

3. **Запустіть сервер:**
   ```cmd
   cd D:\AzerothCore\apps\server\bin\x64\Release
   acore_server.exe --config-file conf/acore.json
   ```

---

## 🎮 Крок 4: Запуск ігрового клієнта (World of Warcraft)

Для ігрового клієнта потрібен **офіційний World of Warcraft** або **WoW Classic**.

### Для локального клієнта:

1. Встановіть WoW/WoW Classic на диск C:\
2. Налаштуйте `GameConfig.xml` у папці `Game` клієнта:

   ```xml
   <World>
     <Address>localhost</Address>
     <Port>7340</Port>
   </World>
   ```

### Для отримання світу гри (через скрипти):

Використовуйте інструменти для згенерувати світ гри:
```cmd
cd D:\AzerothCore\tools
./generate-world.bat
```

---

## 📝 Корисні команди

| Команда | Опис |
|---------|------|
| `acore_server.exe --no-db` | Запустити тестовий сервер без бази даних |
| `acore_server.exe --config-file conf/acore.json` | Запустити повноцінний сервер |
| `acore_client.exe` | Запустити консоль клієнта (Debug) |
| `acore_steam.exe` | Запустити Steam версію клієнта |

---

## 🐛 Рішення проблем

### Проблема: "Visual Studio is NOT installed"
**Рішення:** Завантажте та встановіть Visual Studio Community 2022 з робочим навантаженням "Desktop development with C++".

### Проблема: "CMake is NOT found"
**Рішення:** Завантажте [CMake](https://cmake.org/download/) і встановіть у PATH.

### Проблема: "Missing 'Win32.h'"
**Рішення:** Visual Studio не знайдене або неправильна конфігурація C++ навантаження. Перевірте інсталятор.

### Проблема: Server не запускається ("Error 1060")
**Рішення:** База даних MySQL вже існує — оновіть пароль у `acore.json`.

---

## 📞 Додаткова допомога

- [Офіційна документація AzerothCore](https://github.com/azerothcore/azerothcore-wotlk/tree/master/doc)
- [Discord сервер](https://discord.gg/NXQ2Vr6)
- [Wiki](https://wiki.azerothcore.org/)

---

**Готово!** 🎉 Якщо сервер працює — ви можете почати розробку модів або гри!