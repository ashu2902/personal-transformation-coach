# AURA Phase 1: Foundation Implementation Tasks

- [x] 1. Implement dynamic Design Token themes in Flutter (`main.dart` / theme extension)
  - [x] Color maps for The Supporter, The Pro, and The Teacher
  - [x] Clash Display / Cabinet Grotesk font bindings
- [x] 2. Create the procedural AURA Orb widget (`aura_orb.dart` CustomPainter & AnimationController)
  - [x] Pulsing, rippling, and color morphing animations
  - [x] Hero transition animation hooks
- [x] 3. Refactor Onboarding Screens (`onboarding_screen.dart`)
  - [x] Screen 1: The Spark (Orb intro)
  - [x] Screen 2: The Assessment (Chat flow for obstacles, height/weight sliders)
  - [x] Screen 3: Choose Your Coach’s Soul (3 Orbs representation)
  - [x] Screen 4: The Sunk-Cost Reveal (Blurred preview & Sign-in triggers)
- [x] 4. Integrate Firebase Auth & Initial Profile Setup
  - [x] Hook up Sign-in Wall to Firebase Auth
  - [x] Write initialized profile to Firestore `users/{uid}/profile`
- [x] 5. Redesign the Today Screen to Firestore Sync (`today_screen.dart`)
  - [x] Stream-builder sync to `users/{uid}/daily_logs/{date}`
  - [x] Prescription-centric layout (Activity, Fuel bars, Body Check buttons)
