# Product Specification: AURA Adaptive Wellness Coach

AURA is an AI-native, conversational wellness companion designed for absolute beginners. Instead of acting as a passive tracking ledger (like traditional fitness apps), AURA acts as an active personal coach: evaluating inputs, prescribing daily activities, setting boundaries, and dynamically adjusting its tone based on user behavior.

---

## 1. Core User Experience & Flows

### Flow A: Value-First Onboarding & Auth
1. **Dynamic Onboarding:** The user completes a simplified questionnaire (goals, current height/weight, available equipment, mobility limits/injuries). No complex compound lifting baselines (1RM) are requested for beginners.
2. **Persona Selection:** The user chooses their preferred initial coaching tone:
   * **Empathetic & Supportive:** Focuses on consistency, positive reinforcement, and low friction.
   * **High Accountability:** Direct, metrics-driven, and focused on commitments.
   * **Scientific & Educational:** Explains the biological and physiological *why* behind coach recommendations.
3. **Plan Calibration:** The AI generates an initial personalized daily prescription and metabolic plan.
4. **Sign-In Wall:** To activate and save the plan, the user is prompted to sign in via Firebase (Google/Email). This sunk-cost loop maximizes signup conversion.

### Flow B: The Prescription Board (Today Screen UI)
The main screen of the app is a clean, read-only presentation of what the coach has **prescribed** for today:
* **Daily Activity:** Time-based targets (e.g., *"30-Minute Recovery Walk"* or *"15-Minute Full-Body Stretch"*) rather than complex set/rep grids.
* **Nutrition Tracker:** Visual gauges for Calories, Protein, and Water.
* **Recovery Log:** Quick-view metrics of last night's sleep and soreness level.
* **Sync State:** The screen subscribes to Firestore in real-time. Any changes made during chat are instantly reflected here.

### Flow C: The Coach Screen (Chat UI)
The central operational screen where the user logs data, asks questions, and receives active feedback.
1. **Multi-modal Uploads:** Users upload images (body progress photos, Apple Watch workout summaries, food labels) directly into the chat stream.
2. **Action Prompts:** Conversational chips are pinned to the bottom (e.g., *"Help me plan a 5-minute desk stretch"*, *"Is Diet Coke okay?"*).

---

## 2. Behind-The-Curtain AI Logic

### Feature 1: Conversational Log Parser & The Corrective Loop
When a user logs a meal or workout via chat, AURA processes the input and writes to Firestore.
* **Mechanism (Corrective Loop):** The AI writes the estimated values to the database immediately, but replies with a conversational confirmation:
  > *"Logged a cup of curd (~150 kcal, 12g protein) and a banana. Let me know if the portions were different and I'll adjust it."*
* If the user corrects the portion, the AI overwrites the entry.

### Feature 2: Smart State Classifier (Transient vs. Structural)
When a user makes a complaint or reports a constraint in chat, the AI categorizes the change:
* **Transient States (Soreness, Fatigue, Busy day):** The AI updates the database for *today only*, modifying the active Prescription Board (e.g., replacing Leg Day with an Active Recovery Walk).
* **Structural Parameters (Diet choice, Injuries, Gym access):** The AI updates the core user profile document, triggers a regeneration of future template programs, and stores the constraint in long-term memory.

### Feature 3: Smart Image Classifier (Multi-modal Ingestion)
The app passes uploaded images directly to the Gemini API with instructions to classify and extract parameters:
* **Watch Workout Screenshots:** Extract active minutes, workout type, and calorie burn.
* **Food/Nutrition Labels:** OCR extract Calories, Protein, Fats, and Carbs.
* **Physique Photos:** File in progress history and trigger an encouraging visual check-in review.

### Feature 4: Closed-Loop Behavioral Persona Engine
To prevent beginner burnout, AURA monitors user activity metrics:
* **Metrics Tracked:** Active streak consistency, percentage of completed daily prescriptions, and chat message sentiment.
* **Adaptive Tone Nudges:** If the user initially chose a *High Accountability* coach but starts skipping workouts and logging high stress, the system dynamically shifts the prompt context, instructing AURA to use a more *Empathetic & Supportive* tone until consistency recovers.

---

## 3. Data Architecture (Firebase Sync)

AURA uses Cloud Firestore to maintain real-time state:

* **`users/{userId}/profile`**: Structured parameters (Age, height, weight, current goal, active injuries, initial/effective coaching style).
* **`users/{userId}/daily_logs/{YYYY-MM-DD}`**: The day's active prescription (workout structures, logged activities, macro totals, water intake, sleep quality, muscle soreness score).
* **`users/{userId}/chats/{chatId}/messages`**: History of conversational messages and parsed context summaries.
