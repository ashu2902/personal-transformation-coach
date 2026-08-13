# Implementation Plan: Holistic Beginner-Friendly Transformation Coach

## Goal Description
Expand AURA from a weightlifting-centric app to a holistic, beginner-friendly lifestyle and habit coach. This change makes the onboarding flow accessible to non-lifters, introduces duration-based activity and habit tracking (walking, yoga, stretching, hydration), simplifies complex jargon, and positions the Gemini AI Coach as a conversational partner for everyday wellness.

---

## Proposed Changes

### 1. Data Models Expansion
Modify [`models.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/models/models.dart) to support non-weightlifting goals and duration-based activities.

*   **Goals:** Add `generalWellness` and `habitBuilding` to `GoalType`.
*   **Activity Types:** Create a new `ActivityType` enum (e.g., `weightLifting`, `cardio`, `yoga`, `walking`, `stretching`, `custom`).
*   **Unified Activity Log:** Modify `DailyWorkout` (or introduce `DailyActivity`) to support duration-based targets (e.g., "Walk for 30 minutes") instead of requiring sets, reps, and weights.
*   **Habit Tracker:** Introduce a basic `HabitLog` model for tracking daily habits (hydration, screen-time, mindfulness).

---

### 2. Beginner Onboarding Flow
Refactor [`onboarding_screen.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/screens/onboarding_screen.dart) to dynamically adjust based on experience level.

*   **Dynamic Tracks:** If a user selects **Beginner** or **Wellness/Habit** goals:
    *   **Hide 1RM inputs:** Completely bypass the Bench/Squat/Deadlift 1RM inputs.
    *   **Simplify Equipment:** Default to "bodyweight / no equipment" options first.
    *   **Injury & Mobility Check:** Frame injury collection as "mobility limitations" (e.g., knee stiffness, lower back tight) using encouraging, accessible phrasing.

---

### 3. Unified Activity & Habit Logging
Simplify [`today_screen.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/screens/today_screen.dart) and [`workout_screen.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/screens/workout_screen.dart) for everyday beginners.

*   **Time-Based Workouts:** If the active activity is a walk or yoga session, replace the set-and-rep table with a simple timer, stop/start log, or a completion checkbox.
*   **Everyday Tracking Cards:** Introduce a simplified card for logging steps, water, and sleep quality directly from the home screen without navigating deep menus.
*   **Beginner Quick Log Templates:** Provide easy click-to-log buttons (e.g., "Log 8 glasses of water", "Log a 20-min walk").

---

### 4. Conversational Everyday AI Coach
Reprogram [`ai_service.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/services/ai_service.dart) and [`coach_screen.dart`](file:///Users/meragi/Downloads/personal-transformation-coach/flutter_app/lib/screens/coach_screen.dart) to broaden the coach's domain.

*   **Holistic Coach Prompting:** Update the Gemini system prompt to act as a supportive wellness, habit, and nutrition coach. Instruct the AI to avoid technical jargon (RPE, TDEE, periodization) unless the profile is marked as "Advanced".
*   **Conversational Starters:** Add quick-tap suggestion chips at the bottom of the coach screen for common beginner questions:
    *   *“Suggest a 5-minute stretch routine for lower back pain.”*
    *   *“How do I build a habit of drinking more water?”*
    *   *“I feel low on energy today, what should I do instead of my workout?”*
*   **Interactive Habits Chat:** Allow the user to report daily activity via chat: *"I took a 20-minute walk after dinner,"* and have the parser log it as a completed activity.

---

## Verification Plan

### Automated Tests
*   Run local flutter tests (`flutter test`) to verify state transitions when onboarding as a beginner.
*   Write unit tests in `services_test.dart` to verify that `parseQuickLog` correctly parses duration-based activities (e.g., "walked for 30 minutes") alongside meals.

### Manual Verification
*   Complete the onboarding flow selecting **Beginner** + **Wellness Goal** and verify that no 1RM lifts are requested.
*   Log a time-based walk in the updated daily screen and ensure it visualizes correctly.
*   Ask the Coach for wellness-focused advice (e.g., stretching, habit formation) and check that the response tone is encouraging and jargon-free.
