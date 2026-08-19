import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'transformation_repository.dart';
import 'analytics_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IAnalyticsService _analytics = MixpanelAnalyticsService();

  String? get uid => _auth.currentUser?.uid;
  String? get email => _auth.currentUser?.email;
  String? get displayName => _auth.currentUser?.displayName;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final cred = await _auth.signInWithPopup(GoogleAuthProvider());
      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
        await _analytics.setUserProperties({
          if (user.displayName != null) r'$name': user.displayName,
          if (user.email != null) r'$email': user.email,
          'sign_up_method': 'google',
        });
      }
      return cred;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Google Sign-In error: $e');
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
        await _analytics.setUserProperties({
          r'$email': email,
          'sign_up_method': 'email',
        });
      }
      return cred;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Email sign-up error: $e');
      // If account exists, try signing in instead
      try {
        final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
        final user = cred.user;
        if (user != null) {
          await _analytics.setUserId(user.uid);
          await _analytics.setUserProperties({
            r'$email': email,
            'sign_up_method': 'email',
          });
        }
        return cred;
      } catch (e2) {
        debugPrint('[FIREBASE AUTH] Email sign-in fallback error: $e2');
        return null;
      }
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
        await _analytics.setUserProperties({
          'sign_up_method': 'anonymous',
        });
      }
      return cred;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Anonymous sign-in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _analytics.reset();
    await _auth.signOut();
  }
}

class FirebaseFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
  final ITransformationRepository _localRepo = LocalTransformationRepository();

  // ─── User Profile ───

  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    final map = {
      'name': profile.name,
      'age': profile.age,
      'gender': profile.gender,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'targetWeightKg': profile.targetWeightKg,
      'goal': profile.goal.name,
      'daysPerWeek': profile.daysPerWeek,
      'targetPhysique': profile.targetPhysique,
      'equipmentList': profile.equipmentList.map((e) => e.toMap()).toList(),
      'availableEquipment': profile.availableEquipment.map((e) => e.name).toList(),
      'experienceLevel': profile.experienceLevel.name,
      'benchPress1RMKg': profile.benchPress1RMKg,
      'squat1RMKg': profile.squat1RMKg,
      'deadlift1RMKg': profile.deadlift1RMKg,
      'activeInjuries': profile.activeInjuries,
      'dislikedExercises': profile.dislikedExercises,
      'personalNotes': profile.personalNotes,
      'coachSoul': profile.coachSoul.name,
      'dietaryPreference': profile.dietaryPreference,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set(map, SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveUserProfile failed: $e');
    }
    await _localRepo.saveProfile(profile);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 15));
      if (doc.exists && doc.data() != null) {
        final map = doc.data()!;
        List<EquipmentItem> equipItems = [];
        if (map['equipmentList'] is List) {
          equipItems = (map['equipmentList'] as List)
              .map((e) => EquipmentItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else if (map['availableEquipment'] is List) {
          equipItems = (map['availableEquipment'] as List)
              .map((e) => EquipmentItem.fromString(e.toString()))
              .toList();
        }
        if (equipItems.isEmpty) {
          equipItems = [const EquipmentItem(name: 'Bodyweight', category: 'bodyweight')];
        }

        final profile = UserProfile(
          name: map['name'] ?? '',
          age: map['age'] ?? 25,
          gender: map['gender'] ?? 'male',
          heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
          weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
          targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 68.0,
          goal: GoalType.values.firstWhere((g) => g.name == map['goal'], orElse: () => GoalType.recomp),
          daysPerWeek: map['daysPerWeek'] ?? 4,
          targetPhysique: map['targetPhysique'] ?? 'Athletic Physique',
          equipmentList: equipItems,
          experienceLevel: ExperienceLevel.values.firstWhere((exp) => exp.name == map['experienceLevel'], orElse: () => ExperienceLevel.intermediate),
          benchPress1RMKg: (map['benchPress1RMKg'] as num?)?.toDouble(),
          squat1RMKg: (map['squat1RMKg'] as num?)?.toDouble(),
          deadlift1RMKg: (map['deadlift1RMKg'] as num?)?.toDouble(),
          activeInjuries: (map['activeInjuries'] as List? ?? []).map((e) => e.toString()).toList(),
          dislikedExercises: (map['dislikedExercises'] as List? ?? []).map((e) => e.toString()).toList(),
          personalNotes: (map['personalNotes'] as List? ?? []).map((e) => e.toString()).toList(),
          coachSoul: CoachSoul.values.firstWhere((c) => c.name == map['coachSoul'], orElse: () => CoachSoul.supporter),
          dietaryPreference: map['dietaryPreference'] ?? 'nonVeg',
        );
        return profile;
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getUserProfile failed: $e');
    }
    return await _localRepo.loadProfile();
  }

  // ─── Workouts (Split Collection) ───

  Future<void> saveDailyWorkout(String uid, String dateStr, DailyWorkout workout) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(dateStr)
          .set({
            ...workoutToMap(workout),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyWorkout failed: $e');
    }
  }

  Stream<DocumentSnapshot> getWorkoutStream(String uid, String dateStr) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(dateStr)
        .snapshots();
  }

  Future<DailyWorkout?> getDailyWorkout(String uid, String dateStr) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(dateStr)
          .get()
          .timeout(const Duration(seconds: 15));
      if (doc.exists && doc.data() != null) {
        return workoutFromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getDailyWorkout failed: $e');
      return null;
    }
  }

  Future<Map<String, DailyWorkout>> getRecentWorkouts(String uid, {int limit = 14}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .orderBy('date', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 15));
      final map = <String, DailyWorkout>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final w = workoutFromMap(data);
        map[w.date] = w;
      }
      return map;
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getRecentWorkouts failed: $e');
      return {};
    }
  }

  // ─── Nutrition (Split Collection) ───

  Future<void> saveDailyNutrition(String uid, String dateStr, DailyNutrition nutrition) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('nutrition')
          .doc(dateStr)
          .set({
            ...nutritionToMap(nutrition),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyNutrition failed: $e');
    }
  }

  Stream<DocumentSnapshot> getNutritionStream(String uid, String dateStr) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('nutrition')
        .doc(dateStr)
        .snapshots();
  }

  Future<DailyNutrition> getDailyNutrition(String uid, String dateStr) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('nutrition')
          .doc(dateStr)
          .get()
          .timeout(const Duration(seconds: 10));
      if (doc.exists && doc.data() != null) {
        return nutritionFromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getDailyNutrition failed for $dateStr: $e');
    }
    return DailyNutrition(
      date: dateStr,
      targetCalories: 2000,
      targetProteinG: 150,
      targetCarbsG: 200,
      targetFatG: 60,
      targetWaterMl: 2800,
      waterMl: 0,
      meals: [],
    );
  }

  // ─── Recovery (Split Collection) ───

  Future<void> saveDailyRecovery(String uid, String dateStr, RecoveryCheckIn recovery) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('recovery')
          .doc(dateStr)
          .set({
            ...recoveryToMap(recovery),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyRecovery failed: $e');
    }
  }

  Stream<DocumentSnapshot> getRecoveryStream(String uid, String dateStr) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('recovery')
        .doc(dateStr)
        .snapshots();
  }

  // ─── Progress (New Collection) ───

  Future<void> saveProgress(String uid, String dateStr, ProgressEntry entry) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(dateStr)
          .set({
            'date': entry.date,
            'weightKg': entry.weightKg,
            'bodyFatPercent': entry.bodyFatPercent,
            'waistCm': entry.waistCm,
            'notes': entry.notes,
            if (entry.workoutStatus != null) 'workoutStatus': entry.workoutStatus!.name,
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveProgress failed: $e');
    }
  }

  Future<List<ProgressEntry>> getProgressHistory(String uid, {int limit = 30}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('progress')
          .orderBy('date', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 15));
      return snapshot.docs.map((doc) {
        final map = doc.data();
        final notesStr = map['notes']?.toString().toLowerCase() ?? '';
        final fallbackStatus = notesStr.contains('skipped')
            ? WorkoutStatus.skipped
            : (notesStr.contains('workout') ? WorkoutStatus.completed : null);

        final rawStatus = map['workoutStatus']?.toString();
        final status = rawStatus != null
            ? WorkoutStatus.values.firstWhere(
                (s) => s.name == rawStatus,
                orElse: () => fallbackStatus ?? WorkoutStatus.completed,
              )
            : fallbackStatus;

        return ProgressEntry(
          date: map['date'] ?? doc.id,
          weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
          bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
          waistCm: (map['waistCm'] as num?)?.toDouble(),
          notes: map['notes'],
          workoutStatus: status,
        );
      }).toList();
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getProgressHistory failed: $e');
      return [];
    }
  }

  // ─── Chat Messages (Paginated) ───

  Future<void> saveChatMessage(String uid, ChatMessage message) async {
    try {
      final docData = <String, dynamic>{
        'id': message.id,
        'sender': message.sender,
        'text': message.text,
        'timestamp': message.timestamp,
        'serverTimestamp': FieldValue.serverTimestamp(),
      };
      if (message.imageBytes != null && message.imageBytes!.isNotEmpty) {
        docData['imageBase64'] = base64Encode(message.imageBytes!);
      }
      await _db
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc('default_chat')
          .collection('messages')
          .doc(message.id)
          .set(docData)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveChatMessage failed: $e');
    }
  }

  Stream<QuerySnapshot> getChatMessagesStream(String uid, {int limit = 50}) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc('default_chat')
        .collection('messages')
        .orderBy('serverTimestamp', descending: false)
        .limitToLast(limit)
        .snapshots();
  }

  // ─── Weekly Plan ───

  Future<void> saveWeeklyPlan(String uid, WeeklyPlan plan) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('weekly_plans')
          .doc(plan.weekId)
          .set({
            ...weeklyPlanToMap(plan),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveWeeklyPlan failed: $e');
    }
  }

  Future<WeeklyPlan?> getWeeklyPlan(String uid, String weekId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('weekly_plans')
          .doc(weekId)
          .get()
          .timeout(const Duration(seconds: 15));
      if (doc.exists && doc.data() != null) {
        return weeklyPlanFromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getWeeklyPlan failed: $e');
    }
    return null;
  }

  Stream<DocumentSnapshot> getWeeklyPlanStream(String uid, String weekId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .snapshots();
  }

  // ─── Master Context ───

  Future<void> saveMasterContext(String uid, MasterContext ctx) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('master_context')
          .doc('current')
          .set({
            ...masterContextToMap(ctx),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveMasterContext failed: $e');
    }
  }

  Future<MasterContext?> getMasterContext(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('master_context')
          .doc('current')
          .get()
          .timeout(const Duration(seconds: 15));
      if (doc.exists && doc.data() != null) {
        return masterContextFromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getMasterContext failed: $e');
    }
    return null;
  }

  Stream<DocumentSnapshot> getMasterContextStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('master_context')
        .doc('current')
        .snapshots();
  }

  // ─── Serializers: Workout ───

  Map<String, dynamic> workoutToMap(DailyWorkout workout) {
    return {
      'id': workout.id,
      'date': workout.date,
      'title': workout.title,
      'focusArea': workout.focusArea,
      'estimatedDurationMin': workout.estimatedDurationMin,
      'status': workout.status.name,
      'adaptationNote': workout.adaptationNote,
      'exercises': workout.exercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'targetMuscle': e.targetMuscle,
        'equipmentRequired': e.equipmentRequired,
        'notes': e.notes,
        'sets': e.sets.map((s) => {
          'setNumber': s.setNumber,
          'targetReps': s.targetReps,
          'actualReps': s.actualReps,
          'targetWeightKg': s.targetWeightKg,
          'actualWeightKg': s.actualWeightKg,
          'completed': s.completed,
        }).toList(),
      }).toList(),
    };
  }

  DailyWorkout workoutFromMap(Map<String, dynamic> map) {
    return DailyWorkout(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      title: map['title'] ?? '',
      focusArea: map['focusArea'] ?? '',
      estimatedDurationMin: map['estimatedDurationMin'] ?? 0,
      status: WorkoutStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => WorkoutStatus.scheduled),
      adaptationNote: map['adaptationNote'],
      exercises: (map['exercises'] as List? ?? []).map((e) {
        return Exercise(
          id: e['id'] ?? '',
          name: e['name'] ?? '',
          targetMuscle: e['targetMuscle'] ?? '',
          equipmentRequired: e['equipmentRequired']?.toString() ?? 'bodyweight',
          notes: e['notes'],
          sets: (e['sets'] as List? ?? []).map((s) {
            return ExerciseSet(
              setNumber: s['setNumber'] ?? 1,
              targetReps: s['targetReps'] ?? 10,
              actualReps: s['actualReps'],
              targetWeightKg: (s['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
              actualWeightKg: (s['actualWeightKg'] as num?)?.toDouble(),
              completed: s['completed'] ?? false,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // ─── Serializers: Nutrition ───

  Map<String, dynamic> nutritionToMap(DailyNutrition nutrition) {
    return {
      'date': nutrition.date,
      'targetCalories': nutrition.targetCalories,
      'targetProteinG': nutrition.targetProteinG,
      'targetCarbsG': nutrition.targetCarbsG,
      'targetFatG': nutrition.targetFatG,
      'waterMl': nutrition.waterMl,
      'targetWaterMl': nutrition.targetWaterMl,
      'meals': nutrition.meals.map((m) => {
        'name': m.name,
        'calories': m.calories,
        'proteinG': m.proteinG,
        'carbsG': m.carbsG,
        'fatG': m.fatG,
      }).toList(),
    };
  }

  DailyNutrition nutritionFromMap(Map<String, dynamic> map) {
    return DailyNutrition(
      date: map['date'] ?? '',
      targetCalories: map['targetCalories'] ?? 2000,
      targetProteinG: map['targetProteinG'] ?? 150,
      targetCarbsG: map['targetCarbsG'] ?? 200,
      targetFatG: map['targetFatG'] ?? 60,
      waterMl: map['waterMl'] ?? 0,
      targetWaterMl: map['targetWaterMl'] ?? 3200,
      meals: (map['meals'] as List? ?? []).map((m) {
        return MealItem(
          name: m['name'] ?? '',
          calories: m['calories'] ?? 0,
          proteinG: m['proteinG'] ?? 0,
          carbsG: m['carbsG'] ?? 0,
          fatG: m['fatG'] ?? 0,
        );
      }).toList(),
    );
  }

  // ─── Serializers: Recovery ───

  Map<String, dynamic> recoveryToMap(RecoveryCheckIn recovery) {
    return {
      'date': recovery.date,
      'sleepHours': recovery.sleepHours,
      'sleepQuality': recovery.sleepQuality,
      'muscleSoreness': recovery.muscleSoreness,
      'energyLevel': recovery.energyLevel,
      'stressLevel': recovery.stressLevel,
      'recoveryScore': recovery.recoveryScore,
      'status': recovery.status,
    };
  }

  RecoveryCheckIn recoveryFromMap(Map<String, dynamic> map) {
    return RecoveryCheckIn(
      date: map['date'] ?? '',
      sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 7.0,
      sleepQuality: map['sleepQuality'] ?? 8,
      muscleSoreness: map['muscleSoreness'] ?? 4,
      energyLevel: map['energyLevel'] ?? 8,
      stressLevel: map['stressLevel'] ?? 3,
      recoveryScore: map['recoveryScore'] ?? 80,
      status: map['status'] ?? 'Optimal Adaptation',
    );
  }

  // ─── Serializers: Weekly Plan ───

  Map<String, dynamic> weeklyPlanToMap(WeeklyPlan plan) {
    return {
      'weekId': plan.weekId,
      'startDate': plan.startDate,
      'endDate': plan.endDate,
      'overview': plan.overview,
      'coachNote': plan.coachNote,
      'createdAt': plan.createdAt,
      'days': plan.days.map((d) => {
        'dayName': d.dayName,
        'date': d.date,
        'title': d.title,
        'focusArea': d.focusArea,
        'isRestDay': d.isRestDay,
        'exerciseNames': d.exerciseNames,
        'nutritionFocus': d.nutritionFocus,
      }).toList(),
    };
  }

  WeeklyPlan weeklyPlanFromMap(Map<String, dynamic> map) {
    return WeeklyPlan(
      weekId: map['weekId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      overview: map['overview'] ?? '',
      coachNote: map['coachNote'],
      createdAt: map['createdAt'] ?? '',
      days: (map['days'] as List? ?? []).map((d) {
        return WeeklyDayPlan(
          dayName: d['dayName'] ?? '',
          date: d['date'] ?? '',
          title: d['title'] ?? '',
          focusArea: d['focusArea'] ?? '',
          isRestDay: d['isRestDay'] ?? false,
          exerciseNames: (d['exerciseNames'] as List? ?? []).map((e) => e.toString()).toList(),
          nutritionFocus: d['nutritionFocus'],
        );
      }).toList(),
    );
  }

  // ─── Serializers: Master Context ───

  Map<String, dynamic> masterContextToMap(MasterContext ctx) {
    return {
      'deduced': {
        'activityLevel': ctx.deduced.activityLevel,
        'sessionDurationMin': ctx.deduced.sessionDurationMin,
        'preferredTrainingDays': ctx.deduced.preferredTrainingDays,
        'preferredTrainingStyle': ctx.deduced.preferredTrainingStyle,
        'cardioPreference': ctx.deduced.cardioPreference,
        'activeInjuries': ctx.deduced.activeInjuries,
        'foodAllergies': ctx.deduced.foodAllergies,
        'dislikedExercises': ctx.deduced.dislikedExercises,
        'preferredProteinSources': ctx.deduced.preferredProteinSources,
        'sleepPatternAvg': ctx.deduced.sleepPatternAvg,
        'stressBaseline': ctx.deduced.stressBaseline,
        'personalNotes': ctx.deduced.personalNotes,
        'lastUpdated': ctx.deduced.lastUpdated ?? DateTime.now().toIso8601String(),
      },
      'rollingSummary': {
        'periodDays': ctx.rollingSummary.periodDays,
        'workoutComplianceRate': ctx.rollingSummary.workoutComplianceRate,
        'workoutsCompleted': ctx.rollingSummary.workoutsCompleted,
        'workoutsSkipped': ctx.rollingSummary.workoutsSkipped,
        'avgSessionDurationMin': ctx.rollingSummary.avgSessionDurationMin,
        'recentWorkouts': ctx.rollingSummary.recentWorkouts,
        'nutritionAvg': ctx.rollingSummary.nutritionAvg,
        'recoveryAvg': ctx.rollingSummary.recoveryAvg,
        'weightTrend': ctx.rollingSummary.weightTrend,
        'lastUpdated': ctx.rollingSummary.lastUpdated ?? DateTime.now().toIso8601String(),
      },
    };
  }

  MasterContext masterContextFromMap(Map<String, dynamic> map) {
    final deducedMap = map['deduced'] as Map<String, dynamic>? ?? {};
    final summaryMap = map['rollingSummary'] as Map<String, dynamic>? ?? {};

    return MasterContext(
      deduced: DeducedKnowledge(
        activityLevel: deducedMap['activityLevel'],
        sessionDurationMin: deducedMap['sessionDurationMin'],
        preferredTrainingDays: (deducedMap['preferredTrainingDays'] as List? ?? []).map((e) => e.toString()).toList(),
        preferredTrainingStyle: deducedMap['preferredTrainingStyle'],
        cardioPreference: deducedMap['cardioPreference'],
        activeInjuries: (deducedMap['activeInjuries'] as List? ?? []).map((e) => e.toString()).toList(),
        foodAllergies: (deducedMap['foodAllergies'] as List? ?? []).map((e) => e.toString()).toList(),
        dislikedExercises: (deducedMap['dislikedExercises'] as List? ?? []).map((e) => e.toString()).toList(),
        preferredProteinSources: (deducedMap['preferredProteinSources'] as List? ?? []).map((e) => e.toString()).toList(),
        sleepPatternAvg: (deducedMap['sleepPatternAvg'] as num?)?.toDouble(),
        stressBaseline: deducedMap['stressBaseline'],
        personalNotes: (deducedMap['personalNotes'] as List? ?? []).map((e) => e.toString()).toList(),
        lastUpdated: deducedMap['lastUpdated'],
      ),
      rollingSummary: RollingSummary(
        periodDays: summaryMap['periodDays'] ?? 7,
        workoutComplianceRate: (summaryMap['workoutComplianceRate'] as num?)?.toDouble() ?? 0.0,
        workoutsCompleted: summaryMap['workoutsCompleted'] ?? 0,
        workoutsSkipped: summaryMap['workoutsSkipped'] ?? 0,
        avgSessionDurationMin: (summaryMap['avgSessionDurationMin'] as num?)?.toDouble(),
        recentWorkouts: (summaryMap['recentWorkouts'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        nutritionAvg: Map<String, dynamic>.from(summaryMap['nutritionAvg'] ?? {}),
        recoveryAvg: Map<String, dynamic>.from(summaryMap['recoveryAvg'] ?? {}),
        weightTrend: (summaryMap['weightTrend'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        lastUpdated: summaryMap['lastUpdated'],
      ),
    );
  }
}
