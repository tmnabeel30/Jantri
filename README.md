# ColorSync (SwiftUI + MVVM + Firestore)
A tiny iOS app that generates random **color cards**, persists them **offline**, and **auto‑syncs** to Cloud Firestore when you’re online. Built with **SwiftUI**, **MVVM**, and a clean, replaceable data layer (JSON/Core Data, Firestore/Mock).

> Perfect for assignments and demos: fast to run, easy to read, and safe to extend.

---

## ✨ Features
- **Generate** random hex colors as cards
- **Offline‑first**: local persistence (JSON by default)
- **Auto sync** to **Firestore** when online (batched writes)
- **Manual “Sync now”** button
- **Online/Offline** pill (live via `NWPathMonitor`)
- **Delete** cards
- **SwiftUI previews** that don’t touch Firebase or disk

---

## 🧱 Tech Stack
- **iOS 15+**, **Swift 5.7+**
- **SwiftUI**, **Combine**
- **MVVM** + **Repository (actor)** + **protocol‑based DI**
- **Firebase Firestore** (via Swift Package Manager)
- **JSON** file storage (swap to **Core Data** easily)

---

## 🧭 Architecture (MVVM + Clean Data Layer)

```
[View] ColorListView  ──►  [ViewModel] ColorListViewModel  ──►  [Repository (actor)]
         ▲                    ▲  publishes @Published              │
         │                    │                                    │
   SwiftUI UI            listens to NetworkMonitor                 │
         │                    │                                    ▼
         └────────────────────┴──────────────►  LocalStore  ◄──►  CloudSyncing
                                           (JSON/Core Data)     (Firestore/Mock)
```

- **Views are dumb**: only bind to VM state and send intents.
- **ViewModel is the brain**: handles user actions + connectivity and calls the repository.
- **Repository (actor)**: single source of truth for `[ColorItem]`, persists locally, syncs to cloud.
- **Protocols** decouple infrastructure so you can swap JSON↔Core Data or Firestore↔Mock without touching UI.

---

## 🚀 Getting Started

### 0) Prereqs
- Xcode **15+**, iOS target **15+**
- A Firebase project (free tier)

### 1) Add Firebase packages (SPM)
```
File ▸ Add Packages… → https://github.com/firebase/firebase-ios-sdk
Add products: FirebaseCore, FirebaseFirestore (to your app target)
```

### 2) Configure Firebase
1. Firebase Console → Add iOS app → **Bundle ID must match** your Xcode target.
2. Download **`GoogleService-Info.plist`** and add it to the app target in Xcode.
3. In **Firestore Database**: **Create database** (Native mode) → Start in test mode (dev only).

> If you ever see “Permission denied: Cloud Firestore API has not been used…”, enable the API here (select your project):  
> `https://console.developers.google.com/apis/api/firestore.googleapis.com/overview`

### 3) Run
- `ColorSyncApp` already calls `FirebaseApp.configure()` once and wires DI.
- Build & run on Simulator. Tap **Generate Color**, go offline/online, and watch sync.

---

## 🧪 SwiftUI Previews (no simulator required)
Previews use an **in‑memory** `LocalStore` and a **mock** `CloudSyncing`, so they never hit disk/Firebase.

1) Open `Presentation/Views/ColorListView+Preview.swift`  
2) Press **Option‑Command‑Return** to open the Canvas → **Resume**  
3) Toggle light/dark, change devices, etc.

---

## 🔄 How It Works (Quick Flow)
- **Generate** → VM asks Repository to create item → save to `LocalStore` → UI shows **Pending**.
- **Online** → VM calls `syncIfNeeded()` → Repository batches to Firestore → marks items **Synced** → saves locally → UI updates.
- **Delete** → VM asks Repository to remove item → save locally → UI updates.

Batched Firestore write uses `withCheckedThrowingContinuation` to `await` the callback cleanly.

---

## 🔐 Dev Firestore Rules (temporary)
**Do not ship** these rules to production. Use for local demos only.

```
// DEV ONLY — open rules (replace in production)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🧹 Troubleshooting

**“Permission denied: Cloud Firestore API has not been used…”**  
- Enable the API for your project in Google Cloud Console.
- Ensure you created **Firestore in Native mode** in Firebase Console.
- For quick dev, use open rules (see above).

**Wrong project loaded**  
- Open `GoogleService-Info.plist` → `PROJECT_ID` should match your Firebase project. Remove duplicates.

**Duplicate `FirebaseApp.configure()` / invalid `init()`**  
- Call `FirebaseApp.configure()` **once** in the `@main` App initializer.
- Only one `init()` and one container property in `ColorSyncApp`.

**Swift error: “Generic parameter `T` could not be inferred”** (when awaiting a Firestore batch)  
- Explicitly type the continuation as `CheckedContinuation<Void, Error>`.

```swift
try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
  batch.commit { error in
    error == nil ? cont.resume(returning: ()) : cont.resume(throwing: error!)
  }
}
```

**No Previews**  
- Ensure preview files are in the app target and wrapped in `#if DEBUG`.
- Clean build folder (⇧⌘K) then Resume.

**Offline testing**  
- Simulator ▸ Network → toggle to simulate offline/online.

---

## 🗺️ Roadmap (ideas)
- Core Data default store + background context
- Sign‑in and secure Firestore rules
- Pull‑to‑refresh + activity HUD for sync
- Snapshot listeners (realtime updates from cloud)
- UI polish: animations, sections, search
