import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/transformation_repository.dart';
import '../engine/exercise_database.dart';
import '../engine/transformation_orchestrator.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';

class DayTrackingStatus {
  final String date;
  final String dayLabel;
  final bool isTracked;
  final WorkoutStatus workoutStatus;
  final String statusText;

  DayTrackingStatus({
    required this.date,
    required this.dayLabel,
    required this.isTracked,
    required this.workoutStatus,
    required this.statusText,
  });
}

class TransformationEngineState {
  final UserProfile profile;
  final DailyWorkout workout;
  final DailyNutrition nutrition;
  final RecoveryCheckIn recovery;
  final List<ProgressEntry> progressHistory;
  final List<ChatMessage> chatMessages;
  final bool isOnboardingComplete;
  final String? adaptationNotice;
  final String apiKey;
  final bool isAiThinking;
  final WeeklyPlan? weeklyPlan;
  final MasterContext masterContext;

  TransformationEngineState({
    required this.profile,
    required this.workout,
    required this.nutrition,
    required this.recovery,
    required this.progressHistory,
    required this.chatMessages,
    this.isOnboardingComplete = true,
    this.adaptationNotice,
    this.apiKey = '',
    this.isAiThinking = false,
    this.weeklyPlan,
    MasterContext? masterContext,
  }) : masterContext = masterContext ?? MasterContext();

  TransformationEngineState copyWith({
    UserProfile? profile,
    DailyWorkout? workout,
    DailyNutrition? nutrition,
    RecoveryCheckIn? recovery,
    List<ProgressEntry>? progressHistory,
    List<ChatMessage>? chatMessages,
    bool? isOnboardingComplete,
    String? adaptationNotice,
    String? apiKey,
    bool? isAiThinking,
    WeeklyPlan? weeklyPlan,
    MasterContext? masterContext,
  }) {
    return TransformationEngineState(
      profile: profile ?? this.profile,
      workout: workout ?? this.workout,
      nutrition: nutrition ?? this.nutrition,
      recovery: recovery ?? this.recovery,
      progressHistory: progressHistory ?? this.progressHistory,
      chatMessages: chatMessages ?? this.chatMessages,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      adaptationNotice: adaptationNotice ?? this.adaptationNotice,
      apiKey: apiKey ?? this.apiKey,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
      masterContext: masterContext ?? this.masterContext,
    );
  }

  TodayFocus get todayFocus {
    return TransformationOrchestrator.synthesizeTodayFocus(
      profile: profile,
      workout: workout,
      nutrition: nutrition,
      recovery: recovery,
      history: progressHistory,
    );
  }

  /// Evaluates if progress is tracked for a given date
  bool isProgressTrackedForDate(String dateStr) {
    final hasProgressEntry = progressHistory.any((p) => p.date == dateStr);
    final hasWorkoutActivity = workout.date == dateStr &&
        (workout.status == WorkoutStatus.completed ||
            workout.exercises.any((ex) => ex.sets.any((s) => s.completed)));
    return hasProgressEntry || hasWorkoutActivity;
  }

  /// Calculates effective workout status (if progress is untracked, treat as skipped/did not work out)
  WorkoutStatus get effectiveTodayWorkoutStatus {
    final isTracked = isProgressTrackedForDate(workout.date);
    if (!isTracked && workout.status != WorkoutStatus.completed) {
      return WorkoutStatus.skipped;
    }
    return workout.status;
  }

  List<DayTrackingStatus> getRecentDaysTrackingStatus([int daysCount = 7]) {
    final List<DayTrackingStatus> result = [];
    final today = DateTime.now();

    for (int i = daysCount - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];
      final isToday = i == 0;

      final dayLabel = isToday
          ? 'Today'
          : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.weekday % 7];

      final isTracked = isProgressTrackedForDate(dateStr);

      WorkoutStatus status = WorkoutStatus.skipped;
      if (isTracked) {
        status = isToday ? workout.status : WorkoutStatus.completed;
      }

      result.add(DayTrackingStatus(
        date: dateStr,
        dayLabel: dayLabel,
        isTracked: isTracked,
        workoutStatus: status,
        statusText: isTracked ? 'Worked Out & Tracked' : 'Did Not Work Out (Skipped)',
      ));
    }
    return result;
  }
}

class TransformationEngineNotifier extends StateNotifier<TransformationEngineState> {
  final ITransformationRepository _repository;
  final FirebaseFirestoreService _firestore = FirebaseFirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  StreamSubscription<DocumentSnapshot>? _workoutSubscription;
  StreamSubscription<DocumentSnapshot>? _nutritionSubscription;
  StreamSubscription<DocumentSnapshot>? _recoverySubscription;
  StreamSubscription<QuerySnapshot>? _chatMessagesSubscription;

  TransformationEngineNotifier({ITransformationRepository? repository})
      : _repository = repository ?? LocalTransformationRepository(),
        super(_initialState()) {
    initFromRepository();
  }

