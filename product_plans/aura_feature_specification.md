# AURA Adaptive Wellness Coach — Comprehensive Feature Specification

**Document Version:** 1.0 (Production MVP)  
**Classification:** Product Specification & Feature Inventory  
**Target Platform:** Flutter (Mobile PWA, iOS, Android)

---

## 🧭 Executive Summary

**AURA** is an AI-native conversational personal wellness companion. Unlike legacy fitness applications that act as passive data trackers and dashboard dumps, AURA operates on a single core loop:

$$\text{CONVERSE} \longrightarrow \text{INTERPRET} \longrightarrow \text{PRESCRIBE} \longrightarrow \text{ADAPT} \longrightarrow \text{REFLECT}$$

This document provides an exhaustive, granular inventory of every distinct feature across all eight functional domains of the AURA ecosystem.

---

```
                                  AURA ECOSYSTEM ARCHITECTURE
                                  
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                3-TAB CLIENT SHELL                                      │
    │  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌────────────────────────┐  │
    │  │   TODAY (Prescription)  │  │   COACH (Operational)   │  │ INSIGHTS (Reflection)  │  │
    │  └────────────┬────────────┘  └────────────┬────────────┘  └───────────┬────────────┘  │
    └───────────────┼────────────────────────────┼───────────────────────────┼───────────────┘
                    │                            │                           │
                    ▼                            ▼                           ▼
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                           STATE & PERSONALITY ENGINE                                   │
    │  • 3 Coach Souls (Supporter / Pro / Teacher)     • AURA Orb Cognitive State Machine    │
    │  • Riverpod State Notifier & Delta Protocols     • Dynamic Theme Engine (AuraTheme)    │
    └────────────────────────────────────────────┬───────────────────────────────────────────┘
                                                 │
                                                 ▼
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                         AI ORCHESTRATOR & PERSISTENCE                                  │
    │  • Gemini 1.5/2.0 JSON Action Engine             • Firebase Auth & Cloud Firestore     │
    │  • Progressive Overload & Fatigue Engine         • Semantic Equipment & Memory Model   │
    └────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Domain 1: Design System, Visual Language & The AURA Orb

### 1.1 Restrained Dark-Wellness Visual Foundation
* **Background & Elevation Tokens:**
  * Canvas Background: Near-black charcoal (`#0B0C0D`).
  * Primary Surface (Surface 1): Subtle dark charcoal (`#121416`).
  * Elevated Surface (Surface 2): Lightened dark charcoal (`#191C1F`).
* **Border & Card Geometry:** Cards utilize rounded corners ($14\text{–}20\text{ px}$ radius) with restrained $6\%\text{–}12\%$ white border opacity, completely eliminating aggressive cyberpunk/neon borders.
* **Typographic Hierarchy:**
  * **Syne:** Futuristic, bold display typography used for brand marks, section headers, and prescription titles.
  * **Plus Jakarta Sans / Cabinet Grotesk:** Highly readable geometric body typography ($12\text{–}15\text{ pt}$).

### 1.2 Strict Semantic Color System
AURA enforces strict functional color semantics across every screen:
* 🟣 **AURA Purple (`#A779FF`):** Denotes AURA presence, AI thinking, and cognitive intelligence.
* 🟢 **Action Green (`#39E6A3`):** The **single primary call-to-action (CTA)** color on any surface, denoting recommended execution or completion.
* 🟡 **Warning Amber (`#F59E0B`):** Muted attention cue (soreness ratings, untracked days).
* 🔴 **Concern Coral (`#F87171`):** High-fatigue alerts and destructive actions.

### 1.3 Reactive AURA Orb Cognitive State Machine
The AURA Orb is a hardware-accelerated GPU `CustomPainter` rendering dual radial gradients and soft-tech blur masks. It acts as an interactive state machine rather than static branding:

| Orb State | Animation Dynamic | Color Behavior | Trigger Event |
| :--- | :--- | :--- | :--- |
| `idle` | $4\text{s}$ calm breathing oscillation ($\pm 8\%$ radius) | Active Coach Soul Palette | User viewing screen peacefully |
| `thinking` | $1.8\text{s}$ concentric rotation & core pulse | Inner white core expansion | Gemini processing message/log |
| `responding` | Fluid dynamic wave ripple | Radiant outer aura | AI streaming response card |
| `adapting` | Chromatic transition wave | **Morphs from Soul Color $\rightarrow$ Action Green (`#39E6A3`)** | Workout/fuel adjusted for soreness |
| `completed` | Crisp $1.6\text{s}$ bright pulse | Action Green halo | Workout finished or goal checked |

