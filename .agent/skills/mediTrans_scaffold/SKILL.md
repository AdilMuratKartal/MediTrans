---
name: meditrans-scaffold
description: Scaffolds MediTrans Flutter features, screens, audio flows, and Ethereal Aura Mind UI components aligned with the Stitch designs and master project specification. Use when creating, scaffolding, or refactoring MediTrans modules including emoji mood tracking, breathwork, yoga body exercises, Hz frequencies, sleep sounds/stories, or profile analytics.
---

# MediTrans Feature Scaffolder

Use this skill whenever building or extending UI modules, state controllers, or asset integrations in the `MediTrans` Flutter app (`meditrans`, Firebase project `meditrans-2ff48`).

> **Non-Negotiable Design Rule:** MediTrans has **NO mascot or animated character GIFs**. Follow the Ethereal Aura Mind Stitch designs strictly: translucent frosted glass, glowing ambient orbs, minimalist icons, and clean emoji chips (`☀️`, `🌿`, `🕊️`, `🌪️`, `🌙`, `🔥`).

## Essential References

Before generating code, consult the bundled skill artifacts and master specification:
- **Master Specification:** [project.md](../../../project.md) — full architecture, Stitch catalog, storage/notification/platform architecture, and roadmap.
- **Data Models & Schemas:** [data_referance.md](../../../data_referance.md) — canonical Dart models, Drift SQLite/WASM schemas, Firestore/Supabase bucket contracts, and seed catalogs.
- **State & Route Reference:** [references/state_flow.md](./references/state_flow.md) — navigation graph, Stitch-to-route mapping, canonical data models, and runtime state flows.
- **UI Pattern Example:** [examples/sample_screen.dart](./examples/sample_screen.dart) — Ethereal Aura Mind color tokens, blurred ambient orbs, `AuraGlassCard`, Light/Night switch, and universal player controls.
- **Scaffold Script:** [scripts/generate_feature.sh](./scripts/generate_feature.sh) — creates `lib/features/<feature_name>/{models,controllers,widgets,screens}` skeleton safely.

---

## Scaffolding Workflow

1. **Identify the Target Module & Stitch Spec**
   Check [references/state_flow.md](./references/state_flow.md) to verify the feature's route, theme mode (Light vs. Cosmic Night), and domain contracts.

2. **Generate Feature Skeleton**
   Run the helper script from the repository root (pass `--dark` for Sleep/Cosmic screens and `--with-player` for media screens):
   ```bash
   bash .agent/skills/mediTrans_scaffold/scripts/generate_feature.sh <feature_name> [--dark] [--with-player]
   ```
   The script fails safely if `lib/features/<feature_name>` already exists so existing work is never overwritten.

3. **Apply Ethereal Aura Mind Tokens**
   Match [examples/sample_screen.dart](./examples/sample_screen.dart) and `DESIGN.md`:
   - **Light Surfaces:** `#FBF8FF` (`surface`), `#F3F2FF`–`#ECECFF` tonal steps, primary `#60538D`, secondary `#4A6550`, tertiary `#8A4B2D`, text `#1A1D2B` / `#6A7188`.
   - **Ambient Orbs & Glass:** Radial `lavender` (`#B8A9E3`), `sage` (`#A3C4AB`), `peach` (`#FFC0A0`), and `sunset` (`#F4937A`) behind `BackdropFilter` (`sigmaX: 22`) cards (`rgba(255,255,255,0.45)` fill, `rgba(255,255,255,0.65)` border).
   - **Night / Sleep Mode:** `#0E111C` background, `#181D2D` card tint, `rgba(255,255,255,0.20)` hairline border.
   - **No-Line Rule & Safe Zones:** Use tonal elevation and `16px–28px` corner radii instead of solid `1px` dividers; reserve `80px–104px` bottom scroll padding above floating bars.

4. **Enforce Module-Specific Contracts**
   - **Navigation:** Top-level shell has 3 floating tabs (`Ana Sayfa`, `Meditasyon`, `Profil`); sub-flows (`Nefes`, `Beden`, `Hz`, `Uyku`) hide the bottom tab bar for focus.
   - **Home & Emoji Mood Tracking:** Implement the `ana_sayfa_duygu_durumu` flow without any mascot: greeting header, weekly `P S Ç P C C P` rhythm calendar, removable emoji mood chips + `+ Duygu Ekle` frosted bottom-sheet modal (`☀️ Mutlu`, `🌿 Dingin`, `🕊️ Huzurlu`, `🌪️ Kaygılı`, `🌙 Yorgun`, `🔥 Kızgın`), reflection note input, and `"Frekansa devam et"` player preview card.
   - **Profile & Analytics:** Match `profil_ve_duygu_analizi` with user vitals (**Yaş**, **Kilo**), habit badges, smooth cubic spline weekly emotion chart with daily emoji indicators, and **Çıkış Yap** (`FirebaseAuth.signOut`).
   - **Universal Persistent Audio:** Route all audio (Nature, Noise, Stories, Hz, Breathwork) through a shared controller exposing `Play/Pause`, `±10s` seek, elapsed/total duration, and progress scrubbing. Keep playback alive across tab/route changes.
   - **Breathwork:** Parameterize cadence (`inhaleSeconds`, `holdSeconds`, `exhaleSeconds`) so both Stitch `4-1-4` and existing `4-7-8` audio work seamlessly.
   - **Body Exercises:** Render the 8 borderless pose cards (`01 Virasana`–`08 Savasana`), open via `Hero` into a swipeable `PageView`, and provide a `60s` default countdown ring (`10/20/30/60/90s` presets, `+5s`, chime toggle, next pose progression).
   - **Hz Frequencies & Angel Numbers:** Show each track's backdrop preview inside its list card; inside the player/`PageView`, synchronize backdrop and audio transitions on horizontal swipe.
   - **Sleep Stories:** Keep the story title above player controls and render scrollable reading text cleanly without obscuring playback controls.

5. **Storage, Asset Size & Platform Portability Rules**
   - Normalize asset paths into lowercase ASCII `snake_case` under `assets/` before adding them to `pubspec.yaml` (remove spaces and Turkish diacritics like `ğ`, `ü`, `ş`, `ı`).
   - **Never embed heavy `.mp3`/`.m4a`/`.mp4` catalogs into the app binary.** Resolve remote audio solely through `MediaStorageGateway` backed by **Supabase Storage Free** (`meditation-audio` / `meditation-visuals`) + native `Drift cached_media` disk cache (do **not** use `firebase_storage`, Phone Auth, or Cloud Functions since they require Firebase's paid Blaze plan; keep Firebase strictly on free Spark products: Auth, Firestore, FCM).
   - **Local Persistence & Notifications:** Use **Drift** (`drift_flutter`) for offline-first tables/outbox (`mood_logs`, `cached_media`, `reminder_schedules`), optional **hive_ce** for lightweight player prefs (never `Isar`), and **`NotificationGateway`** wrapping `flutter_local_notifications` + `firebase_messaging`.
   - **macOS & Windows Web Safety:** Never import `dart:io` directly in UI or shared controllers; isolate disk caching (`macOS` App Support) vs. browser streaming (`Chrome`/`web-server`) behind conditional exports (`if (dart.library.io)`). Guard notification/FCM calls cleanly for `kIsWeb` and macOS entitlements (`com.apple.security.network.client`).

---

## Verification Checklist

Run after modifying or scaffolding any feature:

```bash
flutter analyze
flutter test
```

Ensure zero analyzer errors/warnings, verify light and dark contrast on modified screens, and confirm navigation back/pop actions preserve active background audio.
