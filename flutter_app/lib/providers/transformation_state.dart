import 'dart:async';
import 'dart:convert';
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
  final bool isInitializing;
  final String? adaptationNotice;
  final bool isAiThinking;
  final WeeklyPlan? weeklyPlan;
  final MasterContext masterContext;
  final Map<String, DailyWorkout> recentWorkouts;

  TransformationEngineState({
    required this.profile,
    required this.workout,
    required this.nutrition,
    required this.recovery,
    required this.progressHistory,
    required this.chatMessages,
    this.isOnboardingComplete = true,
    this.isInitializing = true,
    this.adaptationNotice,
    this.isAiThinking = false,
    this.weeklyPlan,
    MasterContext? masterContext,
    Map<String, DailyWorkout>? recentWorkouts,
  })  : masterContext = masterContext ?? MasterContext(),
        recentWorkouts = recentWorkouts ?? const {};

  TransformationEngineState copyWith({
    UserProfile? profile,
    DailyWorkout? workout,
    DailyNutrition? nutrition,
    RecoveryCheckIn? recovery,
    List<ProgressEntry>? progressHistory,
    List<ChatMessage>? chatMessages,
    bool? isOnboardingComplete,
    bool? isInitializing,
    String? adaptationNotice,
    bool? isAiThinking,
    WeeklyPlan? weeklyPlan,
    MasterContext? masterContext,
    Map<String, DailyWorkout>? recentWorkouts,
  }) {
    return TransformationEngineState(
      profile: profile ?? this.profile,
      workout: workout ?? this.workout,
      nutrition: nutrition ?? this.nutrition,
      recovery: recovery ?? this.recovery,
      progressHistory: progressHistory ?? this.progressHistory,
      chatMessages: chatMessages ?? this.chatMessages,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      isInitializing: isInitializing ?? this.isInitializing,
      adaptationNotice: adaptationNotice ?? this.adaptationNotice,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
      masterContext: masterContext ?? this.masterContext,
      recentWorkouts: recentWorkouts ?? this.recentWorkouts,
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

  /// Evaluates if progress is accounted for (logged or marked skipped) for a given date
  bool isProgressTrackedForDate(String dateStr) {
    final hasProgressEntry = progressHistory.any((p) => p.date == dateStr);
    final hasRecentWorkout = recentWorkouts.containsKey(dateStr);
    final hasWorkoutActivity = workout.date == dateStr &&
        (workout.status == WorkoutStatus.completed ||
            workout.status == WorkoutStatus.skipped ||
            workout.exercises.any((ex) => ex.sets.any((s) => s.completed)));
    return hasProgressEntry || hasRecentWorkout || hasWorkoutActivity;
  }

  /// Determines if a workout was specifically completed (not skipped) on a date
  bool isWorkoutCompletedForDate(String dateStr) {
    if (workout.date == dateStr &&
        (workout.status == WorkoutStatus.completed ||
            workout.exercises.any((ex) => ex.sets.any((s) => s.completed)))) {
      return true;
    }
    final recent = recentWorkouts[dateStr];
    if (recent != null &&
        (recent.status == WorkoutStatus.completed ||
            recent.exercises.any((ex) => ex.sets.any((s) => s.completed)))) {
      return true;
    }
    final entry = progressHistory.where((p) => p.date == dateStr).firstOrNull;
    if (entry != null) {
      if (entry.workoutStatus == WorkoutStatus.completed) return true;
      if (entry.workoutStatus == WorkoutStatus.skipped) return false;
      final notes = (entry.notes ?? '').toLowerCase();
      if (notes.contains('skipped')) return false;
      if (notes.contains('workout') || notes.contains('session')) return true;
    }
    return false;
  }

  /// Determines if a workout was specifically marked skipped on a date
  bool isWorkoutSkippedForDate(String dateStr) {
    if (workout.date == dateStr && workout.status == WorkoutStatus.skipped) {
      return true;
    }
    final recent = recentWorkouts[dateStr];
    if (recent != null && recent.status == WorkoutStatus.skipped) {
      return true;
    }
    final entry = progressHistory.where((p) => p.date == dateStr).firstOrNull;
    if (entry != null) {
      if (entry.workoutStatus == WorkoutStatus.skipped) return true;
      final notes = (entry.notes ?? '').toLowerCase();
      if (notes.contains('skipped')) return true;
    }
    return false;
  }

  /// Gets the concrete logged workout for a given date if one exists
  DailyWorkout? getWorkoutForDate(String dateStr) {
    if (workout.date == dateStr &&
        (workout.status == WorkoutStatus.completed || workout.exercises.isNotEmpty)) {
      return workout;
    }
    return recentWorkouts[dateStr];
  }

  /// Calculates effective workout status (if progress is untracked, treat as skipped/did not work out)
  WorkoutStatus get effectiveTodayWorkoutStatus {
    final isTracked = isProgressTrackedForDate(workout.date);
    if (!isTracked && workout.status != WorkoutStatus.completed) {
      return WorkoutStatus.skipped;
    }
    return workout.status;
  }

  /// Unlogged past days in the current week (from Monday up to yesterday)
  List<Map<String, String>> get unloggedPreviousDays {
    final List<Map<String, String>> unlogged = [];
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysPassed = now.weekday - 1; // Number of days before today in this week

    // Creation date of user account (defaults to today if brand new)
    final creationDateStr = profile.createdAtDateStr ?? todayStr;

    for (int i = 0; i < daysPassed; i++) {
      final d = monday.add(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];

      // IGNORE past days that occurred BEFORE the user created their account!
      if (dateStr.compareTo(creationDateStr) < 0) {
        continue;
      }

      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

      final isTracked = isProgressTrackedForDate(dateStr);
      if (!isTracked) {
        unlogged.add({
          'date': dateStr,
          'dayName': dayName,
          'displayDate': '${d.month}/${d.day}',
        });
      }
    }
    return unlogged;
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

      final isCompleted = isWorkoutCompletedForDate(dateStr);
      final isSkipped = isWorkoutSkippedForDate(dateStr);

      WorkoutStatus status = WorkoutStatus.scheduled;
      if (isCompleted) {
        status = WorkoutStatus.completed;
      } else if (isSkipped) {
        status = WorkoutStatus.skipped;
      }

      result.add(DayTrackingStatus(
        date: dateStr,
        dayLabel: dayLabel,
        isTracked: isCompleted,
        workoutStatus: status,
        statusText: isCompleted
            ? 'Worked Out & Tracked'
            : (isSkipped ? 'Skipped / Rest Day' : 'Untracked'),
      ));
    }
    return result;
  }
}