---

## 🧠 Domain 2: Coach Souls & Behavioral Personalities

AURA incorporates three distinct, fully realized coaching personalities ("Souls"):

```
           THE SUPPORTER                       THE PRO                       THE TEACHER
        (Empathetic & Gentle)          (High Accountability)            (Scientific & Analytical)
     ┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
     │ • Soft Violet (#A779FF)│      │ • Electric Cyan(#00E5FF│      │ • Emerald Teal (#00BFA5│
     │ • Lavender (#E0B0FF)   │      │ • Deep Indigo (#2979FF)│      │ • Slate Silver (#B0BEC5│
     │ • Focus: Small wins,   │      │ • Focus: Metrics, form,│      │ • Focus: Physiology,   │
     │   self-compassion,     │      │   standards, forward   │      │   hypertrophy science, │
     │   sustainable momentum │      │   training volume      │      │   metabolic recovery   │
     └────────────────────────┘      └────────────────────────┘      └────────────────────────┘
```

### 2.1 The Supporter (`CoachSoul.supporter`)
* **Tone & Persona:** Warm, reassuring, self-compassionate, and focused on habit building.
* **Palette:** Luminous Purple (`#A779FF`) and Warm Lavender (`#E0B0FF`).
* **Behavior on Setbacks:** Normalizes missed sessions and reframes rest as necessary care.

### 2.2 The Pro (`CoachSoul.pro`)
* **Tone & Persona:** Direct, punchy, metrics-oriented, and execution-focused.
* **Palette:** Electric Cyan (`#00E5FF`) and Deep Indigo (`#2979FF`).
* **Behavior on Setbacks:** Pinpoints recovery deficits, adjusts weekly schedule, and keeps standards high without guilt.

### 2.3 The Teacher (`CoachSoul.teacher`)
* **Tone & Persona:** Analytical, educational, explaining the physiological *why* behind nutrition and movement.
* **Palette:** Vivid Emerald Teal (`#00BFA5`) and Cool Slate Silver (`#B0BEC5`).
* **Behavior on Setbacks:** Explains CNS fatigue, glycogen repletion, and motor-unit recruitment adaptation.

### 2.4 Instant Live Persona Switching
* Tapping a persona in the Profile screen instantly hot-swaps the Riverpod `ThemeData`, updates all AURA Orb instances, and prompts the coach to adapt future chat responses.

---

## 📱 Domain 3: Information Architecture & Navigation Shell

### 3.1 3-Tab Product Shell
Bottom navigation is unified into three non-overlapping product jobs:
1. **`Today` (Prescription Board):** Default landing surface answering *"What should I do today?"*.
2. **`Coach` (Operational Surface):** Active conversation, quick logging, and structured decision cards answering *"What is happening / what should I change?"*.
3. **`Insights` (Reflection & Patterns):** Interpretation-first evidence answering *"Is this working and what have we learned?"*.

### 3.2 Top-Bar Profile & Persistent Memory Drawer
* Access via the top-right profile avatar with user initials.
* Houses persistent settings, account sync status, and the Coach Soul selector without crowding the primary bottom navigation bar.

---

## ⚡ Domain 4: Today Screen (The Prescription Board)

```
┌────────────────────────────────────────────────────────────┐
│ TODAY, WEDNESDAY, AUGUST 15                       (AURA)   │
│ Good morning, Vance                                        │
├────────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────────┐ │
│ │ ● AURA'S RECOMMENDATION                                │ │
│ │ Upper Body Strength & Posture Alignment                │ │
│ │ Chest, Back & Core • 45 min                            │ │
│ │ ┌────────────────────────────────────────────────────┐ │ │
│ │ │ 💬 "Optimal energy state detected. Execute this     │ │ │
│ │ │    session with progressive intent."               │ │ │
│ │ └────────────────────────────────────────────────────┘ │ │
│ │ [ ▶ Start Today's Session                          ] │ │
│ └────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────┤
│ TODAY'S FUEL                                      Log Food │
│ You have room for ~680 kcal                        72% Met │
│ Energy (Calories)  [████████████████░░░░] 1320 / 2000 kcal │
│ Protein            [████████████████████] 152 / 150 g      │
├────────────────────────────────────────────────────────────┤
│ RECOVERY & READINESS                                       │
│ [ 🌙 Sleep: 7.5h ]   [ 💧 Water: +250ml ]   [ ⚡ Soreness ] │
└────────────────────────────────────────────────────────────┘
```

