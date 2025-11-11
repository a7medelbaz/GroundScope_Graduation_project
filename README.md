# GroundScope

**GroundScope** هو مشروع تخرج لجامعة الزقازيق الأهلية، ويهدف إلى إنشاء نظام متكامل لإدارة وتنظيم الخدمات الأرضية داخل المطارات، بما يشمل متابعة العمال، الإشراف، توزيع المهام، وإدارة العمليات.

## 📌 مقدمة

GroundScope عبارة عن تطبيق إداري متكامل يعتمد على واجهات مختلفة لكل نوع من المستخدمين:

* **Worker**: إدارة المهام اليومية للعمال.
* **Supervisor**: الإشراف على الفرق، مراجعة التقارير، توزيع المهام.
* **Admin**: التحكم الكامل بالنظام، إدارة المستخدمين، مراقبة العمليات، وإعداد التقارير.

## 🎯 أهداف المشروع

* تحسين تنظيم العمل داخل أرض المطار.
* رفع كفاءة التواصل بين العمال والمشرفين.
* توفير رؤية مركزية للإدارة.
* تقديم تقارير لحظية تساعد في اتخاذ القرارات.

## 🏗️ المعمارية المستخدمة

يعتمد المشروع على **Modular Architecture + MVVM** لضمان:

* قابلية التوسع.
* فصل المسؤوليات.
* سهولة إعادة الاستخدام.
* وضوح الهيكلة.

## 📁 هيكل المشروع (Project Structure)

```text
lib/
 ├── core/
 │    ├── auth/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── network/
 │    ├── storage/
 │    └── utils/
 │
 ├── modules/
 │    ├── worker/
 │    │    ├── core/
 │    │    └── features/
 │    ├── supervisor/
 │    │    ├── core/
 │    │    └── features/
 │    └── admin/
 │         ├── core/
 │         └── features/
 │
 ├── ground_scope_app.dart
 ├── main_development.dart
 └── main_production.dart
```

## 🧩 المزايا الرئيسية للتطبيق

* تخصيص واجهة لكل دور وظيفي.
* إدارة المهام في الوقت الحقيقي.
* إرسال واستقبال إشعارات.
* تسجيل حضور العمال.
* إنشاء تقارير مفصلة للإدارة.

## 🛠️ التقنيات المستخدمة

* **Flutter** (بناء الواجهات).
* **Dart** (لغة البرمجة).
* **MVVM Architecture**.
* **Modular Design**.
* **REST APIs**.

## 👥 الفريق

هذا المشروع تم تطويره بواسطة طلاب **جامعة الزقازيق الأهلية** ضمن مشروع التخرج.

## ✅ حالة المشروع

✅ قيد التطوير النشط.

## 📄 الترخيص (License)

هذا المشروع للاستخدام الأكاديمي فقط، وغير مخصص للنشر التجاري.

## 🎨 Design

> سيتم إضافة لقطات تصميم أو روابط لواجهات GroundScope هنا.
> (ضع هنا صور Figma أو UI Screens عندما تكون جاهزة)

---

## 🧱 Architecture Overview (Colored Mermaid Diagram)

```mermaid
flowchart TD
classDef core fill:#1e40af,stroke:#1e3a8a,color:#fff;
classDef module fill:#065f46,stroke:#064e3b,color:#fff;
classDef feature fill:#0f766e,stroke:#115e59,color:#fff;
classDef main fill:#7c2d12,stroke:#652b11,color:#fff;
classDef file fill:#475569,stroke:#1e293b,color:#fff;

%% ===== LIB =====
LIB[lib/]:::file

%% ===== CORE =====
LIB --> CORE[core/]:::core

CORE --> AUTH[auth/]:::core
AUTH --> AUTH_DATA[data/]:::core
AUTH_DATA --> AUTH_IMPL[auth_repository_impl.dart]:::file
AUTH --> AUTH_DOMAIN[domain/]:::core
AUTH_DOMAIN --> USER_MODEL[models/user_model.dart]:::file
AUTH_DOMAIN --> AUTH_REPO[repositories/auth_repository.dart]:::file
AUTH --> AUTH_PRESENTATION[presentation/]:::core
AUTH_PRESENTATION --> VM[viewmodels/auth_viewmodel.dart]:::file
AUTH_PRESENTATION --> VIEWS[views/login_screen.dart]:::file

CORE --> NETWORK[network/]:::core
CORE --> STORAGE[storage/]:::core
CORE --> UTILS[utils/]:::core

%% ===== MODULES =====
LIB --> MODULES[modules/]:::module

%% Worker
MODULES --> WORKER[worker/]:::module
WORKER --> WORKER_CORE[core/]:::module
WORKER --> WORKER_FEATURES[features/]:::module

WORKER_FEATURES --> TASKS[tasks/]:::feature
TASKS --> TASKS_DATA[data/]:::feature
TASKS --> TASKS_DOMAIN[domain/]:::feature
TASKS --> TASKS_PRESENTATION[presentation/]:::feature

WORKER_FEATURES --> PROFILE[profile/]:::feature
PROFILE --> PROFILE_DATA[data/]:::feature
PROFILE --> PROFILE_DOMAIN[domain/]:::feature
PROFILE --> PROFILE_PRESENTATION[presentation/]:::feature

%% Supervisor
MODULES --> SUPERVISOR[supervisor/]:::module
SUPERVISOR --> SUPERVISOR_CORE[core/]:::module
SUPERVISOR --> SUPERVISOR_FEATURES[features/...]:::feature

%% Admin
MODULES --> ADMIN[admin/]:::module
ADMIN --> ADMIN_CORE[core/]:::module
ADMIN --> ADMIN_FEATURES[features/...]:::feature

%% ===== MAIN FILES =====
LIB --> MAIN_DEV[main_development.dart]:::main
LIB --> MAIN_PROD[main_production.dart]:::main
LIB --> MAIN_APP[ground_scope_app.dart]:::main

```
