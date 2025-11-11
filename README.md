# GroundScope

**GroundScope** هو مشروع تخرج لطلاب **جامعة الزقازيق الأهلية**، ويهدف إلى بناء نظام متكامل لإدارة وتنظيم خدمات العمليات الأرضية في المطارات — مثل توزيع المهام، متابعة العمال، الإشراف، وإعداد التقارير التشغيلية.

## 📌 مقدمة

يوفّر GroundScope ثلاث واجهات رئيسية حسب دور المستخدم:

* **العامل (Worker)**: تنفيذ المهام اليومية.
* **المشرف (Supervisor)**: متابعة الفرق، توزيع المهام، مراجعة التقارير.
* **المدير (Admin)**: تحكم كامل في النظام والمستخدمين والإعدادات.

## 🎯 أهداف المشروع

* تحسين تنظيم سير العمل على أرض المطار.
* تعزيز التواصل بين العمال والمشرفين.
* توفير لوحة تحكم مركزية للإدارة.
* إنشاء تقارير لحظية تدعم اتخاذ القرار.

## 🏗️ المعمارية المستخدمة

يعتمد المشروع على **Modular Architecture + MVVM** بهدف:

* دعم التوسع بسهولة.
* فصل واضح للمسؤوليات.
* سهولة إعادة الاستخدام.
* تنظيم الهيكلة بشكل احترافي.

## 📁 هيكل المشروع

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

## 👥 الفريق

هذا المشروع تم تطويره بواسطة فريق مكون من 9 طلاب من **جامعة الزقازيق الأهلية**:

1. أحمد الباز طلبة الباز صبح
2. محمد حسني محمد حسن
3. عمرو محمد عبد الحميد بدر
4. عبد الله محمد عبد الله نور الدين
5. الشيماء محمد سليمان ابراهيم
6. علياء فايز محمد محمود 
7. ماهيتاب عبد الواحد عبد المنعم
8. وسام كرم شحاته احمد الزهيري 
9. ندي محمد جمال البيومي محمد

## 🎨 التصميم

> سيتم إضافة لقطات التصميم أو روابط Figma لاحقًا.

---

## 🧱 المخطط المعماري (Mermaid Diagram)

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
AUTH --> AUTH_DOMAIN[domain/]:::core
AUTH --> AUTH_PRESENTATION[presentation/]:::core
CORE --> NETWORK[network/]:::core
CORE --> STORAGE[storage/]:::core
CORE --> UTILS[utils/]:::core

%% ===== MODULES =====
LIB --> MODULES[modules/]:::module

%% Worker
MODULES --> WORKER[worker/]:::module
WORKER --> WORKER_CORE[core/]:::module
WORKER --> WORKER_FEATURES[features/]:::module

%% Supervisor
MODULES --> SUPERVISOR[supervisor/]:::module
SUPERVISOR --> SUPERVISOR_CORE[core/]:::module
SUPERVISOR --> SUPERVISOR_FEATURES[features/]:::feature

%% Admin
MODULES --> ADMIN[admin/]:::module
ADMIN --> ADMIN_CORE[core/]:::module
ADMIN --> ADMIN_FEATURES[features/]:::feature

%% ===== MAIN FILES =====
LIB --> MAIN_APP[ground_scope_app.dart]:::main
LIB --> MAIN_DEV[main_development.dart]:::main
LIB --> MAIN_PROD[main_production.dart]:::main


```