### 4.1 Hero Daily Prescription Card
* **Primary Recommendation Hierarchy:** `AURA'S RECOMMENDATION` tag $\rightarrow$ Bold Workout Title $\rightarrow$ Target Muscle Group / Duration $\rightarrow$ Rationale in Coach Voice $\rightarrow$ **Single Primary Action Green CTA**.
* **Prescription Completion Toggle:** Changes from *"Start Today's Session"* to *"Prescription Completed"* with a checkmark upon workout completion.

### 4.2 Visible Adaptation Card (Before $\rightarrow$ After)
* When soreness, low sleep, or user constraints trigger a workout shift, the card dynamically morphs into **"AURA'S ADAPTED PRESCRIPTION"**.
* Displays the crossed-out original plan alongside the adapted prescription with an explicit causality statement.

### 4.3 Interpretation-First Daily Fuel
* Replaces raw numeric calorie dumps with natural language advice (e.g. *"You have room for ~680 kcal — daily protein target completed!"*).
* Visual Progress Bars for Energy (Calories) and Strength (Protein).

### 4.4 Recovery & Readiness Check-Ins
* **Sleep Check-In:** Interactive modal with a duration slider ($4\text{–}12\text{ hours}$) that writes directly to Firestore.
* **Hydration Quick-Log:** Single tap adds $+250\text{ ml}$ water with haptic and snackbar confirmation.
* **Muscle Soreness Rating:** 5-tier selector ($1\text{–}10$ scale) that feeds into the auto-adaptation engine.

### 4.5 Weekly Schedule Contextual Drilldown
* An interactive tile providing 1-tap navigation to the 7-Day Adaptive Weekly Plan.

---

## 💬 Domain 5: Coach Screen (Conversational Operational Surface)

```
┌────────────────────────────────────────────────────────────┐
│                           ( AURA )                         │
│                         THE PRO                            │
│                  AURA is active & listening                │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [User] My legs are really sore from yesterday.            │
│                                                            │
│  [AURA] I've adjusted today's plan. Swapped heavy squats  │
│         for an active recovery walk to clear fatigue.     │
│                                                            │
│         ┌────────────────────────────────────────────────┐ │
│         │ 🔀 ADAPTED PRESCRIPTION                        │ │
│         │ ~Lower Body Strength~ ➔ Active Recovery Walk   │ │
│         │ [ Accept Revised Plan                        ] │ │
│         └────────────────────────────────────────────────┘ │
│                                                            │
│  [User] Had paneer bowl for lunch.                         │
│                                                            │
│  [AURA] Logged: Paneer bowl (~520 kcal, 28g protein).      │
│         ┌────────────────────────────────────────────────┐ │
│         │ 🍽️ Meal Recorded               [Keep] [Edit]    │ │
│         └────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────┤
│ [ I'm feeling sore ] [ Log 650 kcal ] [ Swap to walk ]     │
├────────────────────────────────────────────────────────────┤
│ [ + ]  [ Tell AURA what happened...                   ] [↑]│
└────────────────────────────────────────────────────────────┘
```

### 5.1 Natural Language Logging & State Delta Engine
* Powered by Gemini JSON Function Calling (`logMeal`, `logRecovery`, `adaptWorkout`).
* Users speak or type naturally (e.g. *"Had 2 eggs and a coffee"*, *"Slept only 5 hours"*), and AURA automatically infers macros, duration, and recovery parameters.

### 5.2 In-Line Decision Cards
* Generated directly in the chat stream when plans adapt.
* Shows the exact structural change (~Old Workout~ $\rightarrow$ **New Workout**) with an immediate *"Accept Revised Plan"* CTA.

### 5.3 In-Line Meal Confirmation Cards
* Displays macro breakdown of inferred foods with instant **"Keep"** and **"Edit"** inline buttons for frictionless correction.

