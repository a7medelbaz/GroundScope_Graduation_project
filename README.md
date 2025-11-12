
# GroundScope

**GroundScope** is a graduation project developed by students of  **Zagazig National University** , aiming to provide a comprehensive system for managing and organizing **airport ground operations** — including task allocation, workforce monitoring, supervision, and operational reporting.

---

## 📌 Introduction

GroundScope offers  **three primary interfaces** , tailored to user roles:

* **Worker** : Perform daily operational tasks efficiently.
* **Supervisor** : Monitor teams, assign tasks, and review reports.
* **Admin** : Full control over system settings, user management, and configuration.

---

## 🎯 Project Objectives

* Improve workflow organization on airport grounds.
* Enhance communication between workers and supervisors.
* Provide a centralized administrative dashboard.
* Generate real-time reports to support informed decision-making.

---

## 🏗️ Architecture

The project follows a  **Modular Architecture + MVVM pattern** , designed to:

* Facilitate scalability and future enhancements.
* Ensure clear separation of responsibilities.
* Promote code reusability and maintainability.
* Maintain a professional and organized project structure.

---

## 📁 Project Structure

<pre class="overflow-visible!" data-start="1393" data-end="1859" data--h-bstatus="0OBSERVED"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary" data--h-bstatus="0OBSERVED"><div class="sticky top-9" data--h-bstatus="0OBSERVED"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2" data--h-bstatus="0OBSERVED"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs" data--h-bstatus="0OBSERVED"></div></div></div><div class="overflow-y-auto p-4" dir="ltr" data--h-bstatus="0OBSERVED"><code class="whitespace-pre! language-text" data--h-bstatus="0OBSERVED"><span data--h-bstatus="0OBSERVED"><span data--h-bstatus="0OBSERVED">lib/
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
</span></span></code></div></div></pre>

---

## 👥 Team Members

This project was developed by a team of **9 students** from  **Zagazig National University** :

1. Ahmed Elbaz Talba Elbaz Sobah
2. Mohamed Hosni Mohamed Hassan
3. Amr Mohamed Abdelhamid Badr
4. Abdullah Mohamed Abdullah Nour El-Din
5. Shaimaa Mohamed Suleiman Ibrahim
6. Alyaa Fayez Mohamed Mahmoud
7. Mahetab Abdelwahed Abdelmonem
8. Wissam Karam Shahata Ahmed El-Zuhairy
9. Nada Mohamed Gamal El-Bayoumi Mohamed

---

## 🎨 Design

> UI/UX screenshots or Figma links will be added in future updates.

---
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
AUTH --> AUTH_DATA[Data/]:::core
AUTH_DATA --> AUTH_IMPL[auth_repository_impl.dart]:::file
AUTH --> AUTH_LOGIC[Logic/]:::core
AUTH_LOGIC --> USER_MODEL[user_model.dart]:::file
AUTH_LOGIC --> AUTH_REPO[auth_repository.dart]:::file
AUTH --> AUTH_UI[UI/]:::core

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
TASKS --> TASKS_DATA[Data/]:::feature
TASKS --> TASKS_LOGIC[Logic/]:::feature
TASKS --> TASKS_UI[UI/]:::feature

WORKER_FEATURES --> PROFILE[profile/]:::feature
PROFILE --> PROFILE_DATA[Data/]:::feature
PROFILE --> PROFILE_LOGIC[Logic/]:::feature
PROFILE --> PROFILE_UI[UI/]:::feature

%% Supervisor
MODULES --> SUPERVISOR[supervisor/]:::module
SUPERVISOR --> SUPERVISOR_CORE[core/]:::module
SUPERVISOR --> SUPERVISOR_FEATURES[features/]:::feature

SUPERVISOR_FEATURES --> SUP_FEATURE[Feature/]:::feature
SUP_FEATURE --> SUP_DATA[Data/]:::feature
SUP_FEATURE --> SUP_LOGIC[Logic/]:::feature
SUP_FEATURE --> SUP_UI[UI/]:::feature

%% Admin
MODULES --> ADMIN[admin/]:::module
ADMIN --> ADMIN_CORE[core/]:::module
ADMIN --> ADMIN_FEATURES[features/]:::feature

ADMIN_FEATURES --> AD_FEATURE[Feature/]:::feature
AD_FEATURE --> AD_DATA[Data/]:::feature
AD_FEATURE --> AD_LOGIC[Logic/]:::feature
AD_FEATURE --> AD_UI[UI/]:::feature

%% ===== MAIN FILES =====
LIB --> MAIN_DEV[main_development.dart]:::main
LIB --> MAIN_PROD[main_production.dart]:::main
LIB --> MAIN_APP[ground_scope_app.dart]:::main
```
## 📄 License

This project is **for academic purposes only** and may not be used for commercial purposes.
