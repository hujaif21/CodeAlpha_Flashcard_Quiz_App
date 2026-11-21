# 🧠 BrainBounty

### A Gamified, Cloud-Synced, Community-Driven Flashcard & Quiz Arena

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-Google_Apps_Script-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/apps-script)
[![CodeAlpha](https://img.shields.io/badge/Internship-CodeAlpha_Task_1-7C3AED?style=for-the-badge)](https://github.com/hujaif21/CodeAlpha_Flashcard_Quiz_App)

**BrainBounty** transforms passive studying into an interactive, learn-to-earn experience. Built natively with **Flutter** and powered by a serverless **Google Apps Script + Google Sheets** backend, it crowdsources study decks globally in real time.

[📲 Download Android APK](https://drive.google.com/file/d/1To7gh4ja9JynfGbC4Q4octXkZO4xKaGP/view?usp=drive_link) • [🐛 Report Bug](https://github.com/hujaif21/CodeAlpha_Flashcard_Quiz_App/issues) • [✨ Request Feature](https://github.com/hujaif21/CodeAlpha_Flashcard_Quiz_App/issues)

---

## ⚠️ Installation & Permissions Note

- **Installing the APK:** Since this release APK is distributed outside the Google Play Store, Android may ask you to allow **"Install unknown apps"** for your browser or file manager—tap **Allow** to proceed.

## 🌟 Why BrainBounty?

Most flashcard apps trap study material on a single device. **BrainBounty** was engineered to solve that by combining a real-time global community database with smart local caching and mobile-game progression mechanics.

### 🌍 One Question, Global Impact
* **Crowdsourced Knowledge Base:** Create custom study decks and add, edit, or delete flashcards on the fly.
* **Real-Time Global Sync:** Every question or deck added by a user syncs directly to the central Google Sheets cloud database and immediately appears in every other user's app worldwide.
* **Instant Practice Loop:** Newly contributed cards automatically feed into active study and quiz sessions.

### ⚡ Smart Caching & Smooth Performance
* **Instant Local Caching:** Decks, flashcards, mock exam questions, and leaderboard rankings are cached locally via `SharedPreferences` for faster load times and reduced network calls.
* **10-Second Timeout Resilience:** Gracefully handles serverless cold-start latency from Google Apps Script so the UI stays smooth and responsive.
* **Persistent Profile & State:** User coins, daily streaks, and unlocked Vault items are saved locally on the device so your progress stays intact across sessions.

### 🎮 Gamified Economy & The Vault
* **Starter Bonus & Streaks:** Fresh installs start with **40 Bounty Coins** and track consecutive daily study sessions (`lastActiveDate`) with automated streak counters.
* **The Vault (Inventory System):** Spend earned coins to unlock exclusive **DiceBear SVG Avatars** (*Mythic* & *Epic* tiers) and **Flex Titles**. Unlocked items are saved to a persistent local inventory and can be re-equipped anytime for free.
* **Tactile Haptics:** Configurable haptic feedback reinforces card flips, answer selections, and Vault unlocks.

### 🏆 Arena, Mock Placement & Live Leaderboard
* **Fast-Lane Tournament Quizzes:** 20-second timed blitz rounds with streak multipliers up to **x3 coins**.
* **Mock Placement Exams:** Full 30-minute (`1800s`) simulated placement tests featuring question navigation, flagging, and competitive `+4 / -1` marking.
* **Global Weekly Leaderboard:** Each install generates a unique `globalUserId` (`USER_<timestamp>`) so players can customize their Gamer Tag and compete globally.

---

## 🎨 Visual Identity & UI System

BrainBounty pairs editorial serif display typography with a clean, low-cognitive-load **Soft Lavender & Warm Cream** palette (`#F8F6FC` → `#FFFDF9`), accented by **Electric Royal Purple** (`#7C3AED`) and **Bounty Gold** (`#F59E0B`).

> 📄 For full color tokens, typography hierarchy, and component specs, see [`theme.md`](./theme.md).

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology | Role |
| :--- | :--- | :--- |
| **Frontend UI** | Flutter (Dart) | Cross-platform mobile interface, animations & SVG avatar rendering |
| **State Management** | `Provider` (`ChangeNotifier`) | Reactive state updates across `AppProvider` & `MockTestProvider` |
| **Cloud Backend** | Google Apps Script | Serverless REST API (`doGet` / `doPost` endpoints) |
| **Database** | Google Sheets | Cloud storage for Decks, Flashcards, Mock Questions & Leaderboard |
| **Local Storage** | `SharedPreferences` | Performance caching, user profile persistence, streaks & Vault inventory |

---

## 📂 Project Structure

```text
lib/
├── models/
│   ├── deck.dart               # Study deck data model
│   ├── flashcard.dart          # Flashcard Q&A model
│   └── mock_question.dart      # Placement exam question & state model
├── providers/
│   ├── app_provider.dart       # Core state, coins, streaks, Vault & sync logic
│   └── mock_test_provider.dart # 30-min exam timer, scoring & submission
├── services/
│   └── api_service.dart        # HTTP client, 10s timeouts & local caching
├── screens/                    # Decks, Study Flip, Arena, Mock Exam, Vault & Profile
└── main.dart                   # App entry point & theme configuration
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.0.0`)
* Android Studio / VS Code with Android SDK configured

### Installation & Build

1. **Clone the repository**
   ```bash
   git clone https://github.com/hujaif21/CodeAlpha_Flashcard_Quiz_App.git
   cd CodeAlpha_Flashcard_Quiz_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run in debug mode**
   ```bash
   flutter run
   ```

4. **Build release APK**
   ```bash
   flutter build apk --release
   ```
   The compiled APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👨‍💻 Author

**Hujaif Belim**  
App Development Intern @ **CodeAlpha**  
GitHub: [@hujaif21](https://github.com/hujaif21)