### 5.4 Contextual Action Chips
* Dynamically populated chips floating above the input field based on the user's active coach soul (e.g., Supporter: *"I'm feeling low energy"* vs. Pro: *"Lock in today's workout"*).

### 5.5 Express Quick Actions Modal
* Tapping the `+` button in the composer opens a native operational bottom sheet:
  * 🍽️ **Log Meal / Snack:** Quick prefilled natural language food entry.
  * 💧 **Add Hydration (+250ml):** Instant Firestore logging.
  * ⚡ **Report Soreness / Fatigue:** Immediate workout adaptation trigger.

---

## 📈 Domain 6: Insights Screen (Interpretation & Reflection)

```
┌────────────────────────────────────────────────────────────┐
│ INSIGHTS & PATTERNS                               (AURA)   │
│ Learned by AURA                                            │
├────────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────────┐ │
│ │ ✨ CORE PATTERN IDENTIFIED                              │ │
│ │ "You are maintaining strong momentum with 5 of 7       │ │
│ │  sessions completed. Adherence rate is at 71%."         │ │
│ │                                                        │ │
│ │ 💬 Weekly execution is locked in. Maintain baseline    │ │
│ │    load and ensure nutrition matches output.           │ │
│ └────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────┤
│ WEEKLY MOMENTUM                            ✓ 5 of 7 Done   │
│  (✓)    (✓)    (✓)    (🌙)    (✓)    (✓)    ( T )          │
│   M      T      W     Rest     F      S     Today          │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ 🤝 Rest days are active physiological recovery,        │ │
│ │    not broken streaks.                                 │ │
│ └────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────┤
│ WHAT AURA HAS LEARNED ABOUT YOU                            │
│ 🏋️ Active Gear: Dumbbells, Barbell, Cables, Bodyweight     │
│ 🛡️ Mobility Limitations: None reported (Full ROM)          │
│ 🥗 Dietary Baseline: High-protein flexible balanced        │
├────────────────────────────────────────────────────────────┤
│ PROGRESS TRAJECTORY                       3.5 kg to target │
│ 78.5 kg ➔ 82.0 kg                        [████████░░░░░░░] │
└────────────────────────────────────────────────────────────┘
```

### 6.1 Algorithmic Core Pattern Synthesis
* Evaluates real weekly workout completion rates, average sleep hours, and recovery scores.
* Generates a tailored headline pattern quote and rationale delivered in the active coach persona's voice.

### 6.2 Non-Punitive Weekly Momentum Tracker
* Real-time 7-day bubble row driven by `state.getRecentDaysTrackingStatus(7)`.
* Celebrates rest days with a calm moon icon (`🌙 Rest`) and emphasizes that rest days are essential recovery rather than broken streaks.

### 6.3 Persistent User Model & Constraints Memory
* Transparently displays what AURA has committed to long-term memory:
  * **Active Gear:** Semantic equipment list extracted from onboarding.
  * **Mobility Constraints:** Current injuries or joint limitations.
  * **Dietary Baseline:** Vegetarian, vegan, non-veg, or flexible macro targets.

### 6.4 Live Progress Trajectory
* Computes weight progression dynamically from `state.progressHistory` (initial starting weight vs. current weight vs. target goal) with a mathematical progress ratio bar.

---

## ⚙️ Domain 7: Engine, Progression & Data Architecture

### 7.1 Semantic Equipment Entities (`EquipmentItem`)
* Replaces rigid enums with rich semantic models containing equipment names, categories (`free_weight`, `cables`, `machine`, `bodyweight`, `bands`), weight limits, and custom notes.

### 7.2 Transient vs. Structural State Protocol
* **Transient States:** Soreness, bad sleep, or busy schedules mutate **today's prescription only** with zero permanent changes.
* **Structural States:** New injuries, diet changes, or newly acquired equipment mutate the **canonical user profile** in Firestore and trigger a weekly plan recalculation.

### 7.3 Autoregulatory Fatigue Adaptation Engine
* When recovery scores fall below $50\%$ or soreness exceeds $7/10$, the engine automatically swaps high-intensity compound lifts for low-impact active recovery sessions.

---

## 🚀 Domain 8: Onboarding & Identity

