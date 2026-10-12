# Saarthi Native Flutter Mobile App (సారథి)

High-performance, 100% offline-first native mobile application for **Tirumala & Tirupati Pilgrim Guide**, built with Flutter & Dart.

---

## 🌟 Key Architecture Advantages

1. **Zero Web Server Dependency**:
   - Runs 100% locally on the device via native compiled ARM machine code and the C++ Impeller rendering engine.
   - Immune to web hosting limits, deployment storage caps, and DNS propagation issues.
2. **Bundled Offline Data**:
   - All 75 verified temple guides, historical Sthala Puranas, devotee tips, and 33 curated temple precinct map layouts are bundled directly inside `assets/data/`.
   - Launches in under 500ms, even in airplane mode.
3. **Direct Supabase Live Sync**:
   - Connects directly to Supabase (`https://ehywzcxufqjywrnysmrz.supabase.co`) for real-time Sarva Darshan queue wait times, SSD token counters, and emergency alerts.
4. **Explainable Recommendations**:
   - In accordance with Saarthi pilgrim guidance principles, every recommended temple clearly explains *why* it is recommended for that day.

---

## 📁 Project Structure

```text
saarthi_mobile/
├── assets/
│   └── data/
│       ├── places.json          # 75 verified temples & sacred heritage landmarks
│       ├── festivals.json       # 172 festival dates & crowd rush predictions
│       ├── gita_shlokas.json    # Daily Bhagavad Gita shlokas with Telugu/English
│       └── temple_layouts.json  # 33 offline precinct map vector layouts
├── lib/
│   ├── main.dart                # App entrypoint & bottom navigation scaffold
│   ├── core/
│   │   ├── constants.dart       # Supabase keys, coordinates & Ghat rules
│   │   └── theme.dart           # Sacred Pilgrim Material 3 palette
│   ├── models/
│   │   ├── place.dart           # Place data model
│   │   ├── darshan.dart         # Live Darshan wait time model
│   │   ├── festival.dart        # Festival calendar model
│   │   └── gita_shloka.dart     # Gita shloka model
│   ├── data/
│   │   ├── local_repository.dart# Offline asset loader & distance engine
│   │   └── supabase_repository.dart # Live Supabase sync
│   └── ui/
│       └── screens/
│           ├── home_screen.dart # Live Darshan queue, Daily Gita, Top Sites
│           ├── explore_screen.dart # 75+ Temples search & category filter
│           ├── place_detail_screen.dart # Sthala Puranam, tips, precinct map
│           ├── darshan_screen.dart # Wait times, SSD counters, Ghat rules
│           └── essentials_screen.dart # Dress code, lockers & emergency calls
└── test/
    └── distance_test.dart       # Unit test for dynamic driving calculations
```

---

## 🚀 How to Run & Build

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run in Debug Mode
Connect an Android device or start an emulator:
```bash
flutter run
```

### 3. Run Unit Tests
```bash
flutter test
```

### 4. Build Release Android App Bundle (AAB for Google Play)
```bash
flutter build appbundle --release
```
The output AAB will be ready at `build/app/outputs/bundle/release/app-release.aab`.
