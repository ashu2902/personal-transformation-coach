# Analytics Tracking — Mixpanel

This project uses **Mixpanel** for all product analytics and user behavioral intelligence. Mixpanel is the single source of truth for event tracking, conversion funnels, coach persona resonance, and user identification. Do not introduce any other analytics tools, SDKs, or tracking libraries without explicit instruction from a user.

---

## Before You Add or Modify Any Tracking

⛔ **Do not write Mixpanel tracking code without reading this file first.**

Wrong assumptions about platform, identity, or privacy consent will produce broken Mixpanel data that requires manual cleanup or data deletion requests.

### Mandatory checklist before writing any Mixpanel code

- [x] Confirm you are using the correct Mixpanel SDK for this project: `mixpanel_flutter`
- [x] Check if this project routes data through a CDP — No CDP, direct client SDK via `IAnalyticsService`
- [x] Check if consent gating is required — Privacy boundary enforced: Zero health PII (no raw weights, photos, or medical notes)
- [x] Review the existing Mixpanel tracking plan below before adding new events

---

## Tech Stack

| Detail | Value |
|---|---|
| **Platform** | Flutter (PWA Web, iOS, Android) |
| **Mixpanel SDK** | `mixpanel_flutter` |
| **SDK version** | `^2.4.0` |
| **Tracking method** | Client-side SDK via `AnalyticsService` abstraction |
| **CDP (if any)** | None |
| **Consent / Privacy** | Anonymized IDs; Zero health PII in event payloads |
| **Mixpanel project token** | `0285e0bfe983b61f50aa622f570535af` |
| **Web Script Tag** | `<script src="https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js"></script>` in `web/index.html` |

---

## Mixpanel Initialization

Mixpanel is initialized once at startup through the unified service layer:

**Service File:** `flutter_app/lib/services/analytics_service.dart`  
**Provider File:** `flutter_app/lib/providers/analytics_provider.dart`  
**App Entrypoint:** `flutter_app/lib/main.dart`

```dart
// Initialized in main() before runApp()
final analytics = MixpanelAnalyticsService();
await analytics.init();

// Accessed via Riverpod throughout the widget tree
ref.read(analyticsServiceProvider).logEvent(AuraAnalyticsEvents.prescriptionCompleted, ...);
```

**Do not:**
- Initialize Mixpanel in multiple places
- Create separate Mixpanel instances per screen or component
- Import `package:mixpanel_flutter/mixpanel_flutter.dart` directly in UI feature files — always use `analyticsServiceProvider` or `IAnalyticsService`

---

## Mixpanel Identity & Lifecycle

Mixpanel identity is managed through strict lifecycle calls:

| Action | When to call | Code location |
|---|---|---|
| `analytics.setUserId(uid)` (`mixpanel.identify`) | On signup, login, or session restore on app launch | `lib/services/firebase_service.dart`<br>`lib/main.dart`<br>`lib/screens/onboarding_screen.dart` |
| `analytics.setUserProperties(...)` (`people.set`) | After user is created/authenticated in DB | `lib/services/firebase_service.dart`<br>`lib/screens/onboarding_screen.dart` |
| `analytics.registerSuperProperties(...)` | After login / persona switch | `lib/main.dart`<br>`lib/screens/profile_screen.dart` |
| `analytics.reset()` (`mixpanel.reset`) | On logout | `lib/services/firebase_service.dart` (`FirebaseAuthService.signOut`) |

**Strict Identity Rules:**
- Call `identify()` with the stable Firebase `uid` — never use email addresses as the distinct ID
- Call `identify()` **after** the user record is confirmed in Firestore
- Call `people.set()` only **after** `identify()`
- Track `sign_up_completed` **after** `identify()` and `people.set()`
- Call `reset()` on every logout path to clear the distinct ID and generate a fresh anonymous session

---

## Mixpanel Tracking Plan

All Mixpanel events in AURA follow strict conventions:
- **Event names:** `snake_case`, past tense verb + noun (`prescription_completed`, `sign_up_completed`)
- **Property names:** `snake_case` (`coach_soul`, `goal_type`, `workout_type`)
- **Boolean properties:** use `is_` or `has_` prefix (`is_adapted`, `has_caption`)
- **Numeric values:** unquoted numbers (never strings like `"12"`)

### Core Event Inventory