  Future<void> initFromRepository() async {
    debugPrint('[AURA STATE] Initializing state from online Firestore...');

    final savedApiKey = await _repository.loadApiKey() ?? const String.fromEnvironment('GEMINI_API_KEY');
    if (savedApiKey.isNotEmpty) {
      _aiService = GeminiAIProvider(apiKey: savedApiKey);
      state = state.copyWith(apiKey: savedApiKey);
    }

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] No authenticated Firebase user. Setting isOnboardingComplete = false');
      state = state.copyWith(isOnboardingComplete: false);
      return;
    }

    // Load profile from Firestore
    final profile = await _firestore.getUserProfile(uid);
    if (profile == null || profile.name.isEmpty) {
      debugPrint('[AURA STATE] No remote profile found for UID $uid. Setting isOnboardingComplete = false');
      state = state.copyWith(isOnboardingComplete: false);
      return;
    }

    // Set onboarding complete and initial profile
    state = state.copyWith(
      profile: profile,
      isOnboardingComplete: true,
    );

    // Setup real-time subscriptions for logs and chats
    setupSubscriptions(uid);
  }

  void setupSubscriptions(String uid) {
    debugPrint('[AURA STATE] Subscribing to real-time streams for UID: $uid');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Cancel existing subscriptions
    _workoutSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _recoverySubscription?.cancel();
    _chatMessagesSubscription?.cancel();

    // 1. Subscribe to Today's Workout (separate collection)
    _workoutSubscription = _firestore.getWorkoutStream(uid, todayStr).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final remoteWorkout = _firestore.workoutFromMap(data);
        state = state.copyWith(workout: remoteWorkout);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Workout subscription error: $err');
    });

    // 2. Subscribe to Today's Nutrition (separate collection)
    _nutritionSubscription = _firestore.getNutritionStream(uid, todayStr).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final remoteNutrition = _firestore.nutritionFromMap(data);
        state = state.copyWith(nutrition: remoteNutrition);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Nutrition subscription error: $err');
    });

    // 3. Subscribe to Today's Recovery (separate collection)
    _recoverySubscription = _firestore.getRecoveryStream(uid, todayStr).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final remoteRecovery = _firestore.recoveryFromMap(data);
        state = state.copyWith(recovery: remoteRecovery);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Recovery subscription error: $err');
    });

    // 4. Subscribe to Chat Messages (paginated to last 50)
    _chatMessagesSubscription = _firestore.getChatMessagesStream(uid).listen((snapshot) {
      final List<ChatMessage> messages = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        messages.add(ChatMessage(
          id: data['id'] ?? doc.id,
          sender: data['sender'] ?? 'ai',
          text: data['text'] ?? '',
          timestamp: data['timestamp'] ?? 'Just now',
        ));
      }
      if (messages.isNotEmpty) {
        state = state.copyWith(chatMessages: messages);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Chat Messages subscription error: $err');
    });
  }

  FirebaseAuthService get authService => _auth;
  String? get currentAuthEmail => _auth.email;
  String? get currentAuthDisplayName => _auth.displayName;
  bool get isAuthenticated => _auth.isAuthenticated;

  Future<UserCredential?> signInWithGoogle() async {
    debugPrint('[AURA STATE] Initiating Google Sign-In...');
    try {
      final cred = await _auth.signInWithGoogle();
      final user = cred?.user;
      if (user != null) {
        final uid = user.uid;
        debugPrint('[AURA STATE] Google Sign-In completed for UID $uid');

        // Check if existing profile exists in Firestore for this Google UID
        final existingProfile = await _firestore.getUserProfile(uid);
        if (existingProfile != null && existingProfile.name.isNotEmpty) {
          state = state.copyWith(
            profile: existingProfile,
            isOnboardingComplete: true,
          );
          setupSubscriptions(uid);
        } else {
          // If first time, seed with Google display name if available
          final newName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
              ? user.displayName!.trim()
              : state.profile.name;
          final updatedProfile = state.profile.copyWith(name: newName);
          state = state.copyWith(profile: updatedProfile);
        }
      }
      return cred;
    } catch (e) {
      debugPrint('[AURA STATE] Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint('[AURA STATE] Signing out user...');
    _workoutSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _recoverySubscription?.cancel();
    _chatMessagesSubscription?.cancel();
    await _auth.signOut();
    state = state.copyWith(
      isOnboardingComplete: false,
    );
  }

  Future<void> updateApiKey(String apiKey) async {
    debugPrint('[AURA STATE] Updating Gemini API Key...');
    await _repository.saveApiKey(apiKey);
    _aiService = GeminiAIProvider(apiKey: apiKey);
    state = state.copyWith(apiKey: apiKey);
  }

  static TransformationEngineState _initialState() {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final profile = UserProfile(
      name: 'Athlete',
      age: 28,
      gender: 'male',
      heightCm: 180,
      weightKg: 78.5,
      targetWeightKg: 82.0,
      goal: GoalType.recomp,
      daysPerWeek: 4,
      targetPhysique: 'Athletic V-Taper',
      equipmentList: [
        const EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
        const EquipmentItem(name: 'Barbell', category: 'free_weight'),
        const EquipmentItem(name: 'Cables', category: 'cables'),
      ],
      coachSoul: CoachSoul.supporter,
    );

    final workout = DailyWorkout(
      id: 'placeholder_$todayStr',
      date: todayStr,
      title: 'Your AI Plan is being built...',
      focusArea: 'AI Calibrating',
      estimatedDurationMin: 45,
      status: WorkoutStatus.scheduled,
      exercises: [],
    );

    final nutrition = DailyNutrition(
      date: todayStr,
      targetCalories: 2000,
      targetProteinG: 150,
      targetCarbsG: 200,
      targetFatG: 60,
      targetWaterMl: 2800,
      waterMl: 0,
      meals: [],
    );

    final recovery = RecoveryCheckIn(
      date: todayStr,
      sleepHours: 7.5,
      sleepQuality: 8,
      muscleSoreness: 4,
      energyLevel: 8,
      stressLevel: 3,
      recoveryScore: 84,
      status: 'Optimum Adaptation',
    );

    return TransformationEngineState(
      profile: profile,
      workout: workout,
      nutrition: nutrition,
      recovery: recovery,
      progressHistory: [
        ProgressEntry(date: '2026-08-08', weightKg: 79.2, bodyFatPercent: 18.2),
        ProgressEntry(date: '2026-08-09', weightKg: 78.9, bodyFatPercent: 18.0),
        ProgressEntry(date: '2026-08-10', weightKg: 78.6, bodyFatPercent: 17.9),
      ],
      chatMessages: [
        ChatMessage(
          id: 'm1',
          sender: 'ai',
          text: "Welcome back, Vance. Transformation baseline active. Ready for today's workout?",
          timestamp: '09:00 AM',
        )
      ],
      isOnboardingComplete: true,
      adaptationNotice: "Welcome to AURA! Tap 'Sleep' or 'Aches' below to log your state, or message me in the Coach tab to begin.",
    );
  }

  Future<void> completeOnboarding(UserProfile newProfile) async {
    debugPrint('[AURA STATE] Completing onboarding for ${newProfile.name}...');
    final nutrition = await _aiService.generateAIMetabolicPlan(newProfile);
    final workout = await _aiService.generateAIInitialWorkout(newProfile);
    await completeOnboardingWithPlan(newProfile, nutrition, workout);
  }

  Future<void> completeOnboardingWithPlan(UserProfile newProfile, DailyNutrition nutrition, DailyWorkout workout) async {
    debugPrint('[AURA STATE] Completing onboarding with synthesized plan for ${newProfile.name}...');
    debugPrint('[AURA STATE] Baseline setup: Target Calories ${nutrition.targetCalories} kcal, Target Protein ${nutrition.targetProteinG}g');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final initProgress = ProgressEntry(date: todayStr, weightKg: newProfile.weightKg, notes: 'Initial baseline setup');

    state = state.copyWith(
      profile: newProfile,
      nutrition: nutrition,
      workout: workout,
      progressHistory: [initProgress],
      isOnboardingComplete: true,
      adaptationNotice: "Welcome to AURA, ${newProfile.name}! Tap 'Sleep' or 'Aches' below to log your state, or message me in the Coach tab to begin.",
    );

    final uid = _auth.uid ?? 'firebase_user_vance_77';
    await _firestore.saveUserProfile(uid, newProfile);
    await _firestore.saveDailyWorkout(uid, todayStr, workout);
    await _firestore.saveDailyNutrition(uid, todayStr, nutrition);
    await _repository.saveProgressEntry(initProgress);
    
    setupSubscriptions(uid);

    // Load master context
    _loadMasterContext(uid);

    // Load weekly plan for current week
    _loadCurrentWeeklyPlan(uid);

    debugPrint('[AURA STATE] Onboarding completed & baseline saved online!');
  }

  void updateExerciseSet(String exerciseId, int setIndex, bool completed) {
    debugPrint('[AURA STATE] Updating exercise set: $exerciseId (Set #${setIndex + 1} completed: $completed)');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      final updatedSets = List<ExerciseSet>.from(ex.sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(completed: completed);
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final anyCompleted = updatedExercises.any((ex) => ex.sets.any((s) => s.completed));
    final allCompleted = updatedExercises.every((ex) => ex.sets.every((s) => s.completed));

    WorkoutStatus newStatus = state.workout.status;
    if (allCompleted) {
      newStatus = WorkoutStatus.completed;
      debugPrint('[AURA STATE] Workout completed! All sets marked done.');
    } else if (anyCompleted && state.workout.status == WorkoutStatus.skipped) {
      newStatus = WorkoutStatus.scheduled;
    }

    final updatedWorkout = state.workout.copyWith(
      exercises: updatedExercises,
      status: newStatus,
    );
    state = state.copyWith(workout: updatedWorkout);

    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
  }

  void substituteExercise(String exerciseId, ExerciseDefinition newDefinition) {
    debugPrint('[AURA STATE] Substituting exercise $exerciseId -> ${newDefinition.name}');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      return ex.copyWith(
        name: newDefinition.name,
        targetMuscle: newDefinition.targetMuscle,
        equipmentRequired: newDefinition.equipment.name,
        notes: 'Substituted for ${ex.name}',
      );
    }).toList();

    final updatedWorkout = state.workout.copyWith(exercises: updatedExercises);
    state = state.copyWith(workout: updatedWorkout);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
  }

  void trackProgressForToday() {
    debugPrint('[AURA STATE] Marking daily progress tracked for today');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final existing = state.progressHistory.any((p) => p.date == todayStr);

    final todayEntry = ProgressEntry(
      date: todayStr,
      weightKg: state.profile.weightKg,
      notes: 'Quick daily check-in',
    );

    if (!existing) {
      final newHistory = List<ProgressEntry>.from(state.progressHistory)..add(todayEntry);
      state = state.copyWith(progressHistory: newHistory);
      _repository.saveProgressEntry(todayEntry);
    }

    WorkoutStatus updatedWorkoutStatus = state.workout.status;
    if (updatedWorkoutStatus == WorkoutStatus.skipped) {
      updatedWorkoutStatus = WorkoutStatus.scheduled;
    }

    final updatedWorkout = state.workout.copyWith(status: updatedWorkoutStatus);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyWorkout(uid, todayStr, updatedWorkout);
  }

  void addWater(int amountMl) {
    final newWater = state.nutrition.waterMl + amountMl;
    debugPrint('[AURA STATE] Added +${amountMl}ml water (Total: ${newWater}ml)');
    final updatedNutrition = state.nutrition.copyWith(waterMl: newWater);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
  }

  void addMeal(MealItem meal) {
    debugPrint('[AURA STATE] Added meal: ${meal.name} (${meal.calories} kcal, ${meal.proteinG}g P)');
    final newMeals = List<MealItem>.from(state.nutrition.meals)..add(meal);
    final updatedNutrition = state.nutrition.copyWith(meals: newMeals);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
  }

  Future<MealItem> logMealWithAI(String mealDescription) async {
    debugPrint('[AURA STATE] Estimating meal with AI: "$mealDescription"');
    final meal = await _aiService.estimateAIMealNutrition(mealDescription);
    addMeal(meal);
    return meal;
  }

  void addProgressEntry(ProgressEntry entry) {
    debugPrint('[AURA STATE] Adding weight progress entry: ${entry.weightKg} kg');
    final newHistory = List<ProgressEntry>.from(state.progressHistory)..add(entry);
    final updatedProfile = state.profile.copyWith(weightKg: entry.weightKg);

    state = state.copyWith(
      progressHistory: newHistory,
      profile: updatedProfile,
    );
    trackProgressForToday();
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveUserProfile(uid, updatedProfile);
    _repository.saveProgressEntry(entry);

    // Check for weight stall — ask AI to adapt nutrition asynchronously
    if (newHistory.length >= 14) {
      final recent = newHistory.sublist(newHistory.length - 14);
      final delta = (recent.last.weightKg - recent.first.weightKg).abs();
      if (delta < 0.2 && updatedProfile.goal == GoalType.fatLoss) {
        _aiService.generateAIAdaptedNutrition(
          state.copyWith(profile: updatedProfile, progressHistory: newHistory),
          'Weight stalled over 14 days (only ${delta.toStringAsFixed(1)}kg change). Adjust calorie target for continued fat loss.',
        ).then((adaptedNutrition) {
          _firestore.saveDailyNutrition(uid, state.nutrition.date, adaptedNutrition);
          debugPrint('[AURA STATE] AI nutrition adapted for weight stall.');
        }).catchError((e) {
          debugPrint('[AURA STATE] AI nutrition adaptation failed: $e');
        });
      }
    }
  }

  AIService _aiService = GeminiAIProvider(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
  AIService get aiService => _aiService;

  void appendUserMessage(String text) {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: 'Just now',
    );
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveChatMessage(uid, userMsg);
  }

  Future<void> addChatMessage(String text) async {
    debugPrint('[AURA STATE] User message: $text');
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: 'Just now',
    );

    final uid = _auth.uid ?? 'firebase_user_vance_77';
    await _firestore.saveChatMessage(uid, userMsg);

    // Optimistically show user message in local chat immediately
    final updatedChat = List<ChatMessage>.from(state.chatMessages)..add(userMsg);
    state = state.copyWith(
      chatMessages: updatedChat,
      isAiThinking: true,
    );

    try {
      final orchestratorResult = await _aiService.processCoachMessage(text, state);
      debugPrint('[AURA STATE] Orchestrator determined ${orchestratorResult.actions.length} action(s): ${orchestratorResult.actions.map((a) => a.functionName).toList()}');

      // Sequentially execute actions
      for (final action in orchestratorResult.actions) {
        debugPrint('[AURA STATE] Executing action: ${action.functionName} with args: ${action.arguments}');
        switch (action.functionName) {
          case 'updateEquipment':
            final rawItems = action.arguments['items'];
            final rawEquip = action.arguments['equipment'];
            final rawNote = action.arguments['equipmentNote']?.toString();
            final rawMax = (action.arguments['maxWeightKg'] as num?)?.toDouble();

            final List<EquipmentItem> newItems = [];
            if (rawItems is List) {
              for (var it in rawItems) {
                if (it is Map) {
                  newItems.add(EquipmentItem.fromMap(Map<String, dynamic>.from(it)));
                } else if (it is String) {
                  newItems.add(EquipmentItem.fromString(it));
                }
              }
            } else if (rawEquip is List) {
              for (var e in rawEquip) {
                newItems.add(EquipmentItem.fromString(e.toString(), weightKg: rawMax, notes: rawNote));
              }
            }
            if (newItems.isEmpty) {
              newItems.add(const EquipmentItem(name: 'Bodyweight', category: 'bodyweight'));
            }

            final updatedProfile = state.profile.copyWith(equipmentList: newItems);
            state = state.copyWith(profile: updatedProfile);
            await _firestore.saveUserProfile(uid, updatedProfile);
            break;

          case 'adaptWorkout':
            final reason = action.arguments['reason']?.toString() ?? text;
            final maxWeightNum = (action.arguments['maxWeightKg'] as num?)?.toDouble();
            final adaptedWorkout = await _aiService.adaptWorkoutWithAI(
              reason,
              state,
              explicitEquipment: state.profile.availableEquipment,
              maxWeightKg: maxWeightNum,
            );
            state = state.copyWith(
              workout: adaptedWorkout,
              adaptationNotice: 'Workout adapted via AURA AI: "${adaptedWorkout.adaptationNote ?? reason}"',
            );
            await _firestore.saveDailyWorkout(uid, state.workout.date, adaptedWorkout);
            break;

          case 'logNutrition':
            DailyNutrition updatedNutrition = state.nutrition;
            final mealsRaw = action.arguments['meals'];
            if (mealsRaw is List && mealsRaw.isNotEmpty) {
              final List<MealItem> newMeals = [];
              for (var m in mealsRaw) {
                newMeals.add(MealItem(
                  name: m['name']?.toString() ?? 'Logged Meal',
                  calories: (m['calories'] as num?)?.toInt() ?? 300,
                  proteinG: (m['proteinG'] as num?)?.toInt() ?? 20,
                  carbsG: (m['carbsG'] as num?)?.toInt() ?? 30,
                  fatG: (m['fatG'] as num?)?.toInt() ?? 10,
                ));
              }
              final combined = List<MealItem>.from(updatedNutrition.meals)..addAll(newMeals);
              updatedNutrition = updatedNutrition.copyWith(meals: combined);
            }
            final waterNum = (action.arguments['waterMl'] as num?)?.toInt();
            if (waterNum != null && waterNum > 0) {
              updatedNutrition = updatedNutrition.copyWith(waterMl: updatedNutrition.waterMl + waterNum);
            }
            state = state.copyWith(nutrition: updatedNutrition);
            await _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
            break;

          case 'logRecovery':
            RecoveryCheckIn updatedRecovery = state.recovery;
            final sleepH = (action.arguments['sleepHours'] as num?)?.toDouble() ?? updatedRecovery.sleepHours;
            final sleepQ = (action.arguments['sleepQuality'] as num?)?.toInt() ?? updatedRecovery.sleepQuality;
            final sore = (action.arguments['muscleSoreness'] as num?)?.toInt() ?? updatedRecovery.muscleSoreness;
            final energy = (action.arguments['energyLevel'] as num?)?.toInt() ?? updatedRecovery.energyLevel;
            final stress = (action.arguments['stressLevel'] as num?)?.toInt() ?? updatedRecovery.stressLevel;

            final sleepScore = ((sleepH / 8.0).clamp(0.0, 1.2)) * 10 * (sleepQ / 10.0);
            final score = ((sleepScore * 3.5) + (energy * 3.5) + ((10 - sore) * 2.0) + ((10 - stress) * 1.0)).round().clamp(20, 100);

            updatedRecovery = updatedRecovery.copyWith(
              sleepHours: sleepH,
              sleepQuality: sleepQ,
              muscleSoreness: sore,
              energyLevel: energy,
              stressLevel: stress,
              recoveryScore: score,
            );
            state = state.copyWith(recovery: updatedRecovery);
            await _firestore.saveDailyRecovery(uid, state.recovery.date, updatedRecovery);
            break;

          case 'logWeight':
            final weight = (action.arguments['weightKg'] as num?)?.toDouble();
            if (weight != null && weight > 0) {
              final updatedProfile = state.profile.copyWith(weightKg: weight);
              final todayStr = DateTime.now().toIso8601String().split('T')[0];
              final entry = ProgressEntry(date: todayStr, weightKg: weight, notes: 'Logged via Coach Chat');
              state = state.copyWith(
                profile: updatedProfile,
                progressHistory: List<ProgressEntry>.from(state.progressHistory)..add(entry),
              );
              await _firestore.saveUserProfile(uid, updatedProfile);
              await _repository.saveProgressEntry(entry);
            }
            break;

          case 'updateWorkoutStatus':
            final statusStr = action.arguments['status']?.toString().toLowerCase();
            WorkoutStatus newStatus = state.workout.status;
            if (statusStr == 'completed') newStatus = WorkoutStatus.completed;
            if (statusStr == 'skipped') newStatus = WorkoutStatus.skipped;
            final updatedWorkout = state.workout.copyWith(status: newStatus);
            state = state.copyWith(workout: updatedWorkout);
            await _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
            break;

          case 'updateMasterContext':
            final field = action.arguments['field']?.toString();
            final actionType = action.arguments['action']?.toString();
            final value = action.arguments['value'];
            if (field != null) {
              await updateMasterContextDeduced(
                field: field,
                action: actionType,
                value: value,
              );
            }
            break;

          case 'regenerateWeeklyPlan':
            await generateWeeklyPlan();
            break;
        }
      }

      final aiReply = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: orchestratorResult.coachResponse,
        timestamp: 'Just now',
      );

      final finalChat = List<ChatMessage>.from(state.chatMessages)..add(aiReply);
      state = state.copyWith(
        chatMessages: finalChat,
        isAiThinking: false,
      );
      await _firestore.saveChatMessage(uid, aiReply);
    } catch (e) {
      debugPrint('[AURA STATE] Chat processing failed: $e');
      final errReply = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: "I encountered a hiccup processing that request. Could you please try again?",
        timestamp: 'Just now',
      );
      final finalChat = List<ChatMessage>.from(state.chatMessages)..add(errReply);
      state = state.copyWith(
        chatMessages: finalChat,
        isAiThinking: false,
      );
      await _firestore.saveChatMessage(uid, errReply);
    }
  }

  Future<void> simulateWatchScreenshotScan() async {
    state = state.copyWith(isAiThinking: true);
    await Future.delayed(const Duration(seconds: 3));
    
    final scanReply = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'ai',
      text: "Got it! 340 active calories burned during your workout. I've updated your Energy bar on the home screen.",
      timestamp: 'Just now',
    );
    
    final updatedWorkout = state.workout.copyWith(
      status: WorkoutStatus.completed,
    );
    
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    await _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    await _firestore.saveChatMessage(uid, scanReply);
    
    state = state.copyWith(
      isAiThinking: false,
    );
  }

  void updateRecoveryCheckIn({
    required double sleepHours,
    required int sleepQuality,
    required int muscleSoreness,
    required int energyLevel,
    required int stressLevel,
  }) {
    final sleepScore = ((sleepHours / 8.0).clamp(0.0, 1.2)) * 10 * (sleepQuality / 10.0);
    final score = ((sleepScore * 3.5) + (energyLevel * 3.5) + ((10 - muscleSoreness) * 2.0) + ((10 - stressLevel) * 1.0)).round().clamp(20, 100);

    String statusText = 'Optimal Adaptation';
    if (score < 50) {
      statusText = 'High Fatigue (Deload Advised)';
    } else if (score < 70) {
      statusText = 'Moderate Readiness';
    }

    debugPrint('[AURA STATE] Recovery Check-in updated: Score $score% ($statusText)');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final updatedRecovery = RecoveryCheckIn(
      date: todayStr,
      sleepHours: sleepHours,
      sleepQuality: sleepQuality,
      muscleSoreness: muscleSoreness,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
      recoveryScore: score,
      status: statusText,
    );

    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyRecovery(uid, todayStr, updatedRecovery);

    // If high fatigue, ask AI to adapt workout asynchronously
    if (score < 50) {
      _aiService.generateAIAdaptedWorkout(
        state,
        'High fatigue detected (Score: $score%). Deload the workout for active recovery.',
      ).then((adaptedWorkout) {
        _firestore.saveDailyWorkout(uid, todayStr, adaptedWorkout);
        state = state.copyWith(
          adaptationNotice: 'High fatigue detected. AI adjusted your workout to an active recovery session.',
        );
        debugPrint('[AURA STATE] AI adapted workout for high fatigue recovery.');
      }).catchError((e) {
        debugPrint('[AURA STATE] AI workout adaptation failed: $e');
      });
    }
  }

  Future<QuickLogParsedResult> parseAndApplyQuickLog(String rawText) async {
    debugPrint('[AURA STATE] Parsing Express Quick-Log: "$rawText"');
    final result = await _aiService.parseQuickLog(rawText, state);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // 1. Update Workout Status if extracted
    DailyWorkout updatedWorkout = state.workout;
    if (result.workoutStatus != null) {
      updatedWorkout = updatedWorkout.copyWith(
        status: result.workoutStatus,
        adaptationNote: result.workoutReason ?? 'Updated via Express AI Log',
      );
      await _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    }

    // 2. Add Meals if extracted
    DailyNutrition updatedNutrition = state.nutrition;
    if (result.mealsToAdd.isNotEmpty) {
      final newMeals = List<MealItem>.from(updatedNutrition.meals)..addAll(result.mealsToAdd);
      updatedNutrition = updatedNutrition.copyWith(meals: newMeals);
      await _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
    }

    // 3. Update Recovery if extracted
    RecoveryCheckIn updatedRecovery = state.recovery;
    if (result.sleepHours != null || result.energyLevel != null) {
      final sleepH = result.sleepHours ?? updatedRecovery.sleepHours;
      final energy = result.energyLevel ?? updatedRecovery.energyLevel;
      final sleepScore = ((sleepH / 8.0).clamp(0.0, 1.2)) * 10 * (updatedRecovery.sleepQuality / 10.0);
      final score = ((sleepScore * 3.5) + (energy * 3.5) + ((10 - updatedRecovery.muscleSoreness) * 2.0) + ((10 - updatedRecovery.stressLevel) * 1.0)).round().clamp(20, 100);
      
      updatedRecovery = updatedRecovery.copyWith(
        sleepHours: sleepH,
        energyLevel: energy,
        recoveryScore: score,
      );
      await _firestore.saveDailyRecovery(uid, state.recovery.date, updatedRecovery);
    }

    // 4. Update Weight / Progress if extracted
    if (result.weightKg != null) {
      final updatedProfile = state.profile.copyWith(weightKg: result.weightKg!);
      final entry = ProgressEntry(date: todayStr, weightKg: result.weightKg!, notes: 'Express AI log weight');
      await _firestore.saveUserProfile(uid, updatedProfile);
      await _repository.saveProgressEntry(entry);
    }

    // 5. Append to Chat Log
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: rawText,
      timestamp: 'Just now',
    );
    final aiReply = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      sender: 'ai',
      text: '⚡ Express Log Processed:\n${result.coachFeedback}',
      timestamp: 'Just now',
    );

    await _firestore.saveChatMessage(uid, userMsg);
    await _firestore.saveChatMessage(uid, aiReply);

    return result;
  }

  Future<void> adaptTodayWorkoutWithAI(String request) async {
    debugPrint('[AURA STATE] Adapting workout with AI for: "$request"');
    final adaptedWorkout = await _aiService.adaptWorkoutWithAI(request, state);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    state = state.copyWith(
      workout: adaptedWorkout,
      adaptationNotice: 'Workout adapted via AURA AI: "${adaptedWorkout.adaptationNote ?? request}"',
    );
    await _firestore.saveDailyWorkout(uid, state.workout.date, adaptedWorkout);
  }

  void updateWorkoutStatus(WorkoutStatus status) {
    debugPrint('[AURA STATE] Updating workout status: ${status.name}');
    final updatedWorkout = state.workout.copyWith(status: status);
    state = state.copyWith(workout: updatedWorkout);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
  }

  void updateProfile(UserProfile updatedProfile) {
    debugPrint('[AURA STATE] Profile updated directly');
    state = state.copyWith(profile: updatedProfile);
    final uid = _auth.uid ?? 'firebase_user_vance_77';
    _firestore.saveUserProfile(uid, updatedProfile);
  }

  @override
  void dispose() {
    _workoutSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _recoverySubscription?.cancel();
    _chatMessagesSubscription?.cancel();
    super.dispose();
  }

  // ─── Master Context ───

  Future<void> _loadMasterContext(String uid) async {
    final ctx = await _firestore.getMasterContext(uid);
    if (ctx != null) {
      state = state.copyWith(masterContext: ctx);
      debugPrint('[AURA STATE] Loaded master context from Firestore');
    }
  }

  Future<void> buildAndSaveMasterContext() async {
    debugPrint('[AURA STATE] Building master context...');
    final uid = _auth.uid;
    if (uid == null) return;

    // Layer 3: Build rolling summary from current state
    final recentWorkouts = <Map<String, dynamic>>[
      {'date': state.workout.date, 'title': state.workout.title, 'status': state.workout.status.name},
    ];

    final n = state.nutrition;
    final totalCal = n.meals.fold(0, (total, m) => total + m.calories);
    final totalProt = n.meals.fold(0, (total, m) => total + m.proteinG);

    final nutritionAvg = <String, dynamic>{
      'avgCalories': totalCal,
      'avgProteinG': totalProt,
      'proteinHitRate': n.targetProteinG > 0 ? (totalProt / n.targetProteinG).clamp(0.0, 2.0) : 0.0,
    };

    final recoveryAvg = <String, dynamic>{
      'avgSleepHours': state.recovery.sleepHours,
      'avgRecoveryScore': state.recovery.recoveryScore,
      'avgSoreness': state.recovery.muscleSoreness,
    };

    final weightTrend = state.progressHistory
        .where((p) => p.weightKg > 0)
        .map((p) => <String, dynamic>{'date': p.date, 'kg': p.weightKg})
        .toList();

    final completedCount = state.workout.status == WorkoutStatus.completed ? 1 : 0;
    final skippedCount = state.workout.status == WorkoutStatus.skipped ? 1 : 0;

    final rollingSummary = RollingSummary(
      periodDays: 7,
      workoutComplianceRate: completedCount > 0 ? 1.0 : 0.0,
      workoutsCompleted: completedCount,
      workoutsSkipped: skippedCount,
      recentWorkouts: recentWorkouts,
      nutritionAvg: nutritionAvg,
      recoveryAvg: recoveryAvg,
      weightTrend: weightTrend,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final updatedCtx = state.masterContext.copyWith(
      rollingSummary: rollingSummary,
    );

    state = state.copyWith(masterContext: updatedCtx);
    await _firestore.saveMasterContext(uid, updatedCtx);
    debugPrint('[AURA STATE] Master context built and saved.');
  }

  Future<void> updateMasterContextDeduced({
    String? field,
    String? action,
    dynamic value,
  }) async {
    final uid = _auth.uid;
    if (uid == null) return;

    DeducedKnowledge updated = state.masterContext.deduced;

    switch (field) {
      case 'activityLevel':
        updated = updated.copyWith(activityLevel: value?.toString());
        break;
      case 'sessionDurationMin':
        updated = updated.copyWith(sessionDurationMin: (value as num?)?.toInt());
        break;
      case 'preferredTrainingStyle':
        updated = updated.copyWith(preferredTrainingStyle: value?.toString());
        break;
      case 'cardioPreference':
        updated = updated.copyWith(cardioPreference: value?.toString());
        break;
      case 'activeInjuries':
        if (action == 'append' && value is String) {
          final newList = List<String>.from(updated.activeInjuries)..add(value);
          updated = updated.copyWith(activeInjuries: newList);
        } else if (value is List) {
          updated = updated.copyWith(activeInjuries: value.map((e) => e.toString()).toList());
        }
        break;
      case 'foodAllergies':
        if (action == 'append' && value is String) {
          final newList = List<String>.from(updated.foodAllergies)..add(value);
          updated = updated.copyWith(foodAllergies: newList);
        } else if (value is List) {
          updated = updated.copyWith(foodAllergies: value.map((e) => e.toString()).toList());
        }
        break;
      case 'dislikedExercises':
        if (action == 'append' && value is String) {
          final newList = List<String>.from(updated.dislikedExercises)..add(value);
          updated = updated.copyWith(dislikedExercises: newList);
        } else if (value is List) {
          updated = updated.copyWith(dislikedExercises: value.map((e) => e.toString()).toList());
        }
        break;
      case 'preferredProteinSources':
        if (action == 'append' && value is String) {
          final newList = List<String>.from(updated.preferredProteinSources)..add(value);
          updated = updated.copyWith(preferredProteinSources: newList);
        } else if (value is List) {
          updated = updated.copyWith(preferredProteinSources: value.map((e) => e.toString()).toList());
        }
        break;
      case 'personalNotes':
        if (action == 'append' && value is String) {
          final newList = List<String>.from(updated.personalNotes)..add(value);
          updated = updated.copyWith(personalNotes: newList);
        }
        break;
      case 'preferredTrainingDays':
        if (value is List) {
          updated = updated.copyWith(preferredTrainingDays: value.map((e) => e.toString()).toList());
        }
        break;
    }

    updated = updated.copyWith(lastUpdated: DateTime.now().toIso8601String());
    final updatedCtx = state.masterContext.copyWith(deduced: updated);
    
    // Also synchronize canonical profile
    final updatedProf = state.profile.copyWith(
      activeInjuries: updated.activeInjuries,
      dislikedExercises: updated.dislikedExercises,
      personalNotes: updated.personalNotes,
    );

    state = state.copyWith(masterContext: updatedCtx, profile: updatedProf);
    await _firestore.saveMasterContext(uid, updatedCtx);
    await _firestore.saveUserProfile(uid, updatedProf);
    debugPrint('[AURA STATE] Master context deduced.$field & UserProfile updated.');
  }

  // ─── Weekly Plan ───

  String _currentWeekId() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekNumber = ((monday.difference(DateTime(monday.year, 1, 1)).inDays) / 7).ceil() + 1;
    return '${monday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCurrentWeeklyPlan(String uid) async {
    final weekId = _currentWeekId();
    final plan = await _firestore.getWeeklyPlan(uid, weekId);
    if (plan != null) {
      state = state.copyWith(weeklyPlan: plan);
      debugPrint('[AURA STATE] Loaded weekly plan for $weekId');
    }
  }

  Future<void> generateWeeklyPlan() async {
    debugPrint('[AURA STATE] Generating AI weekly plan...');
    state = state.copyWith(isAiThinking: true);

    try {
      final plan = await _aiService.generateAIWeeklyPlan(state);
      state = state.copyWith(weeklyPlan: plan, isAiThinking: false);

      final uid = _auth.uid;
      if (uid != null) {
        await _firestore.saveWeeklyPlan(uid, plan);
      }
      debugPrint('[AURA STATE] Weekly plan generated and saved: ${plan.weekId}');
    } catch (e) {
      debugPrint('[AURA STATE] Weekly plan generation failed: $e');
      state = state.copyWith(isAiThinking: false);
    }
  }
}

final transformationEngineProvider =
    StateNotifierProvider<TransformationEngineNotifier, TransformationEngineState>((ref) {
  return TransformationEngineNotifier();
});
