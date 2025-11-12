
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

## 🧱 Architecture Diagram (Mermaid)

<pre class="overflow-visible!" data-start="2449" data-end="3834" data--h-bstatus="0OBSERVED"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary" data--h-bstatus="0OBSERVED"><div class="sticky top-9" data--h-bstatus="0OBSERVED"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2" data--h-bstatus="0OBSERVED"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs" data--h-bstatus="0OBSERVED"></div></div></div><div class="overflow-y-auto p-4" dir="ltr" data--h-bstatus="0OBSERVED"><code class="whitespace-pre! language-mermaid" data--h-bstatus="0OBSERVED"><span data--h-bstatus="0OBSERVED">flowchart TD
classDef core fill:#1e40af,stroke:#1e3a8a,color:#fff;
classDef module fill:#065f46,stroke:#064e3b,color:#fff;
classDef feature fill:#0f766e,stroke:#115e59,color:#fff;
classDef main fill:#7c2d12,stroke:#652b11,color:#fff;
classDef file fill:#475569,stroke:#1e293b,color:#fff;

LIB[lib/]:::file

CORE[core/]:::core
LIB --> CORE
AUTH[auth/]:::core
CORE --> AUTH
AUTH_DATA[data/]:::core
AUTH --> AUTH_DATA
AUTH_DOMAIN[domain/]:::core
AUTH --> AUTH_DOMAIN
AUTH_PRESENTATION[presentation/]:::core
AUTH --> AUTH_PRESENTATION
NETWORK[network/]:::core
CORE --> NETWORK
STORAGE[storage/]:::core
CORE --> STORAGE
UTILS[utils/]:::core
CORE --> UTILS

MODULES[modules/]:::module
LIB --> MODULES

WORKER[worker/]:::module
MODULES --> WORKER
WORKER_CORE[core/]:::module
WORKER --> WORKER_CORE
WORKER_FEATURES[features/]:::module
WORKER --> WORKER_FEATURES

SUPERVISOR[supervisor/]:::module
MODULES --> SUPERVISOR
SUPERVISOR_CORE[core/]:::module
SUPERVISOR --> SUPERVISOR_CORE
SUPERVISOR_FEATURES[features/]:::feature
SUPERVISOR --> SUPERVISOR_FEATURES

ADMIN[admin/]:::module
MODULES --> ADMIN
ADMIN_CORE[core/]:::module
ADMIN --> ADMIN_CORE
ADMIN_FEATURES[features/]:::feature
ADMIN --> ADMIN_FEATURES

MAIN_APP[ground_scope_app.dart]:::main
LIB --> MAIN_APP
MAIN_DEV[main_development.dart]:::main
LIB --> MAIN_DEV
MAIN_PROD[main_production.dart]:::main
LIB --> MAIN_PROD
</span></code></div></div></pre>

---

## 📄 License

This project is **for academic purposes only** and may not be used for commercial purposes.

<style>#mermaid-1762908976483{font-family:sans-serif;font-size:16px;fill:#333;}#mermaid-1762908976483 .error-icon{fill:#552222;}#mermaid-1762908976483 .error-text{fill:#552222;stroke:#552222;}#mermaid-1762908976483 .edge-thickness-normal{stroke-width:2px;}#mermaid-1762908976483 .edge-thickness-thick{stroke-width:3.5px;}#mermaid-1762908976483 .edge-pattern-solid{stroke-dasharray:0;}#mermaid-1762908976483 .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-1762908976483 .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-1762908976483 .marker{fill:#333333;}#mermaid-1762908976483 .marker.cross{stroke:#333333;}#mermaid-1762908976483 svg{font-family:sans-serif;font-size:16px;}#mermaid-1762908976483 .label{font-family:sans-serif;color:#333;}#mermaid-1762908976483 .label text{fill:#333;}#mermaid-1762908976483 .node rect,#mermaid-1762908976483 .node circle,#mermaid-1762908976483 .node ellipse,#mermaid-1762908976483 .node polygon,#mermaid-1762908976483 .node path{fill:#ECECFF;stroke:#9370DB;stroke-width:1px;}#mermaid-1762908976483 .node .label{text-align:center;}#mermaid-1762908976483 .node.clickable{cursor:pointer;}#mermaid-1762908976483 .arrowheadPath{fill:#333333;}#mermaid-1762908976483 .edgePath .path{stroke:#333333;stroke-width:1.5px;}#mermaid-1762908976483 .flowchart-link{stroke:#333333;fill:none;}#mermaid-1762908976483 .edgeLabel{background-color:#e8e8e8;text-align:center;}#mermaid-1762908976483 .edgeLabel rect{opacity:0.5;background-color:#e8e8e8;fill:#e8e8e8;}#mermaid-1762908976483 .cluster rect{fill:#ffffde;stroke:#aaaa33;stroke-width:1px;}#mermaid-1762908976483 .cluster text{fill:#333;}#mermaid-1762908976483 div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:sans-serif;font-size:12px;background:hsl(80,100%,96.2745098039%);border:1px solid #aaaa33;border-radius:2px;pointer-events:none;z-index:100;}#mermaid-1762908976483:root{--mermaid-font-family:sans-serif;}#mermaid-1762908976483:root{--mermaid-alt-font-family:sans-serif;}#mermaid-1762908976483 flowchart-v2{fill:apa;}</style>
