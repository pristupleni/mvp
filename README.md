# SmartSklad B2B 📱📦

[![Flutter](https://img.shields.io/badge/Flutter-3.x-38BDF8?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-10B981?logo=supabase)](https://supabase.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-3B82F6)]()
[![License](https://img.shields.io/badge/License-MIT-amber)]()

**SmartSklad B2B** is a cross-platform mobile & desktop inventory tracking, automated purchasing, and KGS debt settlement application designed for gadget retailers and electronics wholesalers at Dordoi and Madina wholesale markets in Bishkek, Kyrgyzstan.

---

## 🚀 Key Features

* **📦 Real-Time Inventory Tracking:** Stock level status badges (🟢 Normal, 🟡 Low, 🔴 Deficit), predictive "Days Remaining" indicators, and quick 1-click `+` Stock In / `-` Sale buttons.
* **📸 Built-in Camera QR Scanner:** Instant package scanning for stock arrivals and quick quantity entry.
* **🤖 1-Click Purchase Orders:** Automated deficit calculation and direct PO sending via **WhatsApp** and **Telegram** deep-links.
* **💰 KGS Debt & Settlement Tracking:** Receivables and Payables management in Kyrgyz Som (KGS) with direct phone contacts integration and auto-reminder WhatsApp messaging.
* **🧮 China Cargo & Margin Calculator:** Cost breakdown for China factory price, cargo shipping, customs, packaging, and automatic +40% profit margin suggestion with live KGS ↔ USD currency conversion.
* **👥 Role-Based Adaptive UI:** Seamless switching between **Retail Store / Seller** and **Wholesale Supplier**.
* **📜 Audit Action Log:** Chronological logging of all stock adjustments, debt entries, and purchases for fraud prevention.
* **🌐 Offline-First Architecture:** Local `SharedPreferences` JSON caching with auto-sync when online.
* **🌍 Multi-Language Support:** Instant toggling between **Russian** and **Kyrgyz** (`РУС` ↔ `КЫР`).

---

## 🛠 Tech Stack

- **Frontend:** Flutter 3.x, Dart, Provider (State Management)
- **UI & Theme:** Material 3 Dark Theme (`#0B0F19`), Responsive Layout (`NavigationRail` for Desktop/Tablet)
- **Backend & Database:** Supabase (PostgreSQL, Row Level Security, Custom ENUMs, Indexes)
- **Persistence:** Local JSON Cache (`SharedPreferences`)
- **Integrations:** Camera QR Scanner, Phone Contacts API, WhatsApp & Telegram Deep Linking

---

## 📁 Project Structure

```text
lib/
├── main.dart                   # Application Entry Point & ThemeData
├── models/                     # Data Models (Product, Debt, Contact, AuditLog, etc.)
├── providers/                  # State Management (AppStateProvider)
├── screens/                    # Main App Screens (Warehouse, AutoPurchase, Debts, Profile, Calculator, AuditLogs)
├── services/                   # Services (Localization, Messenger, Storage, Permissions)
└── widgets/                    # Reusable Custom UI Components & Modals
database/
└── supabase_schema.sql         # PostgreSQL / Supabase Database Schema
```

---

## 📥 Installation & Running

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio / VS Code
- JDK 17+

### Run Locally
```bash
git clone https://github.com/your-username/smartsklad-b2b.git
cd smartsklad-b2b
flutter pub get
flutter run
```

### Build Release APK
```bash
flutter build apk --release --android-skip-build-dependency-validation
```
The output APK file will be available at:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