### 8.1 4-Step Low-Friction Onboarding Wizard
* Motivation-first onboarding without high-friction 1RM tests or complex rep calculations.
* Captures age, height, weight, target physique, available equipment, and mobility limitations.

### 8.2 Interactive Coach Soul Preview Carousel
* Step 5 of onboarding allows users to preview how each of the three Coach Souls responds to real-world scenarios before locking in their choice.

### 8.3 Automated Baseline Plan Generation
* Gemini generates an initial personalized metabolic plan (calories, protein, carbs, fats) and workout schedule upon completing onboarding.

### 8.4 Firebase Auth & Cloud Firestore Real-Time Sync
* Supports Google Sign-In and anonymous guest accounts.
* Real-time document streams for workouts (`users/{id}/workouts/{date}`), nutrition (`users/{id}/nutrition/{date}`), recovery (`users/{id}/recovery/{date}`), and messages.

---

## 📊 Summary Feature Inventory Table

| Feature ID | Domain | Feature Name | Description | Status |
| :--- | :--- | :--- | :--- | :--- |
| **DS-01** | Visual | Charcoal Theme Palette | `#0B0C0D`, `#121416`, `#191C1F` canvas & surfaces | 🟢 Live |
| **DS-02** | Visual | Semantic Action Green | `#39E6A3` dedicated single primary CTA token | 🟢 Live |
| **DS-03** | Visual | Reactive AURA Orb | 7-state GPU animated painter with Action Green lerp | 🟢 Live |
| **CP-01** | Personas | The Supporter Soul | Empathetic, momentum-first coaching voice & theme | 🟢 Live |
| **CP-02** | Personas | The Pro Soul | Metrics-driven, high-accountability voice & theme | 🟢 Live |
| **CP-03** | Personas | The Teacher Soul | Scientific, physiological rationale voice & theme | 🟢 Live |
| **CP-04** | Personas | Dynamic Persona Switcher | 1-tap live theme and prompt recalibration | 🟢 Live |
| **IA-01** | Navigation | 3-Tab Shell Architecture | Today (Prescription), Coach (Chat), Insights (Patterns) | 🟢 Live |
| **TD-01** | Today | Prescription Board Hero | Recommendation $\rightarrow$ Reason $\rightarrow$ Green Action CTA | 🟢 Live |
| **TD-02** | Today | Adapted Plan Banner | Visual Before $\rightarrow$ After comparison card for adaptations | 🟢 Live |
| **TD-03** | Today | Interpretation-First Fuel | Calories & protein progress with actionable meal advice | 🟢 Live |
| **TD-04** | Today | Recovery Check-In Modals | Sleep duration slider & 1-10 muscle soreness ratings | 🟢 Live |
| **CH-01** | Coach | Gemini AI Conversationalist | Real-time chat with state delta function calling | 🟢 Live |
| **CH-02** | Coach | In-Line Decision Cards | Before $\rightarrow$ After workout change cards with Accept CTA | 🟢 Live |
| **CH-03** | Coach | In-Line Meal Cards | Compact meal cards with Keep / Edit portion controls | 🟢 Live |
| **CH-04** | Coach | Express Quick Actions | One-tap shortcuts for meal, water, and recovery logs | 🟢 Live |
| **IN-01** | Insights | Dynamic Pattern Synthesis | Algorithmic behavioral takeaways based on volume | 🟢 Live |
| **IN-02** | Insights | Weekly Momentum Dots | Real 7-day activity tracking where rest = recovery | 🟢 Live |
| **IN-03** | Insights | Persistent Model Memory | Surface equipment, constraints, and dietary baseline | 🟢 Live |
| **IN-04** | Insights | Live Weight Trajectory | Mathematical progress ratio from progress history | 🟢 Live |
| **ENG-01**| Engine | Semantic Equipment Model | Rich `EquipmentItem` entities over rigid enums | 🟢 Live |
| **ENG-02**| Engine | Autoregulatory Adaptation | Automatic workout deloading on high fatigue/soreness | 🟢 Live |
| **ONB-01**| Onboarding| 4-Step Calibration Wizard | Goal, metrics, equipment, and personality selection | 🟢 Live |
| **AUTH-01**| Identity | Firebase & Firestore Sync | Real-time cloud persistence & Google Authentication | 🟢 Live |
