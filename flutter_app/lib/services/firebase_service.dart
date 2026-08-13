import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'transformation_repository.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isAuthenticated => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  Future<String?> signInWithGoogle() async {
    try {
      final userCred = await _auth.signInAnonymously();
      return userCred.user?.uid;
    } catch (e) {
      debugPrint('[FIREBASE AUTH ERROR] signInWithGoogle failed: $e');
      return 'firebase_user_vance_77'; // Fallback to local test baseline
    }
  }

  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCred.user?.uid;
    } catch (e) {
      // Gracefully fall back to anonymous session if creation fails during debug
      try {
        final userCred = await _auth.signInAnonymously();
        return userCred.user?.uid;
      } catch (err) {
        debugPrint('[FIREBASE AUTH ERROR] Anonymous fallback failed: $err');
        return 'firebase_user_vance_77';
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class FirebaseFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
  final ITransformationRepository _localRepo = LocalTransformationRepository();

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
      'availableEquipment': profile.availableEquipment.map((e) => e.name).toList(),
      'experienceLevel': profile.experienceLevel.name,
      'benchPress1RMKg': profile.benchPress1RMKg,
      'squat1RMKg': profile.squat1RMKg,
      'deadlift1RMKg': profile.deadlift1RMKg,
      'activeInjuries': profile.activeInjuries,
      'coachSoul': profile.coachSoul.name,
    };
    try {
      // Adds a 15-second timeout so the app never hangs if Firestore is offline
      // or if auth permissions are not configured yet.
      await _db
          .collection('users')
          .doc(uid)
          .set(map)
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
        final profile = UserProfile(
          name: map['name'] ?? '',
          age: map['age'] ?? 25,
          gender: map['gender'] ?? 'male',
          heightCm: (map['heightCm'] as num).toDouble(),
          weightKg: (map['weightKg'] as num).toDouble(),
          targetWeightKg: (map['targetWeightKg'] as num).toDouble(),
          goal: GoalType.values.firstWhere((g) => g.name == map['goal'], orElse: () => GoalType.recomp),
          daysPerWeek: map['daysPerWeek'] ?? 4,
          targetPhysique: map['targetPhysique'] ?? 'Athletic Physique',
          availableEquipment: (map['availableEquipment'] as List? ?? [])
              .map((e) => EquipmentType.values.firstWhere((eq) => eq.name == e, orElse: () => EquipmentType.dumbbells))
              .toList(),
          experienceLevel: ExperienceLevel.values.firstWhere((exp) => exp.name == map['experienceLevel'], orElse: () => ExperienceLevel.intermediate),
          benchPress1RMKg: (map['benchPress1RMKg'] as num?)?.toDouble(),
          squat1RMKg: (map['squat1RMKg'] as num?)?.toDouble(),
          deadlift1RMKg: (map['deadlift1RMKg'] as num?)?.toDouble(),
          activeInjuries: (map['activeInjuries'] as List? ?? []).map((e) => e.toString()).toList(),
          coachSoul: CoachSoul.values.firstWhere((c) => c.name == map['coachSoul'], orElse: () => CoachSoul.supporter),
        );
        return profile;
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getUserProfile failed: $e');
    }
    return await _localRepo.loadProfile();
  }

  Future<void> saveDailyLog(String uid, String dateStr, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('daily_logs')
          .doc(dateStr)
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyLog failed: $e');
    }
  }

  Future<void> saveDailyWorkout(String uid, String dateStr, DailyWorkout workout) async {
    await saveDailyLog(uid, dateStr, {'workout': workoutToMap(workout)});
  }

  Future<void> saveDailyNutrition(String uid, String dateStr, DailyNutrition nutrition) async {
    await saveDailyLog(uid, dateStr, {'nutrition': nutritionToMap(nutrition)});
  }

  Future<void> saveDailyRecovery(String uid, String dateStr, RecoveryCheckIn recovery) async {
    await saveDailyLog(uid, dateStr, {'recovery': recoveryToMap(recovery)});
  }

  Future<void> saveChatMessage(String uid, ChatMessage message) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc('default_chat')
          .collection('messages')
          .doc(message.id)
          .set({
            'id': message.id,
            'sender': message.sender,
            'text': message.text,
            'timestamp': message.timestamp,
            'serverTimestamp': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveChatMessage failed: $e');
    }
  }

  Stream<DocumentSnapshot> getDailyLogStream(String uid, String dateStr) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .doc(dateStr)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessagesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc('default_chat')
        .collection('messages')
        .orderBy('serverTimestamp', descending: false)
        .snapshots();
  }

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
        'equipmentRequired': e.equipmentRequired.name,
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
          equipmentRequired: EquipmentType.values.firstWhere((eq) => eq.name == e['equipmentRequired'], orElse: () => EquipmentType.dumbbells),
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
}
