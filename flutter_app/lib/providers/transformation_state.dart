import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/transformation_repository.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import 'analytics_provider.dart';
import 'mutations/workout_mutations.dart';
import 'mutations/nutrition_mutations.dart';
import 'mutations/recovery_mutations.dart';

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
  final List<PendingAction> pendingActions;
  final Map<String, List<CommandPreview>> messagePreviews;
  final List<CommandPreview> latestPreviews;

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
    this.pendingActions = const [],
    this.messagePreviews = const {},
    this.latestPreviews = const [],
  })  : masterContext = masterContext ?? const MasterContext(),
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
    List<PendingAction>? pendingActions,
    Map<String, List<CommandPreview>>? messagePreviews,
    List<CommandPreview>? latestPreviews,
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
      pendingActions: pendingActions ?? this.pendingActions,
      messagePreviews: messagePreviews ?? this.messagePreviews,
      latestPreviews: latestPreviews ?? this.latestPreviews,
    );
  }

  TodayFocus get todayFocus {
    final isWorkoutDone = workout.status == WorkoutStatus.completed;
    final totalProt = nutrition.meals.fold<num>(0, (acc, m) => acc + m.proteinG);
    final remainingProt = (nutrition.targetProteinG - totalProt).clamp(0, 999);

    if (recovery.recoveryScore < 50) {
      return const TodayFocus(
        primaryActionTitle: 'Focus on Systemic Recovery & Deload',
        primaryActionDescription: 'Readiness is low. Execute today\'s scaled Deload session or take an active recovery walk.',
        category: 'RECOVER',
        isDeloadAdvised: true,
      );
    }

    if (!isWorkoutDone) {
      return TodayFocus(
        primaryActionTitle: 'Execute ${workout.title}',
        primaryActionDescription: 'Complete your ${workout.estimatedDurationMin}-minute session targeting ${workout.focusArea}. Aim for ${nutrition.targetProteinG}g protein.',
        category: 'TRAIN',
      );
    }

    if (remainingProt > 20) {
      return TodayFocus(
        primaryActionTitle: 'Hit Remaining ${remainingProt}g Protein Target',
        primaryActionDescription: 'Workout completed! Fuel muscle recovery by hitting your remaining protein target before sleep.',
        category: 'EAT',
      );
    }

    return const TodayFocus(
      primaryActionTitle: 'Targets Complete! Optimize Nighttime Recovery',
      primaryActionDescription: 'Workout & nutrition targets hit for today. Hydrate with 500ml water and aim for 8 hours of sleep.',
      category: 'RECOVER',
    );
  }


  /// Evaluates if progress is accounted for (logged or marked skipped) for a given date
  bool isProgressTrackedForDate(String dateStr) {
    final hasProgressEntry = progressHistory.any((p) {
      if (p.date != dateStr) return false;
      if (p.workoutStatus == WorkoutStatus.completed || p.workoutStatus == WorkoutStatus.skipped) {
        return true;
      }
      final notes = (p.notes ?? '').toLowerCase();
      return notes.contains('skipped') || notes.contains('workout') || notes.contains('session');
    });
    final recent = recentWorkouts[dateStr];
    final hasRecentCompletedOrSkipped = recent != null &&
        (recent.status == WorkoutStatus.completed ||
            recent.status == WorkoutStatus.skipped ||
            recent.exercises.any((ex) => ex.sets.any((s) => s.completed)));
    final hasWorkoutActivity = workout.date == dateStr &&
        (workout.status == WorkoutStatus.completed ||
            workout.status == WorkoutStatus.skipped ||
            workout.exercises.any((ex) => ex.sets.any((s) => s.completed)));
    return hasProgressEntry || hasRecentCompletedOrSkipped || hasWorkoutActivity;
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

  /// Calculates effective workout status (if progress is untracked for past days, treat as skipped/did not work out)
  WorkoutStatus get effectiveTodayWorkoutStatus {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    // Today's workout is actively scheduled or in-progress, never falsely evaluate to skipped
    if (workout.date == todayStr) {
      return workout.status;
    }
    final isTracked = isProgressTrackedForDate(workout.date);
    if (!isTracked && workout.status != WorkoutStatus.completed) {
      return WorkoutStatus.skipped;
    }
    return workout.status;
  }

  String get effectiveCreationDateStr {
    if (profile.createdAtDateStr != null && profile.createdAtDateStr!.isNotEmpty) {
      return profile.createdAtDateStr!;
    }
    if (progressHistory.isNotEmpty) {
      final dates = progressHistory.map((p) => p.date).where((d) => d.isNotEmpty).toList()..sort();
      if (dates.isNotEmpty) {
        return dates.first;
      }
    }
    if (recentWorkouts.isNotEmpty) {
      final dates = recentWorkouts.keys.where((d) => d.isNotEmpty).toList()..sort();
      if (dates.isNotEmpty) {
        return dates.first;
      }
    }
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Unlogged past days in the current week (from Monday up to yesterday)
  List<Map<String, String>> get unloggedPreviousDays {
    final List<Map<String, String>> unlogged = [];
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysPassed = now.weekday - 1; // Number of days before today in this week

    final creationDateStr = effectiveCreationDateStr;

    for (int i = 0; i < daysPassed; i++) {
      final d = monday.add(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];

      // IGNORE past days that occurred BEFORE the user created their account!
      if (dateStr.compareTo(creationDateStr) < 0) {
        continue;
      }

      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

      // Exclude days designated as rest days in the weekly plan
      final planDay = (weeklyPlan != null && i < weeklyPlan!.days.length)
          ? weeklyPlan!.days[i]
          : null;
      if (planDay != null && planDay.isRestDay) {
        continue;
      }

      final isCompleted = isWorkoutCompletedForDate(dateStr);
      final isSkipped = isWorkoutSkippedForDate(dateStr);
      if (!isCompleted && !isSkipped) {
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

class TransformationEngineNotifier extends StateNotifier<TransformationEngineState>
    with WorkoutMutations, NutritionMutations, RecoveryMutations {
  final ITransformationRepository _repository;
  final FirebaseFirestoreService _firestore;
  final FirebaseAuthService _auth;
  final AIService _aiService;
  final IAnalyticsService _analytics;
  AIService get aiService => _aiService;

  StreamSubscription<DocumentSnapshot>? _workoutSubscription;
  StreamSubscription<DocumentSnapshot>? _nutritionSubscription;
  StreamSubscription<DocumentSnapshot>? _recoverySubscription;
  StreamSubscription<QuerySnapshot>? _chatMessagesSubscription;
  StreamSubscription<List<PendingAction>>? _pendingActionsSubscription;
  StreamSubscription<DocumentSnapshot>? _weeklyPlanSubscription;
  StreamSubscription<User?>? _authSubscription;

  TransformationEngineNotifier({
    ITransformationRepository? repository,
    FirebaseFirestoreService? firestore,
    FirebaseAuthService? auth,
    AIService? aiService,
    IAnalyticsService? analytics,
    bool autoInit = true,
  })  : _repository = repository ?? LocalTransformationRepository(),
        _firestore = firestore ?? FirebaseFirestoreService(),
        _auth = auth ?? FirebaseAuthService(),
        _aiService = aiService ?? GeminiAIProvider(),
        _analytics = analytics ?? MixpanelAnalyticsService(),
        super(_initialState()) {
    if (autoInit) {
      initFromRepository();
      _authSubscription = _auth.authStateChanges.listen((user) {
        if (user != null) {
          initFromRepository();
        }
      });
    }
  }

  @override
  void saveWorkoutToRemote(DailyWorkout workout) {
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, state.workout.date, workout);
    }
  }

  @override
  void updateWorkoutFieldsToRemote(Map<String, dynamic> fields) {
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.updateDailyWorkoutField(uid, state.workout.date, fields);
    }
  }

  @override
  Future<void> saveNutritionToRemote(String date, DailyNutrition nutrition) async {
    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveDailyNutrition(uid, date, nutrition);
    }
  }

  @override
  Future<DailyNutrition> getRemoteNutrition(String date) async {
    final uid = _auth.uid;
    if (uid != null) {
      return await _firestore.getDailyNutrition(uid, date);
    }
    return state.nutrition;
  }

  @override
  void saveRecoveryToRemote(String date, RecoveryCheckIn recovery) {
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyRecovery(uid, date, recovery);
    }
  }

  @override
  void handleFatigueDeload(int score) {
    _aiService.generateAIAdaptedWorkout(
      state,
      'High fatigue detected (Score: $score%). Deload the workout for active recovery.',
    ).then((_) {
      if (!mounted) return;
      state = state.copyWith(
        adaptationNotice: 'High fatigue detected. AI adjusted your workout to an active recovery session.',
      );
      debugPrint('[AURA STATE] AI adapted workout requested for high fatigue recovery. UI will sync via Firestore stream.');
    }).catchError((e) {
      debugPrint('[AURA STATE] AI workout adaptation failed: $e');
    });
  }


  bool _isInitializingFromRepo = false;

  Future<void> initFromRepository() async {
    if (_isInitializingFromRepo) return;
    _isInitializingFromRepo = true;

    debugPrint('[AURA STATE] Initializing state from online Firestore...');

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] No authenticated Firebase user. Setting isOnboardingComplete = false');
      state = state.copyWith(isOnboardingComplete: false, isInitializing: false);
      _isInitializingFromRepo = false;
      return;
    }

    try {
      // Parallel fetch: profile, weekly plan, master context, progress history, recent workouts
      final profileFuture = _firestore.getUserProfile(uid);
      final weeklyPlanFuture = _firestore.getWeeklyPlan(uid);
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

      if (weeklyPlan != null) {
        _syncTodayWorkoutWithWeeklyPlan(weeklyPlan);
      }

      // Setup real-time subscriptions for logs and chats
      setupSubscriptions(uid);
    } catch (e) {
      debugPrint('[AURA STATE] initFromRepository error: $e');
      state = state.copyWith(isInitializing: false);
    } finally {
      _isInitializingFromRepo = false;
    }
  }

  /// Pull-to-refresh hook to fetch the latest state from Firestore across all systems
  Future<void> refreshState() async {
    debugPrint('[AURA STATE] Pull-to-refresh: fetching latest state from remote repository...');
    await initFromRepository();
  }

  void _syncTodayWorkoutWithWeeklyPlan(WeeklyPlan plan) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final currentWorkout = state.workout;
    final isUnstarted = currentWorkout.id.startsWith('baseline_') ||
        (currentWorkout.status == WorkoutStatus.scheduled &&
            currentWorkout.exercises.every((e) => e.sets.every((s) => !s.completed)));

    if (isUnstarted) {
      final uid = _auth.uid;
      if (uid != null) {
        _autoDeriveTodayWorkoutIfMissing(uid, todayStr, explicitPlan: plan);
      }
    }
  }

  Future<void> _autoDeriveTodayWorkoutIfMissing(String uid, String todayStr, {WeeklyPlan? explicitPlan}) async {
    DailyWorkout? derivedWorkout;
    final activePlan = explicitPlan ?? state.weeklyPlan;
    if (activePlan != null) {
      final now = DateTime.now();
      final dayIndex = now.weekday - 1; // 0 for Monday, 6 for Sunday
      if (dayIndex >= 0 && dayIndex < activePlan.days.length) {
        final dayPlan = activePlan.days[dayIndex];
        if (dayPlan.isRestDay && dayPlan.exerciseNames.isEmpty) {
          derivedWorkout = DailyWorkout(
            id: 'plan_rest_$todayStr',
            date: todayStr,
            title: dayPlan.title.isNotEmpty ? dayPlan.title : 'Active Recovery & Rest',
            focusArea: dayPlan.focusArea.isNotEmpty ? dayPlan.focusArea : 'Mobility & Recovery',
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
              targetMuscle: dayPlan.focusArea.isNotEmpty ? dayPlan.focusArea : 'Mobility & Core',
              equipmentRequired: 'bodyweight',
              sets: [
                const ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0.0),
                const ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 0.0),
                const ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0.0),
              ],
            );
          }).toList();

          derivedWorkout = DailyWorkout(
            id: 'plan_$todayStr',
            date: todayStr,
            title: dayPlan.title.isNotEmpty ? dayPlan.title : (dayPlan.isRestDay ? 'Active Recovery & Mobility' : 'Prescribed Workout'),
            focusArea: dayPlan.focusArea.isNotEmpty ? dayPlan.focusArea : 'Full Body',
            estimatedDurationMin: dayPlan.isRestDay ? 25 : 45,
            status: WorkoutStatus.scheduled,
            exercises: exercises,
            adaptationNote: dayPlan.nutritionFocus ?? (dayPlan.isRestDay ? 'Scheduled active recovery session from weekly plan.' : null),
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
        const Exercise(
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
        const Exercise(
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

    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
      ..[todayStr] = derivedWorkout;
    state = state.copyWith(
      workout: derivedWorkout,
      recentWorkouts: updatedRecent,
    );
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
    _pendingActionsSubscription?.cancel();
    _weeklyPlanSubscription?.cancel();

    // 1. Subscribe to Today's Workout (separate collection)
    _workoutSubscription = _firestore.getWorkoutStream(uid, todayStr).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final remoteWorkout = _firestore.workoutFromMap(data);

        // Guard against stale stream snapshot overwrite if local state has newer completed sets or status
        final localCompletedCount = state.workout.exercises.fold<int>(
          0, (sum, ex) => sum + ex.sets.where((s) => s.completed).length,
        );
        final remoteCompletedCount = remoteWorkout.exercises.fold<int>(
          0, (sum, ex) => sum + ex.sets.where((s) => s.completed).length,
        );

        if (remoteWorkout.date == state.workout.date &&
            localCompletedCount > remoteCompletedCount &&
            remoteWorkout.status != WorkoutStatus.completed &&
            state.workout.status != WorkoutStatus.completed) {
          debugPrint('[AURA STATE] Ignored stale remote workout stream snapshot (local: $localCompletedCount vs remote: $remoteCompletedCount)');
          return;
        }

        final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
          ..[remoteWorkout.date] = remoteWorkout;
        state = state.copyWith(
          workout: remoteWorkout,
          recentWorkouts: updatedRecent,
        );
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
        
        final String? imgUrl = data['imageUrl'] as String?;

        messages.add(ChatMessage(
          id: data['id'] ?? doc.id,
          sender: data['sender'] ?? 'ai',
          text: data['text'] ?? '',
          timestamp: msgTime.toIso8601String(),
          createdAt: msgTime,
          imageBytes: imgBytes,
          imageUrl: imgUrl,
        ));
      }
      if (messages.isNotEmpty) {
        state = state.copyWith(chatMessages: messages);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Chat Messages subscription error: $err');
    });

    // 5. Subscribe to Pending Actions
    _pendingActionsSubscription = _firestore.getPendingActionsStream(uid).listen((pendingList) {
      state = state.copyWith(pendingActions: pendingList);
    }, onError: (err) {
      debugPrint('[AURA STATE] Pending actions subscription error: $err');
    });

    // 6. Subscribe to Current Weekly Plan Document
    _weeklyPlanSubscription = _firestore.getCurrentWeeklyPlanStream(uid).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final remotePlan = _firestore.weeklyPlanFromMap(data);
        state = state.copyWith(weeklyPlan: remotePlan);
        _repository.saveWeeklyPlan(remotePlan);
        _syncTodayWorkoutWithWeeklyPlan(remotePlan);
      }
    }, onError: (err) {
      debugPrint('[AURA STATE] Weekly Plan subscription error: $err');
    });

  }

  FirebaseAuthService get authService => _auth;
  String? get currentAuthEmail => _auth.email;
  String? get currentAuthDisplayName => _auth.displayName;
  bool get isAuthenticated => _auth.isAuthenticated;
  bool get isAnonymous => _auth.isAnonymous;
  bool get isPermanentUser => _auth.isPermanentUser;

  Future<UserCredential?> linkAnonymousWithGoogle() async {
    debugPrint('[AURA STATE] Linking anonymous user with Google...');
    try {
      final cred = await _auth.linkAnonymousWithGoogle();
      final user = cred?.user;
      if (user != null) {
        final uid = user.uid;
        debugPrint('[AURA STATE] Account linked successfully for UID $uid (${user.email})');

        // Preserve and update profile in state and Firestore without wiping workouts or plans
        final currentName = state.profile.name;
        final newName = (user.displayName != null && user.displayName!.trim().isNotEmpty && (currentName.isEmpty || currentName == 'Guest Athlete'))
            ? user.displayName!.trim()
            : currentName;
        final updatedProfile = state.profile.copyWith(name: newName);
        state = state.copyWith(profile: updatedProfile);

        await _firestore.saveUserProfile(uid, updatedProfile);
        setupSubscriptions(uid);
      }
      return cred;
    } catch (e) {
      debugPrint('[AURA STATE] Account link error: $e');
      rethrow;
    }
  }

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
    _pendingActionsSubscription?.cancel();
    await _auth.signOut();
    state = state.copyWith(
      isOnboardingComplete: false,
    );
  }

  Future<void> deleteAccount() async {
    debugPrint('[AURA STATE] Deleting user account and archiving data...');

    final uid = _auth.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await _firestore.archiveAndDeleteUserData(uid);
      } catch (e) {
        debugPrint('[AURA STATE] Error archiving Firestore user data: $e');
      }
    }

    try {
      await _auth.deleteAccount();
    } catch (e) {
      debugPrint('[AURA STATE] Error deleting Firebase Auth user: $e');
      rethrow; // Abort here, don't clear local state!
    }

    // Only clean up state if auth deletion succeeds
    _workoutSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _recoverySubscription?.cancel();
    _chatMessagesSubscription?.cancel();
    _pendingActionsSubscription?.cancel();

    try {
      await _repository.clearAll();
    } catch (e) {
      debugPrint('[AURA STATE] Error clearing local repository: $e');
    }

    state = _initialState().copyWith(
      isOnboardingComplete: false,
      isInitializing: false,
    );
  }

  static TransformationEngineState _initialState() {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    const profile = UserProfile(
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
        EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
        EquipmentItem(name: 'Barbell', category: 'free_weight'),
        EquipmentItem(name: 'Cables', category: 'cables'),
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
        const ProgressEntry(date: '2026-08-08', weightKg: 79.2, bodyFatPercent: 18.2),
        const ProgressEntry(date: '2026-08-09', weightKg: 78.9, bodyFatPercent: 18.0),
        const ProgressEntry(date: '2026-08-10', weightKg: 78.6, bodyFatPercent: 17.9),
      ],
      chatMessages: [],
      isOnboardingComplete: true,
      adaptationNotice: "Welcome to AURA! Tap 'Sleep' or 'Aches' below to log your state, or message me in the Coach tab to begin.",
    );
  }

  Future<void> completeOnboarding(UserProfile newProfile) async {
    debugPrint('[AURA STATE] Completing onboarding for ${newProfile.name}...');
    try {
      await _aiService.generateAIMetabolicPlan(newProfile);
    } catch (e) {
      debugPrint('[AURA STATE] generateAIMetabolicPlan error during onboarding: $e');
    }
    try {
      await _aiService.generateAIInitialWorkout(newProfile);
    } catch (e) {
      debugPrint('[AURA STATE] generateAIInitialWorkout error during onboarding: $e');
    }
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final initProgress = ProgressEntry(date: todayStr, weightKg: newProfile.weightKg, notes: 'Initial baseline setup');

    state = state.copyWith(
      profile: newProfile,
      progressHistory: [initProgress],
      chatMessages: [
        ChatMessage(
          id: 'welcome_1',
          sender: 'ai',
          text: "Welcome to AURA, ${newProfile.name}! I've generated your baseline plan. Ready to get started?",
          timestamp: 'Just now',
          createdAt: DateTime.now(),
        )
      ],
      isOnboardingComplete: true,
      adaptationNotice: "Welcome to AURA, ${newProfile.name}! Tap 'Sleep' or 'Aches' below to log your state, or message me in the Coach tab to begin.",
    );

    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveUserProfile(uid, newProfile);
      await _firestore.saveProgress(uid, initProgress.date, initProgress);
      setupSubscriptions(uid);
    }
  }


  Future<void> completeOnboardingWithPlan(UserProfile newProfile, DailyNutrition nutrition, DailyWorkout workout) async {
    debugPrint('[AURA STATE] Completing onboarding with synthesized plan for ${newProfile.name}...');
    debugPrint('[AURA STATE] Baseline setup: Target Calories ${nutrition.targetCalories} kcal, Target Protein ${nutrition.targetProteinG}g');
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final initProgress = ProgressEntry(date: todayStr, weightKg: newProfile.weightKg, notes: 'Initial baseline setup');

    state = state.copyWith(
      profile: newProfile,
      progressHistory: [initProgress],
      chatMessages: [
        ChatMessage(
          id: 'welcome_1',
          sender: 'ai',
          text: "Welcome to AURA, ${newProfile.name}! I've generated your baseline plan. Ready to get started?",
          timestamp: 'Just now',
          createdAt: DateTime.now(),
        )
      ],
      isOnboardingComplete: true,
      adaptationNotice: "Welcome to AURA, ${newProfile.name}! Tap 'Sleep' or 'Aches' below to log your state, or message me in the Coach tab to begin.",
    );

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] Error: Cannot complete onboarding without an authenticated UID');
      return;
    }
    await _firestore.saveUserProfile(uid, newProfile);
    await _repository.saveProgressEntry(initProgress);
    
    setupSubscriptions(uid);

    // Load master context
    _loadMasterContext(uid);

    // Generate weekly plan in the background so it's ready
    generateWeeklyPlan();

    debugPrint('[AURA STATE] Onboarding completed! AI plans saved remotely.');
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

  @override
  void completeWorkout({String? dateStr, String? notes}) {
    final targetDate = dateStr ?? state.workout.date;
    debugPrint('[AURA STATE] Completing workout for $targetDate');

    final updatedExercises = state.workout.exercises.map((ex) {
      final updatedSets = ex.sets.map((s) => s.copyWith(completed: true)).toList();
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final completedWorkout = state.workout.copyWith(
      exercises: updatedExercises,
      status: WorkoutStatus.completed,
    );

    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
      ..[targetDate] = completedWorkout;

    final progressEntry = ProgressEntry(
      date: targetDate,
      weightKg: state.profile.weightKg,
      notes: notes ?? 'Completed: ${completedWorkout.title}',
      workoutStatus: WorkoutStatus.completed,
    );
    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == targetDate)
      ..add(progressEntry);

    state = state.copyWith(
      workout: targetDate == state.workout.date ? completedWorkout : state.workout,
      recentWorkouts: updatedRecent,
      progressHistory: newHistory,
    );

    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveDailyWorkout(uid, targetDate, completedWorkout);
      _firestore.saveProgress(uid, targetDate, progressEntry);
    }
    _repository.saveProgressEntry(progressEntry);

    // Mixpanel event: prescription_completed (Core Value Moment)
    final totalSets = completedWorkout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    _analytics.logEvent(
      AuraAnalyticsEvents.prescriptionCompleted,
      properties: {
        'workout_type': completedWorkout.title,
        'focus_area': completedWorkout.focusArea,
        'estimated_duration_min': completedWorkout.estimatedDurationMin,
        'exercise_count': completedWorkout.exercises.length,
        'total_sets': totalSets,
        'is_adapted': completedWorkout.adaptationNote != null && completedWorkout.adaptationNote!.isNotEmpty,
        'coach_soul': state.profile.coachSoul.name,
      },
    );
  }

  void trackProgressForToday() {
    debugPrint('[AURA STATE] Marking daily progress tracked for today');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final todayEntry = ProgressEntry(
      date: todayStr,
      weightKg: state.profile.weightKg,
      notes: 'Quick daily check-in',
      workoutStatus: state.workout.status,
    );

    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == todayStr)
      ..add(todayEntry);
    state = state.copyWith(progressHistory: newHistory);

    final uid = _auth.uid;
    if (uid != null) {
      _firestore.saveProgress(uid, todayStr, todayEntry);
    }
    _repository.saveProgressEntry(todayEntry);
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

  Future<void> markPastWorkoutCompleted(String dateStr, {WeeklyDayPlan? planDay, String? notes}) async {
    debugPrint('[AURA STATE] Marking past workout for $dateStr as completed');
    final isToday = dateStr == DateTime.now().toIso8601String().split('T')[0];

    DailyWorkout? existing = state.recentWorkouts[dateStr];
    if (existing == null && isToday && state.workout.exercises.isNotEmpty) {
      existing = state.workout;
    }

    DailyWorkout completedWorkout;
    if (existing != null && existing.exercises.isNotEmpty) {
      final updatedExercises = existing.exercises.map((ex) {
        final updatedSets = ex.sets.map((s) => s.copyWith(completed: true)).toList();
        return ex.copyWith(sets: updatedSets);
      }).toList();
      completedWorkout = existing.copyWith(
        exercises: updatedExercises,
        status: WorkoutStatus.completed,
      );
    } else {
      WeeklyDayPlan? plan = planDay;
      if (plan == null && state.weeklyPlan != null) {
        try {
          plan = state.weeklyPlan!.days.firstWhere((d) => d.date == dateStr);
        } catch (_) {
          plan = null;
        }
      }

      final exerciseNames = (plan != null && plan.exerciseNames.isNotEmpty)
          ? plan.exerciseNames
          : const ['Push-Ups', 'Bodyweight Squats', 'Plank'];

      final exercises = exerciseNames.map((exName) {
        final exId = exName.toLowerCase().replaceAll(' ', '_');
        return Exercise(
          id: exId,
          name: exName,
          targetMuscle: plan?.focusArea ?? 'Full Body',
          equipmentRequired: 'Bodyweight',
          sets: const [
            ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0, completed: true),
            ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 0, completed: true),
            ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0, completed: true),
          ],
        );
      }).toList();

      completedWorkout = DailyWorkout(
        id: 'workout_$dateStr',
        date: dateStr,
        title: plan?.title ?? 'Prescribed Workout',
        focusArea: plan?.focusArea ?? 'Full Body',
        estimatedDurationMin: 40,
        status: WorkoutStatus.completed,
        exercises: exercises,
      );
    }

    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts)
      ..[dateStr] = completedWorkout;

    final entry = ProgressEntry(
      date: dateStr,
      weightKg: state.profile.weightKg,
      notes: notes ?? 'Completed: ${completedWorkout.title}',
      workoutStatus: WorkoutStatus.completed,
    );
    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == dateStr)
      ..add(entry);

    state = state.copyWith(
      workout: isToday ? completedWorkout : state.workout,
      recentWorkouts: updatedRecent,
      progressHistory: newHistory,
    );

    final uid = _auth.uid;
    if (uid != null) {
      await _firestore.saveDailyWorkout(uid, dateStr, completedWorkout);
      await _firestore.saveProgress(uid, dateStr, entry);
    }
    _repository.saveProgressEntry(entry);

    final totalSets = completedWorkout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    _analytics.logEvent(
      AuraAnalyticsEvents.prescriptionCompleted,
      properties: {
        'workout_type': completedWorkout.title,
        'focus_area': completedWorkout.focusArea,
        'estimated_duration_min': completedWorkout.estimatedDurationMin,
        'exercise_count': completedWorkout.exercises.length,
        'total_sets': totalSets,
        'is_adapted': completedWorkout.adaptationNote != null && completedWorkout.adaptationNote!.isNotEmpty,
        'is_backfill': !isToday,
        'coach_soul': state.profile.coachSoul.name,
      },
    );
  }

  Future<void> undoPastWorkoutStatus(String dateStr) async {
    debugPrint('[AURA STATE] Undoing past workout status for $dateStr');
    final isToday = dateStr == DateTime.now().toIso8601String().split('T')[0];

    final updatedRecent = Map<String, DailyWorkout>.from(state.recentWorkouts);
    if (updatedRecent.containsKey(dateStr)) {
      final w = updatedRecent[dateStr]!;
      final resetExercises = w.exercises.map((ex) {
        final resetSets = ex.sets.map((s) => s.copyWith(completed: false)).toList();
        return ex.copyWith(sets: resetSets);
      }).toList();
      updatedRecent[dateStr] = w.copyWith(
        status: WorkoutStatus.scheduled,
        exercises: resetExercises,
      );
    }

    final newHistory = List<ProgressEntry>.from(state.progressHistory)
      ..removeWhere((p) => p.date == dateStr);

    state = state.copyWith(
      workout: isToday ? (state.workout.copyWith(status: WorkoutStatus.scheduled)) : state.workout,
      recentWorkouts: updatedRecent,
      progressHistory: newHistory,
    );

    final uid = _auth.uid;
    if (uid != null) {
      if (updatedRecent.containsKey(dateStr)) {
        await _firestore.saveDailyWorkout(uid, dateStr, updatedRecent[dateStr]!);
      }
      await _firestore.deleteProgress(uid, dateStr);
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

  @override
  void addWater(int amountMl) {
    final newWater = state.nutrition.waterMl + amountMl;
    debugPrint('[AURA STATE] Added +${amountMl}ml water (Total: ${newWater}ml)');
    final updatedNutrition = state.nutrition.copyWith(waterMl: newWater);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.updateDailyNutritionField(uid, state.nutrition.date, {'waterMl': newWater});
    }
  }

  @override
  void addMeal(MealItem meal) {
    debugPrint('[AURA STATE] Added meal: ${meal.name} (${meal.calories} kcal, ${meal.proteinG}g P)');
    final newMeals = List<MealItem>.from(state.nutrition.meals)..add(meal);
    final updatedNutrition = state.nutrition.copyWith(meals: newMeals);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.updateDailyNutritionField(uid, state.nutrition.date, {'meals': newMeals.map((m) => m.toJson()).toList()});
    }
  }

  @override
  void clearTodayNutrition() {
    debugPrint('[AURA STATE] Clearing today\'s logged nutrition entries...');
    final updatedNutrition = state.nutrition.copyWith(meals: []);
    state = state.copyWith(nutrition: updatedNutrition);
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.updateDailyNutritionField(uid, state.nutrition.date, {'meals': []});
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

  @override
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
        final updateMap = <String, dynamic>{
          'meals': updated.meals.map((m) => m.toJson()).toList(),
        };
        if (waterMl != null && waterMl > 0) {
          updateMap['waterMl'] = updated.waterMl;
        }
        await _firestore.updateDailyNutritionField(uid, todayStr, updateMap);
      }
    } else {
      if (uid != null) {
        DailyNutrition existing = await _firestore.getDailyNutrition(uid, targetDate);
        final combined = List<MealItem>.from(existing.meals)..addAll(newMeals);
        var updated = existing.copyWith(date: targetDate, meals: combined);
        if (waterMl != null && waterMl > 0) {
          updated = updated.copyWith(waterMl: updated.waterMl + waterMl);
        }
        
        final updateMap = <String, dynamic>{
          'meals': updated.meals.map((m) => m.toJson()).toList(),
        };
        if (waterMl != null && waterMl > 0) {
          updateMap['waterMl'] = updated.waterMl;
        }
        await _firestore.updateDailyNutritionField(uid, targetDate, updateMap);
      }
    }
  }

  @override
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
        await _firestore.updateDailyNutritionField(uid, todayStr, {
          'meals': updated.meals.map((m) => m.toJson()).toList(),
        });
      }
    } else {
      if (uid != null) {
        DailyNutrition existing = await _firestore.getDailyNutrition(uid, targetDate);
        final updatedMeals = existing.meals.where((m) => !m.name.toLowerCase().contains(search)).toList();
        await _firestore.updateDailyNutritionField(uid, targetDate, {
          'meals': updatedMeals.map((m) => m.toJson()).toList(),
        });
      }
    }
  }

  @override
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
        await _firestore.updateDailyNutritionField(uid, todayStr, {
          'meals': updated.meals.map((m) => m.toJson()).toList(),
        });
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
        await _firestore.updateDailyNutritionField(uid, targetDate, {
          'meals': updatedMeals.map((m) => m.toJson()).toList(),
        });
      }
    }
  }

  Future<MealItem> logMealWithAI(String mealDescription) async {
    debugPrint('[AURA STATE] Estimating meal with AI: "$mealDescription"');
    final meal = await _aiService.estimateAIMealNutrition(mealDescription);
    debugPrint('[AURA STATE] AI estimated meal: ${meal.name} -> Will sync via Firestore stream');
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
        _aiService.generateAIAdaptedNutrition(
          state.copyWith(profile: updatedProfile, progressHistory: newHistory),
          'Weight stalled over 14 days (only ${delta.toStringAsFixed(1)}kg change). Adjust calorie target for continued fat loss.',
        ).then((_) {
          if (!mounted) return;
          debugPrint('[AURA STATE] AI nutrition adapted for weight stall. Will sync via stream.');
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

  Future<void> addChatMessage(
    String text, {
    Uint8List? imageBytes,
    String? imageUrl,
    String mimeType = 'image/jpeg',
    ContextEnvelope? contextEnvelope,
  }) async {
    if (state.isAiThinking) {
      debugPrint('[AURA STATE] AI processing in progress, skipping concurrent message trigger');
      return;
    }

    final uid = _auth.uid;
    if (uid == null) {
      debugPrint('[AURA STATE] Cannot add chat message: User is unauthenticated');
      return;
    }

    debugPrint('[AURA STATE] User message: $text (Image attached: ${imageBytes != null || imageUrl != null})');
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: now.toIso8601String(),
      createdAt: now,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
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
        imageUrl: imageUrl,
        mimeType: mimeType,
        contextEnvelope: contextEnvelope,
      );
      debugPrint('[AURA STATE] Orchestrator determined ${orchestratorResult.actions.length} action(s): ${orchestratorResult.actions.map((a) => a.functionName).toList()}');

      debugPrint('[AURA STATE] Orchestrator executed ${orchestratorResult.actions.length} action(s) on backend. Pending actions: ${orchestratorResult.pendingActions.length}');

      if (orchestratorResult.pendingActions.isNotEmpty) {
        final mergedPending = List<PendingAction>.from(state.pendingActions);
        for (var pa in orchestratorResult.pendingActions) {
          if (!mergedPending.any((p) => p.id == pa.id)) {
            mergedPending.add(pa);
          }
        }
        state = state.copyWith(pendingActions: mergedPending);
      }

      final now = DateTime.now();
      final aiReply = ChatMessage(
        id: (now.millisecondsSinceEpoch + 1).toString(),
        sender: 'ai',
        text: orchestratorResult.coachResponse,
        timestamp: now.toIso8601String(),
        createdAt: now,
      );

      final List<CommandPreview> previews = [];
      if (orchestratorResult is UnifiedAIOrchestratorResult) {
        previews.addAll(orchestratorResult.previews);
      }

      final updatedPreviews = Map<String, List<CommandPreview>>.from(state.messagePreviews);
      if (previews.isNotEmpty) {
        updatedPreviews[aiReply.id] = previews;
      }

      final finalChat = List<ChatMessage>.from(state.chatMessages)..add(aiReply);
      state = state.copyWith(
        chatMessages: finalChat,
        isAiThinking: false,
        messagePreviews: updatedPreviews,
        latestPreviews: previews,
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
          status: result.workoutStatus!,
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

  Future<void> adaptTodayWorkoutWithAI(String request, {ContextEnvelope? contextEnvelope}) async {
    debugPrint('[AURA STATE] Adapting workout with AI for: "$request"');
    final envelope = contextEnvelope ?? ContextEnvelope(
      activeScreen: 'workout',
      activeWorkoutDate: state.workout.date,
      focusedExerciseId: state.workout.exercises.firstOrNull?.id,
      focusedExerciseName: state.workout.exercises.firstOrNull?.name,
    );
    await addChatMessage(request, contextEnvelope: envelope);
    if (!mounted) return;
    state = state.copyWith(
      adaptationNotice: 'Workout adapted via AURA AI: "$request"',
    );
  }

  Future<void> undoCommandPreview(CommandPreview preview) async {
    if (preview.inverseCommand == null || preview.inverseCommand!.isEmpty) return;
    debugPrint('[AURA STATE] Reversing action via inverse command: ${preview.inverseCommand}');
    await addChatMessage(preview.inverseCommand!);
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

  Future<void> approvePendingAction(String actionId) async {
    final uid = _auth.uid;
    if (uid != null) {
      debugPrint('[AURA STATE] Approving pending structural action: $actionId');
      await _firestore.resolvePendingAction(uid, actionId, 'approve');
    }
  }

  Future<void> rejectPendingAction(String actionId) async {
    final uid = _auth.uid;
    if (uid != null) {
      debugPrint('[AURA STATE] Rejecting pending structural action: $actionId');
      await _firestore.resolvePendingAction(uid, actionId, 'reject');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _workoutSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _recoverySubscription?.cancel();
    _chatMessagesSubscription?.cancel();
    _pendingActionsSubscription?.cancel();
    _weeklyPlanSubscription?.cancel();
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

  Future<void> _loadCurrentWeeklyPlan(String uid) async {
    final plan = await _firestore.getWeeklyPlan(uid);
    if (plan != null) {
      state = state.copyWith(weeklyPlan: plan);
      _syncTodayWorkoutWithWeeklyPlan(plan);
      debugPrint('[AURA STATE] Loaded weekly plan: ${plan.weekId}');
    }
  }

  Future<void> generateWeeklyPlan() async {
    debugPrint('[AURA STATE] Generating AI weekly plan...');
    state = state.copyWith(isAiThinking: true);

    try {
      final plan = await _aiService.generateAIWeeklyPlan(state);
      if (plan != null) {
        state = state.copyWith(weeklyPlan: plan, isAiThinking: false);
        await _repository.saveWeeklyPlan(plan);
        final uid = _auth.uid;
        if (uid != null) {
          await _firestore.saveWeeklyPlan(uid, plan);
        }
        _syncTodayWorkoutWithWeeklyPlan(plan);
        debugPrint('[AURA STATE] Weekly plan updated in state and persisted: ${plan.weekId}');
      } else {
        state = state.copyWith(isAiThinking: false);
      }
    } catch (e) {
      debugPrint('[AURA STATE] Weekly plan generation failed: $e');
      state = state.copyWith(isAiThinking: false);
    }
  }
}

final transformationEngineProvider =
    StateNotifierProvider<TransformationEngineNotifier, TransformationEngineState>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  return TransformationEngineNotifier(analytics: analytics);
});
