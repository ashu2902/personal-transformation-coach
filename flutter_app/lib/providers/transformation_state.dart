import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/transformation_repository.dart';
import '../engine/exercise_database.dart';
import '../engine/transformation_orchestrator.dart';
import '../services/ai_service.dart';

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
  });

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

  TransformationEngineNotifier({ITransformationRepository? repository})
      : _repository = repository ?? LocalTransformationRepository(),
        super(_initialState()) {
    initFromRepository();
  }

  Future<void> initFromRepository() async {
    debugPrint('[AURA STATE] Initializing state from repository...');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final savedApiKey = await _repository.loadApiKey() ?? const String.fromEnvironment('GEMINI_API_KEY');
    if (savedApiKey.isNotEmpty) {
      _aiService = GeminiAIProvider(apiKey: savedApiKey);
      state = state.copyWith(apiKey: savedApiKey);
    }

    final savedProfile = await _repository.loadProfile();
    if (savedProfile == null || savedProfile.name.isEmpty) {
      debugPrint('[AURA STATE] No saved profile found. Setting isOnboardingComplete = false');
      state = state.copyWith(isOnboardingComplete: false);
      return;
    }

    // Load today's workout — if none saved, use a lean placeholder (AI will set it during onboarding)
    final savedWorkout = await _repository.loadTodayWorkout(todayStr);
    final savedNutrition = await _repository.loadTodayNutrition(todayStr);
    final savedRecovery = await _repository.loadTodayRecovery(todayStr) ?? state.recovery;
    final savedProgress = await _repository.loadProgressHistory();

    // If high fatigue, ask AI to adapt asynchronously
    if (savedRecovery.recoveryScore < 50 && savedWorkout != null) {
      try {
        final adaptedWorkout = await _aiService.generateAIAdaptedWorkout(
          state.copyWith(
            profile: savedProfile,
            workout: savedWorkout,
            nutrition: savedNutrition ?? state.nutrition,
            recovery: savedRecovery,
            progressHistory: savedProgress,
          ),
          'High fatigue detected (Score: ${savedRecovery.recoveryScore}%). Deload for active recovery.',
        );
        debugPrint('[AURA STATE] AI adapted workout for high fatigue.');
        state = state.copyWith(
          profile: savedProfile,
          workout: adaptedWorkout,
          nutrition: savedNutrition ?? state.nutrition,
          recovery: savedRecovery,
          progressHistory: savedProgress.isEmpty ? state.progressHistory : savedProgress,
          chatMessages: state.chatMessages,
          isOnboardingComplete: true,
          adaptationNotice: 'High fatigue detected. Your workout has been adjusted for active recovery.',
          apiKey: savedApiKey,
        );
        return;
      } catch (e) {
        debugPrint('[AURA STATE] AI adaptation failed: $e');
      }
    }

    debugPrint('[AURA STATE] State successfully initialized for user: ${savedProfile.name}');
    state = TransformationEngineState(
      profile: savedProfile,
      workout: savedWorkout ?? state.workout,
      nutrition: savedNutrition ?? state.nutrition,
      recovery: savedRecovery,
      progressHistory: savedProgress.isEmpty ? state.progressHistory : savedProgress,
      chatMessages: state.chatMessages,
      isOnboardingComplete: true,
      adaptationNotice: null,
      apiKey: savedApiKey,
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
      availableEquipment: [
        EquipmentType.dumbbells,
        EquipmentType.barbell,
        EquipmentType.cables,
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
          text: "Welcome back, Alex. Transformation baseline active. Ready for today's workout?",
          timestamp: '09:00 AM',
        )
      ],
      isOnboardingComplete: true,
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
    );

    await _repository.saveProfile(newProfile);
    await _repository.saveTodayNutrition(nutrition);
    await _repository.saveTodayWorkout(workout);
    await _repository.saveProgressEntry(initProgress);
    debugPrint('[AURA STATE] Onboarding completed & baseline saved to localStorage!');
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
    _repository.saveTodayWorkout(updatedWorkout);
  }

  void substituteExercise(String exerciseId, ExerciseDefinition newDefinition) {
    debugPrint('[AURA STATE] Substituting exercise $exerciseId -> ${newDefinition.name}');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      return ex.copyWith(
        name: newDefinition.name,
        targetMuscle: newDefinition.targetMuscle,
        equipmentRequired: newDefinition.equipment,
        notes: 'Substituted for ${ex.name}',
      );
    }).toList();

    final updatedWorkout = state.workout.copyWith(exercises: updatedExercises);
    state = state.copyWith(workout: updatedWorkout);
    _repository.saveTodayWorkout(updatedWorkout);
  }

  void trackProgressForToday() {
    debugPrint('[AURA STATE] Marking daily progress tracked for today');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final existing = state.progressHistory.any((p) => p.date == todayStr);

    List<ProgressEntry> newHistory = List.from(state.progressHistory);
    final todayEntry = ProgressEntry(
      date: todayStr,
      weightKg: state.profile.weightKg,
      notes: 'Quick daily check-in',
    );

    if (!existing) {
      newHistory.add(todayEntry);
    }

    WorkoutStatus updatedWorkoutStatus = state.workout.status;
    if (updatedWorkoutStatus == WorkoutStatus.skipped) {
      updatedWorkoutStatus = WorkoutStatus.scheduled;
    }

    final updatedWorkout = state.workout.copyWith(status: updatedWorkoutStatus);

    state = state.copyWith(
      progressHistory: newHistory,
      workout: updatedWorkout,
    );

    _repository.saveProgressEntry(todayEntry);
    _repository.saveTodayWorkout(updatedWorkout);
  }

  void addWater(int amountMl) {
    final newWater = state.nutrition.waterMl + amountMl;
    debugPrint('[AURA STATE] Added +${amountMl}ml water (Total: ${newWater}ml)');
    final updatedNutrition = state.nutrition.copyWith(waterMl: newWater);
    state = state.copyWith(nutrition: updatedNutrition);
    _repository.saveTodayNutrition(updatedNutrition);
  }

  void addMeal(MealItem meal) {
    debugPrint('[AURA STATE] Added meal: ${meal.name} (${meal.calories} kcal, ${meal.proteinG}g P)');
    final newMeals = List<MealItem>.from(state.nutrition.meals)..add(meal);
    final updatedNutrition = state.nutrition.copyWith(meals: newMeals);
    state = state.copyWith(nutrition: updatedNutrition);
    _repository.saveTodayNutrition(updatedNutrition);
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
    _repository.saveProfile(updatedProfile);
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
          state = state.copyWith(
            nutrition: adaptedNutrition,
            adaptationNotice: 'Weight progress stalled. AI adjusted your daily calorie target.',
          );
          _repository.saveTodayNutrition(adaptedNutrition);
          debugPrint('[AURA STATE] AI nutrition adapted for weight stall.');
        }).catchError((e) {
          debugPrint('[AURA STATE] AI nutrition adaptation failed: $e');
        });
      }
    }
  }

  AIService _aiService = GeminiAIProvider(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
  AIService get aiService => _aiService;

  Future<void> addChatMessage(String text) async {
    debugPrint('[AURA STATE] User message: $text');
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: 'Just now',
    );

    state = state.copyWith(
      chatMessages: List.from(state.chatMessages)..add(userMsg),
      isAiThinking: true,
    );

    final responseText = await _aiService.generateCoachResponse(text, state);
    debugPrint('[AURA STATE] AI Coach reply generated');

    final aiReply = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      sender: 'ai',
      text: responseText,
      timestamp: 'Just now',
    );

    state = state.copyWith(
      chatMessages: List.from(state.chatMessages)..add(aiReply),
      isAiThinking: false,
    );
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
    
    // Simulate updating today's metrics
    final updatedWorkout = state.workout.copyWith(
      status: WorkoutStatus.completed,
    );
    
    state = state.copyWith(
      chatMessages: List.from(state.chatMessages)..add(scanReply),
      isAiThinking: false,
      workout: updatedWorkout,
    );
    _repository.saveTodayWorkout(updatedWorkout);
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

    state = state.copyWith(
      recovery: updatedRecovery,
    );
    _repository.saveTodayRecovery(updatedRecovery);

    // If high fatigue, ask AI to adapt workout asynchronously
    if (score < 50) {
      _aiService.generateAIAdaptedWorkout(
        state,
        'High fatigue detected (Score: $score%). Deload the workout for active recovery.',
      ).then((adaptedWorkout) {
        state = state.copyWith(
          workout: adaptedWorkout,
          adaptationNotice: 'High fatigue detected. AI adjusted your workout to an active recovery session.',
        );
        _repository.saveTodayWorkout(adaptedWorkout);
        debugPrint('[AURA STATE] AI adapted workout for high fatigue recovery.');
      }).catchError((e) {
        debugPrint('[AURA STATE] AI workout adaptation failed: $e');
      });
    }
  }

  Future<QuickLogParsedResult> parseAndApplyQuickLog(String rawText) async {
    debugPrint('[AURA STATE] Parsing Express Quick-Log: "$rawText"');
    final result = await _aiService.parseQuickLog(rawText, state);

    // 1. Update Workout Status if extracted
    DailyWorkout updatedWorkout = state.workout;
    if (result.workoutStatus != null) {
      updatedWorkout = updatedWorkout.copyWith(
        status: result.workoutStatus,
        adaptationNote: result.workoutReason ?? 'Updated via Express AI Log',
      );
    }

    // 2. Add Meals if extracted
    DailyNutrition updatedNutrition = state.nutrition;
    if (result.mealsToAdd.isNotEmpty) {
      final newMeals = List<MealItem>.from(updatedNutrition.meals)..addAll(result.mealsToAdd);
      updatedNutrition = updatedNutrition.copyWith(meals: newMeals);
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
    }

    // 4. Update Weight / Progress if extracted
    UserProfile updatedProfile = state.profile;
    List<ProgressEntry> updatedHistory = List.from(state.progressHistory);
    if (result.weightKg != null) {
      updatedProfile = updatedProfile.copyWith(weightKg: result.weightKg!);
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final entry = ProgressEntry(date: todayStr, weightKg: result.weightKg!, notes: 'Express AI log weight');
      updatedHistory.add(entry);
      _repository.saveProgressEntry(entry);
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
    final updatedChat = List<ChatMessage>.from(state.chatMessages)..addAll([userMsg, aiReply]);

    state = state.copyWith(
      workout: updatedWorkout,
      nutrition: updatedNutrition,
      recovery: updatedRecovery,
      profile: updatedProfile,
      progressHistory: updatedHistory,
      chatMessages: updatedChat,
    );

    _repository.saveTodayWorkout(updatedWorkout);
    _repository.saveTodayNutrition(updatedNutrition);
    _repository.saveTodayRecovery(updatedRecovery);
    _repository.saveProfile(updatedProfile);

    return result;
  }

  Future<void> adaptTodayWorkoutWithAI(String request) async {
    debugPrint('[AURA STATE] Adapting workout with AI for: "$request"');
    final adaptedWorkout = await _aiService.adaptWorkoutWithAI(request, state);
    state = state.copyWith(
      workout: adaptedWorkout,
      adaptationNotice: 'Workout adapted via AURA AI: "${adaptedWorkout.adaptationNote}"',
    );
    await _repository.saveTodayWorkout(adaptedWorkout);
  }

  void updateWorkoutStatus(WorkoutStatus status) {
    debugPrint('[AURA STATE] Updating workout status: ${status.name}');
    final updatedWorkout = state.workout.copyWith(status: status);
    state = state.copyWith(workout: updatedWorkout);
    _repository.saveTodayWorkout(updatedWorkout);
  }

  void updateProfile(UserProfile updatedProfile) {
    debugPrint('[AURA STATE] Profile updated directly');
    state = state.copyWith(profile: updatedProfile);
    _repository.saveProfile(updatedProfile);
  }
}

final transformationEngineProvider =
    StateNotifierProvider<TransformationEngineNotifier, TransformationEngineState>((ref) {
  return TransformationEngineNotifier();
});
