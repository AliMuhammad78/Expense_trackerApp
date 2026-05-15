 

# Expense_trackerApp 💰

**Expense_trackerApp** is a high-performance, cross-platform mobile application built with Flutter. It offers users a seamless way to track their financial life with a focus on security, multi-user isolation, and a modern, adaptive user interface.

## 🌟 Key Features

* **Secure Authentication:** Dedicated Login and Registration system using localized SQFlite storage.
* **Multi-User Isolation:** Advanced database logic that ensures data is securely partitioned by `userId`.
* **Smart Session Management:** Persistent login states using `SharedPreferences`—the app remembers you.
* **Dynamic Theme Engine:** Persistent Light and Dark mode support that adapts globally across all screens.
* **Fluid UX/UI:** * Keyboard-driven form navigation (Next/Done actions).
* Beautifully animated Splash Screen.
* Categorized expense/income tracking with daily grouping.


* **Visual Analytics:** Interactive charts and detailed reports to visualize spending habits.

## 🛠️ Technical Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** Dart
* **Database:** SQFlite (Local SQLite)
* **State Management:** Provider
* **Local Storage:** SharedPreferences
* **Utility:** Intl (Formatting), UUID (Unique ID Generation)

## 📸 Screenshots

| Splash Screen | Login / Register | Home Dashboard | Dark Mode |
| --- | --- | --- | --- |
|  |  |  |  |

*(Note: Replace placeholders with your actual screenshots from the `assets` folder.)*

## 🚀 Getting Started

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/Expense_trackerApp.git

```


2. **Install dependencies:**
```bash
flutter pub get

```


3. **Run the application:**
```bash
flutter run

```



## 🏗️ Project Structure

```text
lib/
├── data/          # DatabaseHelper & SQFlite configuration
├── models/        # User and Transaction data models
├── providers/     # Transaction & Theme state management
├── screens/       # UI Screens (Home, Login, Charts, etc.)
├── widgets/       # Reusable UI components
└── theme.dart     # Global styling and ThemeProvider

```

## 👤 Author

**Muhammad Ali Saagar** Computer Science Student at the University of Gujrat.

---

*Developed with ❤️ and focus on financial clarity.*