class TransformationEngineNotifier extends StateNotifier<TransformationEngineState> {
  final ITransformationRepository _repository;
  final FirebaseFirestoreService _firestore = FirebaseFirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final AIService _aiService = GeminiAIProvider();
  AIService get aiService => _aiService;

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

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] No authenticated Firebase user. Setting isOnboardingComplete = false');
      state = state.copyWith(isOnboardingComplete: false, isInitializing: false);
      return;
    }

    try {
      final weekId = _currentWeekId();
      // Parallel fetch: profile, weekly plan, master context, progress history, recent workouts
      final profileFuture = _firestore.getUserProfile(uid);
      final weeklyPlanFuture = _firestore.getWeeklyPlan(uid, weekId);
      final masterCtxFuture = _firestore.getMasterContext(uid);
      final progressFuture = _firestore.getProgressHistory(uid);
      final recentWorkoutsFuture = _firestore.getRecentWorkouts(uid);

      final results = await Future.wait([
        profileFuture,
        weeklyPlanFuture,
        masterCtxFuture,
        progressFuture,
        recentWorkoutsFuture,
      ]);

      final profile = results[0] as UserProfile?;
      final weeklyPlan = results[1] as WeeklyPlan?;
      final masterCtx = results[2] as MasterContext?;
      final progressHist = results[3] as List<ProgressEntry>?;
      final recentWorkoutsMap = results[4] as Map<String, DailyWorkout>?;

      if (profile == null || profile.name.isEmpty) {
        debugPrint('[AURA STATE] No remote profile found for UID $uid. Setting isOnboardingComplete = false');
        state = state.copyWith(isOnboardingComplete: false, isInitializing: false);
        return;
      }

      state = state.copyWith(
        profile: profile,
        weeklyPlan: weeklyPlan ?? state.weeklyPlan,
        masterContext: masterCtx ?? state.masterContext,
        progressHistory: (progressHist != null && progressHist.isNotEmpty)
            ? progressHist
            : state.progressHistory,
        recentWorkouts: recentWorkoutsMap ?? state.recentWorkouts,
        isOnboardingComplete: true,
        isInitializing: false,
      );

      // Setup real-time subscriptions for logs and chats
      setupSubscriptions(uid);
    } catch (e) {
      debugPrint('[AURA STATE] initFromRepository error: $e');
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<void> _autoDeriveTodayWorkoutIfMissing(String uid, String todayStr) async {
    DailyWorkout? derivedWorkout;
    if (state.weeklyPlan != null) {
      final now = DateTime.now();
      final dayIndex = now.weekday - 1; // 0 for Monday, 6 for Sunday
      if (dayIndex >= 0 && dayIndex < state.weeklyPlan!.days.length) {
        final dayPlan = state.weeklyPlan!.days[dayIndex];
        if (dayPlan.isRestDay) {
          derivedWorkout = DailyWorkout(
            id: 'plan_rest_$todayStr',
            date: todayStr,
            title: 'Active Recovery & Rest',
            focusArea: 'Mobility & Recovery',
            estimatedDurationMin: 20,
            status: WorkoutStatus.scheduled,
            exercises: [],
            adaptationNote: 'Scheduled rest day from weekly plan.',
          );
        } else {
          final exercises = dayPlan.exerciseNames.map((name) {
            return Exercise(
              id: 'ex_${name.toLowerCase().replaceAll(' ', '_')}',
              name: name,
              targetMuscle: dayPlan.focusArea,
              equipmentRequired: 'bodyweight',
              sets: [
                ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0.0),
                ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 0.0),
                ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0.0),
              ],
            );
          }).toList();

          derivedWorkout = DailyWorkout(
            id: 'plan_$todayStr',
            date: todayStr,
            title: dayPlan.title,
            focusArea: dayPlan.focusArea,
            estimatedDurationMin: 45,
            status: WorkoutStatus.scheduled,
            exercises: exercises,
            adaptationNote: dayPlan.nutritionFocus,
          );
        }
      }
    }

    derivedWorkout ??= DailyWorkout(
      id: 'baseline_$todayStr',
      date: todayStr,
      title: "Today's Prescribed Session",
      focusArea: "General Readiness",
      estimatedDurationMin: 40,
      status: WorkoutStatus.scheduled,
      exercises: [
        Exercise(
          id: 'ex_pushups',
          name: 'Push-ups',
          targetMuscle: 'Chest & Core',
          equipmentRequired: 'bodyweight',
          sets: [
            ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 0.0),
            ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 0.0),
            ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0.0),
          ],
        ),
        Exercise(
          id: 'ex_squats',
          name: 'Bodyweight Squats',
          targetMuscle: 'Quadriceps & Glutes',
          equipmentRequired: 'bodyweight',
          sets: [
            ExerciseSet(setNumber: 1, targetReps: 15, targetWeightKg: 0.0),
            ExerciseSet(setNumber: 2, targetReps: 15, targetWeightKg: 0.0),
            ExerciseSet(setNumber: 3, targetReps: 15, targetWeightKg: 0.0),
          ],
        ),
      ],
    );

    state = state.copyWith(workout: derivedWorkout);
    await _firestore.saveDailyWorkout(uid, todayStr, derivedWorkout);
    debugPrint('[AURA STATE] Auto-derived workout saved for $todayStr: ${derivedWorkout.title}');
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
      } else {
        // Auto-derive today's workout if none exists yet
        _autoDeriveTodayWorkoutIfMissing(uid, todayStr);
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
      } else {
        // Reset nutrition to fresh empty slate for today
        final freshNutrition = DailyNutrition(
          date: todayStr,
          targetCalories: state.nutrition.targetCalories,
          targetProteinG: state.nutrition.targetProteinG,
          targetCarbsG: state.nutrition.targetCarbsG,
          targetFatG: state.nutrition.targetFatG,
          targetWaterMl: 2800,
          waterMl: 0,
          meals: [],
        );
        state = state.copyWith(nutrition: freshNutrition);
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
        DateTime? msgTime;

        if (data['serverTimestamp'] != null && data['serverTimestamp'] is Timestamp) {
          msgTime = (data['serverTimestamp'] as Timestamp).toDate();
        } else if (data['timestamp'] != null && data['timestamp'] != 'Just now') {
          msgTime = DateTime.tryParse(data['timestamp'].toString());
        }

        // Fallback: If doc ID is millisecondsSinceEpoch (numeric string)
        if (msgTime == null) {
          final epoch = int.tryParse(doc.id);
          if (epoch != null && epoch > 1000000000000) {
            msgTime = DateTime.fromMillisecondsSinceEpoch(epoch);
          }
        }
        msgTime ??= DateTime.now();

        Uint8List? imgBytes;
        if (data['imageBase64'] != null && data['imageBase64'] is String && (data['imageBase64'] as String).isNotEmpty) {
          try {
            imgBytes = base64Decode(data['imageBase64'] as String);
          } catch (e) {
            debugPrint('[AURA STATE] Image decode error: $e');
          }
        }

        messages.add(ChatMessage(
          id: data['id'] ?? doc.id,
          sender: data['sender'] ?? 'ai',
          text: data['text'] ?? '',
          timestamp: msgTime.toIso8601String(),
          createdAt: msgTime,
          imageBytes: imgBytes,
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
      sleepHours: 8.0,
      sleepQuality: 9,
      muscleSoreness: 0,
      energyLevel: 9,
      stressLevel: 2,
      recoveryScore: 95,
      status: 'Optimal / Rested',
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

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] Error: Cannot complete onboarding without an authenticated UID');
      return;
    }
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

  Future<bool> signInAndLoadUserProfile({bool useGoogleAuth = true}) async {
    try {
      UserCredential? cred;
      if (useGoogleAuth) {
        cred = await _auth.signInWithGoogle();
      } else {
        cred = await _auth.signInAnonymously();
      }

      final uid = cred?.user?.uid ?? _auth.uid;
      if (uid == null) return false;

      final existingProfile = await _firestore.getUserProfile(uid);
      if (existingProfile != null && existingProfile.name.isNotEmpty) {
        state = state.copyWith(
          profile: existingProfile,
          isOnboardingComplete: true,
          adaptationNotice: "Welcome back, ${existingProfile.name}! Your transformation state has been synced.",
        );

        setupSubscriptions(uid);
        _loadMasterContext(uid);
        _loadCurrentWeeklyPlan(uid);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AURA STATE] Sign in error: $e');
      return false;
    }
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

    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    }
  }

  void markAllExercisesCompleted() {
    debugPrint('[AURA STATE] Marking all workout exercises & sets completed in bulk');
    final updatedExercises = state.workout.exercises.map((ex) {
      final updatedSets = ex.sets.map((s) => s.copyWith(completed: true)).toList();
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final updatedWorkout = state.workout.copyWith(
      exercises: updatedExercises,
      status: WorkoutStatus.completed,
    );
    state = state.copyWith(workout: updatedWorkout);

    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    }
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
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    }
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
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, todayStr, updatedWorkout);
    }
  }

  Future<void> markPastWorkoutSkipped(String dateStr) async {
    debugPrint('[AURA STATE] Marking past workout for $dateStr as skipped');
    final entry = ProgressEntry(
      date: dateStr,
      weightKg: state.profile.weightKg,
      notes: 'Marked skipped',
      workoutStatus: WorkoutStatus.skipped,
    );
    final skippedWorkout = DailyWorkout(
      id: 'skipped_$dateStr',
      date: dateStr,
      title: 'Rest / Skipped Session',
      focusArea: 'Rest',
      estimatedDurationMin: 0,
      status: WorkoutStatus.skipped,
      exercises: [],
    );
    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
      ..[dateStr] = skippedWorkout;
    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == dateStr)
      ..add(entry);
    state = state.copyWith(
      progressHistory: newHistory,
      recentWorkouts: updatedRecent,
    );

    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveProgress(uid, dateStr, entry);
      await _firestore.saveDailyWorkout(uid, dateStr, skippedWorkout);
    }
  }

  Future<DailyWorkout> parseWorkoutFromText(String naturalText, {String? targetDate}) async {
    debugPrint('[AURA STATE] AI parsing natural workout text: "$naturalText"');
    state = state.copyWith(isAiThinking: true);
    try {
      final parsed = await _aiService.parseWorkoutFromNaturalText(
        naturalText,
        state,
        targetDate: targetDate,
      );
      state = state.copyWith(isAiThinking: false);
      return parsed;
    } catch (e) {
      debugPrint('[AURA STATE] parseWorkoutFromText error: $e');
      state = state.copyWith(isAiThinking: false);
      rethrow;
    }
  }

  Future<void> confirmAndSaveParsedWorkout(DailyWorkout workout, {String? targetDate}) async {
    final effectiveDate = targetDate ?? workout.date;
    final normalizedWorkout = workout.copyWith(
      date: effectiveDate,
      status: WorkoutStatus.completed,
    );
    debugPrint('[AURA STATE] Confirming and saving workout for $effectiveDate: ${normalizedWorkout.title}');

    final isToday = effectiveDate == DateTime.now().toIso8601String().split('T')[0];
    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
      ..[effectiveDate] = normalizedWorkout;

    final entry = ProgressEntry(
      date: effectiveDate,
      weightKg: state.profile.weightKg,
      notes: 'Workout: ${normalizedWorkout.title} (${normalizedWorkout.exercises.length} exercises)',
      workoutStatus: WorkoutStatus.completed,
    );
    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == effectiveDate)
      ..add(entry);

    state = state.copyWith(
      workout: isToday ? normalizedWorkout : state.workout,
      progressHistory: newHistory,
      recentWorkouts: updatedRecent,
    );

    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveDailyWorkout(uid, effectiveDate, normalizedWorkout);
      await _firestore.saveProgress(uid, effectiveDate, entry);
    }
  }

  void checkAndRefreshForNewDay() {
    final nowStr = DateTime.now().toIso8601String().split('T')[0];
    if (state.workout.date != nowStr) {
      debugPrint('[AURA STATE] Day change detected on app resume! Refreshing for $nowStr');
      final uid = _auth.uid;
      if (uid != null) {
        setupSubscriptions(uid);
      }
    }
  }

  void addWater(int amountMl) {
    final newWater = state.nutrition.waterMl + amountMl;
    debugPrint('[AURA STATE] Added +${amountMl}ml water (Total: ${newWater}ml)');
    final updatedNutrition = state.nutrition.copyWith(waterMl: newWater);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
    }
  }

  void addMeal(MealItem meal) {
    debugPrint('[AURA STATE] Added meal: ${meal.name} (${meal.calories} kcal, ${meal.proteinG}g P)');
    final newMeals = List<MealItem>.from(state.nutrition.meals)..add(meal);
    final updatedNutrition = state.nutrition.copyWith(meals: newMeals);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
    }
  }

  void clearTodayNutrition() {
    debugPrint('[AURA STATE] Clearing today\'s logged nutrition entries...');
    final updatedNutrition = state.nutrition.copyWith(meals: []);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
    }
  }

  String _resolveTargetDate(String? rawDate) {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    if (rawDate == null || rawDate.isEmpty || rawDate.toLowerCase() == 'today') {
      return todayStr;
    }
    if (rawDate.toLowerCase() == 'yesterday') {
      final yesterday = today.subtract(const Duration(days: 1));
      return yesterday.toIso8601String().split('T')[0];
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
      return rawDate;
    }
    return todayStr;
  }

  Future<void> logNutritionForDate({
    required List<MealItem> newMeals,
    int? waterMl,
    String? rawDate,
  }) async {
    final uid = _auth.uid;
    final targetDate = _resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    debugPrint('[AURA STATE] Logging nutrition for date: $targetDate (Today: $todayStr)');

    if (targetDate == todayStr) {
      final combined = List<MealItem>.from(state.nutrition.meals)..addAll(newMeals);
      var updated = state.nutrition.copyWith(meals: combined);
      if (waterMl != null && waterMl > 0) {
        updated = updated.copyWith(waterMl: updated.waterMl + waterMl);
      }
      state = state.copyWith(nutrition: updated);
      if (uid != null) {
        await _firestore.saveDailyNutrition(uid, todayStr, updated);
      }
    } else {
      if (uid != null) {
        DailyNutrition existing = await _firestore.getDailyNutrition(uid, targetDate);
        final combined = List<MealItem>.from(existing.meals)..addAll(newMeals);
        var updated = existing.copyWith(date: targetDate, meals: combined);
        if (waterMl != null && waterMl > 0) {
          updated = updated.copyWith(waterMl: updated.waterMl + waterMl);
        }
        await _firestore.saveDailyNutrition(uid, targetDate, updated);
      }
    }
  }

  Future<void> removeMealFromDate({
    required String mealName,
    String? rawDate,
  }) async {
    final uid = _auth.uid;
    final targetDate = _resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final search = mealName.toLowerCase();

    debugPrint('[AURA STATE] Removing meal "$mealName" for date: $targetDate');

    if (targetDate == todayStr) {
      final updatedMeals = state.nutrition.meals.where((m) => !m.name.toLowerCase().contains(search)).toList();
      final updated = state.nutrition.copyWith(meals: updatedMeals);
      state = state.copyWith(nutrition: updated);
      if (uid != null) {
        await _firestore.saveDailyNutrition(uid, todayStr, updated);
      }
    } else {
      if (uid != null) {
        DailyNutrition existing = await _firestore.getDailyNutrition(uid, targetDate);
        final updatedMeals = existing.meals.where((m) => !m.name.toLowerCase().contains(search)).toList();
        final updated = existing.copyWith(meals: updatedMeals);
        await _firestore.saveDailyNutrition(uid, targetDate, updated);
      }
    }
  }

  Future<void> updateMealPortionForDate({
    required String mealName,
    required num calories,
    required num proteinG,
    required num carbsG,
    required num fatG,
    String? rawDate,
  }) async {
    final uid = _auth.uid;
    final targetDate = _resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final search = mealName.toLowerCase();

    debugPrint('[AURA STATE] Updating meal portion for "$mealName" on date: $targetDate');

    if (targetDate == todayStr) {
      final updatedMeals = state.nutrition.meals.map((m) {
        if (m.name.toLowerCase().contains(search)) {
          return MealItem(
            name: m.name,
            calories: calories.toInt(),
            proteinG: proteinG.toInt(),
            carbsG: carbsG.toInt(),
            fatG: fatG.toInt(),
          );
        }
        return m;
      }).toList();
      final updated = state.nutrition.copyWith(meals: updatedMeals);
      state = state.copyWith(nutrition: updated);
      if (uid != null) {
        await _firestore.saveDailyNutrition(uid, todayStr, updated);
      }
    } else {
      if (uid != null) {
        DailyNutrition existing = await _firestore.getDailyNutrition(uid, targetDate);
        final updatedMeals = existing.meals.map((m) {
          if (m.name.toLowerCase().contains(search)) {
            return MealItem(
              name: m.name,
              calories: calories.toInt(),
              proteinG: proteinG.toInt(),
              carbsG: carbsG.toInt(),
              fatG: fatG.toInt(),
            );
          }
          return m;
        }).toList();
        final updated = existing.copyWith(meals: updatedMeals);
        await _firestore.saveDailyNutrition(uid, targetDate, updated);
      }
    }
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
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveUserProfile(uid, updatedProfile);
      _repository.saveProgressEntry(entry);
    }

    // Check for weight stall — ask AI to adapt nutrition asynchronously
    if (newHistory.length >= 14) {
      final recent = newHistory.sublist(newHistory.length - 14);
      final delta = (recent.last.weightKg - recent.first.weightKg).abs();
      if (delta < 0.2 && updatedProfile.goal == GoalType.fatLoss) {
        final targetDate = state.nutrition.date;
        _aiService.generateAIAdaptedNutrition(
          state.copyWith(profile: updatedProfile, progressHistory: newHistory),
          'Weight stalled over 14 days (only ${delta.toStringAsFixed(1)}kg change). Adjust calorie target for continued fat loss.',
        ).then((adaptedNutrition) {
          if (!mounted) return;
          if (uid != null) {
            _firestore.saveDailyNutrition(uid, targetDate, adaptedNutrition);
          }
          debugPrint('[AURA STATE] AI nutrition adapted for weight stall.');
        }).catchError((e) {
          debugPrint('[AURA STATE] AI nutrition adaptation failed: $e');
        });
      }
    }
  }

  void appendUserMessage(String text) {
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: now.toIso8601String(),
      createdAt: now,
    );
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveChatMessage(uid, userMsg);
    }
  }

  Future<void> addChatMessage(String text, {Uint8List? imageBytes, String mimeType = 'image/jpeg'}) async {
    if (state.isAiThinking) {
      debugPrint('[AURA STATE] AI processing in progress, skipping concurrent message trigger');
      return;
    }

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] Cannot add chat message: User is unauthenticated');
      return;
    }

    debugPrint('[AURA STATE] User message: $text (Image attached: ${imageBytes != null})');
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: now.toIso8601String(),
      createdAt: now,
      imageBytes: imageBytes,
    );

    await _firestore.saveChatMessage(uid, userMsg);

    // Optimistically show user message in local chat immediately
    final updatedChat = List<ChatMessage>.from(state.chatMessages)..add(userMsg);
    state = state.copyWith(
      chatMessages: updatedChat,
      isAiThinking: true,
    );

    try {
      final orchestratorResult = await _aiService.processCoachMessage(
        text,
        state,
        imageBytes: imageBytes,
        mimeType: mimeType,
      );
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
            try {
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
            } catch (adaptErr) {
              debugPrint('[AURA STATE] adaptWorkoutWithAI network error, applying local fallback: $adaptErr');
              final isHome = reason.toLowerCase().contains('home') ||
                  reason.toLowerCase().contains('bodyweight') ||
                  reason.toLowerCase().contains('no gym') ||
                  reason.toLowerCase().contains("can't go");

              final fallbackExercises = <Exercise>[];
              for (var ex in state.workout.exercises) {
                final subs = ExerciseDatabase.getSubstitutions(
                  currentExerciseName: ex.name,
                  availableEquipment: isHome
                      ? [EquipmentType.bodyweight]
                      : state.profile.availableEquipment,
                );
                if (subs.isNotEmpty) {
                  fallbackExercises.add(Exercise(
                    id: 'sub_${ex.id}',
                    name: subs.first.name,
                    targetMuscle: subs.first.targetMuscle,
                    equipmentRequired: subs.first.equipment.name,
                    sets: ex.sets.map((s) => ExerciseSet(
                      setNumber: s.setNumber,
                      targetReps: s.targetReps,
                      targetWeightKg: 0.0,
                    )).toList(),
                    notes: isHome ? 'Bodyweight adaptation for home workout' : 'Adapted variation',
                  ));
                } else {
                  fallbackExercises.add(ex);
                }
              }

              final adapted = state.workout.copyWith(
                title: isHome ? "Today's Home Workout Session" : state.workout.title,
                focusArea: state.workout.focusArea,
                status: WorkoutStatus.adapted,
                exercises: fallbackExercises,
                adaptationNote: reason,
              );
              state = state.copyWith(
                workout: adapted,
                adaptationNotice: 'Workout adapted: "$reason"',
              );
              await _firestore.saveDailyWorkout(uid, state.workout.date, adapted);
            }
            break;

          case 'logNutrition':
            final mealsRaw = action.arguments['meals'];
            final List<MealItem> newMeals = [];
            if (mealsRaw is List && mealsRaw.isNotEmpty) {
              for (var m in mealsRaw) {
                newMeals.add(MealItem(
                  name: m['name']?.toString() ?? 'Logged Meal',
                  calories: (m['calories'] as num?)?.toInt() ?? 300,
                  proteinG: (m['proteinG'] as num?)?.toInt() ?? 20,
                  carbsG: (m['carbsG'] as num?)?.toInt() ?? 30,
                  fatG: (m['fatG'] as num?)?.toInt() ?? 10,
                ));
              }
            }
            final waterNum = (action.arguments['waterMl'] as num?)?.toInt();
            final targetDateRaw = action.arguments['targetDate']?.toString();
            await logNutritionForDate(newMeals: newMeals, waterMl: waterNum, rawDate: targetDateRaw);
            break;

          case 'removeMeal':
            final mealName = action.arguments['mealName']?.toString() ?? '';
            final targetDateRaw = action.arguments['targetDate']?.toString();
            if (mealName.isNotEmpty) {
              await removeMealFromDate(mealName: mealName, rawDate: targetDateRaw);
            }
            break;

          case 'updateMealPortion':
            final mealName = action.arguments['mealName']?.toString() ?? '';
            final cals = (action.arguments['calories'] as num?) ?? 300;
            final p = (action.arguments['proteinG'] as num?) ?? 20;
            final c = (action.arguments['carbsG'] as num?) ?? 30;
            final f = (action.arguments['fatG'] as num?) ?? 10;
            final targetDateRaw = action.arguments['targetDate']?.toString();
            if (mealName.isNotEmpty) {
              await updateMealPortionForDate(
                mealName: mealName,
                calories: cals,
                proteinG: p,
                carbsG: c,
                fatG: f,
                rawDate: targetDateRaw,
              );
            }
            break;

          case 'clearNutrition':
            clearTodayNutrition();
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

      final now = DateTime.now();
      final aiReply = ChatMessage(
        id: (now.millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: orchestratorResult.coachResponse,
        timestamp: now.toIso8601String(),
        createdAt: now,
      );

      final finalChat = List<ChatMessage>.from(state.chatMessages)..add(aiReply);
      state = state.copyWith(
        chatMessages: finalChat,
        isAiThinking: false,
      );
      await _firestore.saveChatMessage(uid, aiReply);
    } catch (e) {
      debugPrint('[AURA STATE] Chat processing failed: $e');
      final errNow = DateTime.now();
      final lower = text.toLowerCase().trim();
      String fallbackMsg = "I encountered a brief connection hiccup. Please send your message again.";
      if (lower == 'yes' || lower == 'ok' || lower == 'sure' || lower == 'sounds good' || lower == 'done') {
        fallbackMsg = "Understood! I'm keeping your routine calibrated. Let me know when you want to adapt workouts or log meals.";
      }
      final errReply = ChatMessage(
        id: (errNow.millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: fallbackMsg,
        timestamp: errNow.toIso8601String(),
        createdAt: errNow,
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
    
    final scanNow = DateTime.now();
    final scanReply = ChatMessage(
      id: scanNow.millisecondsSinceEpoch.toString(),
      sender: 'ai',
      text: "Got it! 340 active calories burned during your workout. I've updated your Energy bar on the home screen.",
      timestamp: scanNow.toIso8601String(),
      createdAt: scanNow,
    );
    
    final updatedWorkout = state.workout.copyWith(
      status: WorkoutStatus.completed,
    );
    
    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
      await _firestore.saveChatMessage(uid, scanReply);
    }
    
    if (!mounted) return;
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

    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyRecovery(uid, todayStr, updatedRecovery);
    }

    // If high fatigue, ask AI to adapt workout asynchronously
    if (score < 50) {
      _aiService.generateAIAdaptedWorkout(
        state,
        'High fatigue detected (Score: $score%). Deload the workout for active recovery.',
      ).then((adaptedWorkout) {
        if (!mounted) return;
        state = state.copyWith(
          workout: adaptedWorkout,
          adaptationNotice: 'High fatigue detected. AI adjusted your workout to an active recovery session.',
        );
        if (uid != null) {
          _firestore.saveDailyWorkout(uid, todayStr, adaptedWorkout);
        }
        debugPrint('[AURA STATE] AI adapted workout for high fatigue recovery.');
      }).catchError((e) {
        debugPrint('[AURA STATE] AI workout adaptation failed: $e');
      });
    }
  }

  void updateSleep(double sleepHours) {
    updateRecoveryCheckIn(
      sleepHours: sleepHours,
      sleepQuality: state.recovery.sleepQuality,
      muscleSoreness: state.recovery.muscleSoreness,
      energyLevel: state.recovery.energyLevel,
      stressLevel: state.recovery.stressLevel,
    );
  }

  void updateSoreness(int soreness) {
    updateRecoveryCheckIn(
      sleepHours: state.recovery.sleepHours,
      sleepQuality: state.recovery.sleepQuality,
      muscleSoreness: soreness,
      energyLevel: state.recovery.energyLevel,
      stressLevel: state.recovery.stressLevel,
    );
  }

  Future<QuickLogParsedResult> parseAndApplyQuickLog(String rawText) async {
    debugPrint('[AURA STATE] Parsing Express Quick-Log: "$rawText"');
    final result = await _aiService.parseQuickLog(rawText, state);
    final uid = _auth.uid;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (uid != null) {
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
      final now = DateTime.now();
      final userMsg = ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        sender: 'user',
        text: rawText,
        timestamp: now.toIso8601String(),
        createdAt: now,
      );
      final aiReply = ChatMessage(
        id: (now.millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: '⚡ Express Log Processed:\n${result.coachFeedback}',
        timestamp: now.toIso8601String(),
        createdAt: now,
      );

      await _firestore.saveChatMessage(uid, userMsg);
      await _firestore.saveChatMessage(uid, aiReply);
    }

    return result;
  }

  Future<void> adaptTodayWorkoutWithAI(String request) async {
    debugPrint('[AURA STATE] Adapting workout with AI for: "$request"');
    final adaptedWorkout = await _aiService.adaptWorkoutWithAI(request, state);
    if (!mounted) return;
    state = state.copyWith(
      workout: adaptedWorkout,
      adaptationNotice: 'Workout adapted via AURA AI: "${adaptedWorkout.adaptationNote ?? request}"',
    );
    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveDailyWorkout(uid, state.workout.date, adaptedWorkout);
    }
  }

  void updateWorkoutStatus(WorkoutStatus status) {
    debugPrint('[AURA STATE] Updating workout status: ${status.name}');
    final updatedWorkout = state.workout.copyWith(status: status);
    state = state.copyWith(workout: updatedWorkout);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, state.workout.date, updatedWorkout);
    }
  }

  void updateProfile(UserProfile updatedProfile) {
    debugPrint('[AURA STATE] Profile updated directly');
    state = state.copyWith(profile: updatedProfile);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveUserProfile(uid, updatedProfile);
    }
  }

  void updateCoachSoul(CoachSoul soul) {
    debugPrint('[AURA STATE] Switching coach soul to ${soul.name}');
    final updated = state.profile.copyWith(coachSoul: soul);
    updateProfile(updated);
  }

  Future<void> updateGoal({
    required GoalType goal,
    required String targetPhysique,
    required double targetWeightKg,
    int? daysPerWeek,
  }) async {
    debugPrint('[AURA STATE] Recalibrating transformation goal to ${goal.name} (target: $targetWeightKg kg, $daysPerWeek days/week)');
    final updatedProfile = state.profile.copyWith(
      goal: goal,
      targetPhysique: targetPhysique,
      targetWeightKg: targetWeightKg,
      daysPerWeek: daysPerWeek ?? state.profile.daysPerWeek,
    );

    // Calculate new target calories and macros based on goal and weight
    final double weight = updatedProfile.weightKg > 0 ? updatedProfile.weightKg : 70.0;
    final int newCalories;
    final int newProtein;
    final int newCarbs;
    final int newFats;

    switch (goal) {
      case GoalType.fatLoss:
        newCalories = (weight * 26).round(); // Caloric deficit (~1800-2000 kcal for 70-75kg)
        newProtein = (weight * 2.1).round(); // High protein retention (~150-160g)
        newFats = (weight * 0.7).round();    // Essential fats (~50-55g)
        newCarbs = ((newCalories - (newProtein * 4) - (newFats * 9)) / 4).round().clamp(50, 400);
        break;
      case GoalType.muscleGain:
        newCalories = (weight * 34).round(); // Caloric surplus (~2400-2600 kcal)
        newProtein = (weight * 2.0).round(); // ~140-150g
        newFats = (weight * 0.9).round();    // ~60-70g
        newCarbs = ((newCalories - (newProtein * 4) - (newFats * 9)) / 4).round().clamp(100, 500);
        break;
      case GoalType.recomp:
        newCalories = (weight * 30).round(); // Maintenance (~2100-2300 kcal)
        newProtein = (weight * 2.0).round(); // ~140-150g
        newFats = (weight * 0.8).round();    // ~55-60g
        newCarbs = ((newCalories - (newProtein * 4) - (newFats * 9)) / 4).round().clamp(80, 450);
        break;
    }

    final updatedNutrition = state.nutrition.copyWith(
      targetCalories: newCalories,
      targetProteinG: newProtein,
      targetCarbsG: newCarbs,
      targetFatG: newFats,
    );

    state = state.copyWith(
      profile: updatedProfile,
      nutrition: updatedNutrition,
      adaptationNotice: 'Goal updated to ${goal.displayName}. Daily fuel calibrated to $newCalories kcal ($newProtein g protein).',
    );

    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveUserProfile(uid, updatedProfile);
      await _firestore.saveDailyNutrition(uid, state.nutrition.date, updatedNutrition);
    }
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