| Mixpanel Event | Trigger | Key Properties | File Location |
|---|---|---|---|
| `sign_up_completed` | User completes account calibration/sign-in wall (Lifecycle Gate) | `sign_up_method`, `coach_soul`, `goal_type`, `platform` | `lib/screens/onboarding_screen.dart` |
| `prescription_completed` | User finishes prescribed workout session (**Core Value Moment**) | `workout_type`, `focus_area`, `estimated_duration_min`, `exercise_count`, `total_sets`, `is_adapted`, `coach_soul` | `lib/screens/workout_screen.dart` |
| `onboarding_started` | User lands on onboarding welcome step | `platform` | `lib/screens/onboarding_screen.dart` |
| `onboarding_step_completed` | User advances through onboarding questionnaire | `step_index`, `step_name`, `next_step_index` | `lib/screens/onboarding_screen.dart` |
| `soul_selected` | User chooses a coach persona card | `soul_name`, `previous_soul`, `surface` | `lib/screens/onboarding_screen.dart` |
| `plan_calibrated` | AI finishes initial metabolic & workout baseline | `goal_type`, `target_calories`, `target_protein_g`, `days_per_week`, `equipment_count`, `coach_soul` | `lib/screens/onboarding_screen.dart` |
| `chat_message_sent` | User sends conversational message or photo to AI coach | `input_type` (`text`/`image`), `length`, `source`, `coach_soul` | `lib/screens/coach_screen.dart` |
| `portion_corrected` | User triggers portion adjustment on food entry | `action` (`edit_requested`) | `lib/screens/coach_screen.dart` |
| `recovery_logged` | User records sleep duration or muscle soreness | `sleep_hours` / `soreness_score`, `metric_type` | `lib/screens/today_screen.dart` |
| `soul_switched` | User swaps active coach persona in settings | `soul_name`, `previous_soul`, `surface` | `lib/screens/profile_screen.dart` |
| `goal_updated` | User recalibrates transformation goal or schedule | `previous_goal`, `new_goal`, `target_physique`, `days_per_week` | `lib/screens/profile_screen.dart` |
| `screen_viewed` | User navigates tabs or pushes a major screen | `screen_name` (`today`, `coach`, `insights`, `profile`, `workout_active`) | `lib/main.dart` |
| `account_deleted` | User confirms account deletion | `reason` | `lib/services/firebase_service.dart` |

---

## Super Properties & User Profiles

### Super Properties (Auto-attached to every event):
- `platform`: `'flutter_pwa'` / `'ios'` / `'android'`
- `app_version`: `'1.0.1'`
- `coach_soul`: Active coach persona (`'supporter'`, `'pro'`, `'teacher'`)
- `goal_type`: Primary goal (`'fat_loss'`, `'muscle_gain'`, `'recomp'`)

### User Profile (`mixpanel.getPeople().set()`):
- `$name`: User display name
- `$email`: User email (if authenticated)
- `coach_soul`: Current persona
- `goal_type`: Primary goal
- `days_per_week`: Prescribed workout frequency
- `dietary_preference`: Diet choice (`'nonVeg'`, `'vegetarian'`, etc.)
- `experience_level`: Training experience

---

## How to Add a New Mixpanel Event

1. **Check the tracking plan above** — if the event exists, use it. Do not create duplicate event names.
2. **Define constant in `AuraAnalyticsEvents`** in `lib/services/analytics_service.dart`.
3. **Use `snake_case` naming** and pass strongly-typed, non-null properties.
4. **Invoke via Riverpod:**
   ```dart
   ref.read(analyticsServiceProvider).logEvent(
     AuraAnalyticsEvents.yourNewEvent,
     properties: {
       'property_name': value,
     },
   );
   ```
5. **Update this file** — add the new event to the tracking table.
6. **Verify in Mixpanel Live View** at [mixpanel.com](https://mixpanel.com) under project token `0285e0bfe983b61f50aa622f570535af`.

---

## What Not to Do

- **Do not introduce other analytics tools.** Mixpanel is the single source of truth.
- **Do not track sensitive Health PII** — Never send raw body weight numbers, uploaded physique photo URLs, or medical condition text into Mixpanel properties.
- **Do not send quoted strings for numeric values** — send `10` not `"10"`.
- **Do not skip `reset()` on logout** — failing to reset causes Mixpanel to merge distinct users.
- **Do not call `identify()` before authentication is complete**.
