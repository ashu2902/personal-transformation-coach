# AURA Adaptive Wellness Coach — Project Context & Rules

This document provides a single source of truth for the project context, architecture, design guidelines, and codebase structure. It is designed to be loaded by the AI agent to instantly align on project parameters without manual lookup.

---

## 🔮 Project Overview
**AURA** is an AI-native, conversational personal wellness companion designed to act as an active, adaptive coach for users of all fitness levels (especially absolute beginners). Unlike static tracking logs, AURA evaluates user inputs, prescribes daily actions, dynamically adjusts its coaching style, and syncs status in real-time.

---

## 📂 Codebase & Directory Structure

- **`flutter_app/`**: Core mobile-first client application.
  - **`lib/main.dart`**: Root application setup, routing, dynamic theme engine mapping.
  - **`lib/models/models.dart`**: Core schemas including `UserProfile`, `DailyWorkout`, `DailyNutrition`, `RecoveryCheckIn`, `ProgressEntry`, and enums (`CoachSoul`, `GoalType`, `ExperienceLevel`).
  - **`lib/engine/`**: Core algorithms.
    - `exercise_database.dart` & `food_database.dart`: Standard databases for workouts and meals.
    - `progressive_overload_engine.dart` & `transformation_orchestrator.dart`: Progressive adaptation engines.
  - **`lib/providers/`**: Application state management.
    - `transformation_state.dart`: Manages active user states, program progression, database syncing, and user stats.
  - **`lib/services/`**: Integration layers.
    - `ai_service.dart`: Integrates Gemini API prompts for each `CoachSoul`, parser logic, and chat flows.
    - `firebase_service.dart`: Integrates Firestore real-time synchronization and Firebase Auth.
    - `transformation_repository.dart`: Local/remote DB repository abstraction.
  - **`lib/screens/`**: UI views.
    - `today_screen.dart`: **The Prescription Board**. Shows daily Move cards, visual calorie/protein/water gauges, sleep and soreness logs.
    - `coach_screen.dart`: **The Coach Chat UI**. Houses the AURA Orb header, action chips, inline portion choice buttons, and laser scanning overlays.
    - `onboarding_screen.dart`: A 4-step wizard collecting goals/metrics, previewing souls, and prompting authentication via Firebase.
    - `profile_screen.dart`: Base profile screen that dynamically maps details and settings based on the coach soul.
    - `widgets/aura_orb.dart`: CustomPainter rendering the animated, reactive radial gradient AI coach orb.

---

## 🎨 Brand & Design System

AURA employs a premium, high-tech minimalist design with soft-tech elements:
1. **Typography**: Headings use **Syne** (bold, futuristic) and body text uses **Cabinet Grotesk** (geometric, highly legible).
2. **Coach Souls & Themes**: The UI theme adapts dynamically to the selected coach tone:
   - **Empathetic & Supportive (`supporter`)**: Soft, consistency-focused tones with positive reinforcement.
   - **High Accountability (`pro`)**: Direct, metrics-driven, and active commitment checking.
   - **Scientific & Educational (`teacher`)**: Informative, explaining the physiological *why* behind plans.
3. **The AURA Orb**: An animated orb widget reflecting the coach's active state (pulsing, swirling, or rippling) using specific gradient color pairs mapped to the selected `CoachSoul`.

---

## ⚙️ AI Engine & Unified Semantic State Architecture

1. **Unified Canonical State & Firestore Schema**:
   - `users/{userId}`: Consolidated Canonical User State document containing demographics, goals, `equipmentList` (semantic `EquipmentItem` objects with names, categories, weight caps, and notes), active injuries, and deduced personal preferences.
   - `users/{userId}/workouts/{YYYY-MM-DD}`: Daily active workout prescriptions, status markers, and exercise notes.
   - `users/{userId}/nutrition/{YYYY-MM-DD}`: Daily macro targets, logged meals, and hydration metrics.
   - `users/{userId}/recovery/{YYYY-MM-DD}`: Sleep hours, quality scores, soreness ratings, and energy levels.
   - `users/{userId}/weekly_plans/{YYYY-Www}`: 7-day adaptive workout and nutrition schedule.
   - `users/{userId}/chats/{chatId}/messages`: Real-time conversation logs and action confirmations.

2. **Atomic State Delta Protocol**:
   The AI Orchestrator acts as a single-turn state transition engine:
   $$\text{Next State} = \text{AI\_Orchestrator}(\text{Current State}, \text{Incoming Message})$$
   Instead of fragmented client switches, the orchestrator outputs a structured **State Delta** containing:
   - **Canonical Memory Updates**: Semantic equipment modifications (e.g. `10kg Workout Bag`), new injuries, or training notes.
   - **Transient Action Updates**: Today's workout substitutions or fuel updates.
   - **Metrics Logs**: Meals, water, sleep, scale weight.
   - **Program Rebuild Flags**: `regenerateWeeklyPlan` when structural parameters change.
   - **Coach Persona Reply**: Warm, supportive, or accountable conversational text.

3. **Semantic Equipment vs. Rigid Enums**:
   Real-world gear is open-ended (e.g., *"10kg sandbag"*, *"resistance bands with door anchor"*, *"pull-up bar"*). Equipment is represented as rich `EquipmentItem` entities rather than lossy 5-value enums. The UI reactively renders whatever equipment is prescribed.

4. **Transient vs. Structural Separation**:
   - *Transient states* (soreness, busy day) modify the active board for **today only**.
   - *Structural states* (diet choices, equipment limits, injuries) mutate the canonical user profile and trigger weekly plan recalculations.

---

## 🛠️ Development & Coding Rules

- **Strict Theme Adherence**: Do not hardcode colors or styles. Utilize dynamic `Theme.of(context)` tokens that map back to the user's active `CoachSoul` profile.
- **Beginner-Friendly UX**: When onboarding beginners or building new templates, bypass high-friction 1RM metrics, favor duration-based activity tags (e.g., "15-minute stretch"), and frame injuries as "mobility limitations."
- **Dart & Flutter Changes**: Always run `flutter test` to verify state transitions and parsing logic. Proactively run hot reloads on any running apps using available debug tools to instantly verify UI rendering.
