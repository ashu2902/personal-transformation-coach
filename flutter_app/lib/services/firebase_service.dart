import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/nutrition.dart';
import '../models/recovery.dart';
import '../models/chat_and_ai.dart';
import '../models/weekly_plan.dart';
import '../models/master_context.dart';
import 'transformation_repository.dart';
import 'analytics_service.dart';

class FirebaseAuthService {
  final FirebaseAuth? _auth;
  final IAnalyticsService _analytics;

  FirebaseAuthService({
    FirebaseAuth? auth,
    IAnalyticsService? analytics,
  })  : _auth = auth ??
            (Firebase.apps.isNotEmpty
                ? FirebaseAuth.instance
                : null),
        _analytics = analytics ?? MixpanelAnalyticsService();

  String? get uid => _auth?.currentUser?.uid;
  String? get email => _auth?.currentUser?.email;
  String? get displayName => _auth?.currentUser?.displayName;
  bool get isAuthenticated => _auth?.currentUser != null;
  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? true;
  bool get isPermanentUser => _auth?.currentUser != null && !_auth!.currentUser!.isAnonymous;
  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  Future<UserCredential?> linkAnonymousWithGoogle() async {
    try {
      if (_auth == null) return null;
      final currentUser = _auth!.currentUser;
      final googleProvider = GoogleAuthProvider();
      UserCredential cred;

      if (currentUser != null && currentUser.isAnonymous) {
        debugPrint('[FIREBASE AUTH] Linking anonymous guest account with Google...');
        cred = await currentUser.linkWithPopup(googleProvider);
      } else {
        debugPrint('[FIREBASE AUTH] Signing in with Google popup...');
        cred = await _auth!.signInWithPopup(googleProvider);
      }

      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
        await _analytics.setUserProperties({
          if (user.displayName != null) r'$name': user.displayName,
          if (user.email != null) r'$email': user.email,
          'sign_up_method': 'google_linked',
          'is_guest': false,
        });
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      debugPrint('[FIREBASE AUTH] Google Link/Sign-In error code: ${e.code}, message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Google Link error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_auth == null) return null;
      final cred = await _auth!.signInWithPopup(GoogleAuthProvider());
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
      if (_auth == null) return null;
      final cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
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
      debugPrint('[FIREBASE AUTH] Sign-Up error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (_auth == null) return null;
      final cred = await _auth!.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
      }
      return cred;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Sign-In error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      if (_auth == null) return null;
      final cred = await _auth!.signInAnonymously();
      final user = cred.user;
      if (user != null) {
        await _analytics.setUserId(user.uid);
        await _analytics.setUserProperties({
          'sign_up_method': 'anonymous',
        });
      }
      return cred;
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Anonymous Sign-In error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _analytics.reset();
    if (_auth != null) {
      await _auth!.signOut();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _analytics.logEvent(AuraAnalyticsEvents.accountDeleted, properties: {'reason': 'user_requested'});
    } catch (e) {
      debugPrint('[FIREBASE AUTH] Analytics log error on delete: $e');
    }
    await _analytics.reset();
    final user = _auth?.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}

class FirebaseFirestoreService {
  final FirebaseFirestore? _firestoreInstance;
  final ITransformationRepository _localRepo;

  FirebaseFirestoreService({
    FirebaseFirestore? firestore,
    ITransformationRepository? localRepo,
  })  : _firestoreInstance = firestore ??
            (Firebase.apps.isNotEmpty
                ? FirebaseFirestore.instance
                : null),
        _localRepo = localRepo ?? LocalTransformationRepository();

  FirebaseFirestore? get _db => _firestoreInstance;

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
      'equipmentList': profile.equipmentList.map((e) => e.toJson()).toList(),
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
      'createdAtDateStr': profile.createdAtDateStr ?? DateTime.now().toIso8601String().split('T')[0],
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .set(map, SetOptions(merge: true))
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveUserProfile failed: $e');
    }
    await _localRepo.saveProfile(profile);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      if (_db != null) {
        final doc = await _db!
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists && doc.data() != null) {
          final map = doc.data()!;
          List<EquipmentItem> equipItems = [];
          if (map['equipmentList'] is List) {
            equipItems = (map['equipmentList'] as List)
                .map((e) => EquipmentItem.fromJson(Map<String, dynamic>.from(e as Map)))
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
            createdAtDateStr: map['createdAtDateStr']?.toString(),
          );
          return profile;
        }
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getUserProfile failed: $e');
    }
    return await _localRepo.loadProfile();
  }

  // ─── Workouts (Split Collection) ───

  Future<void> saveDailyWorkout(String uid, String dateStr, DailyWorkout workout) async {
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('workouts')
            .doc(dateStr)
            .set({
              ...workoutToMap(workout),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyWorkout failed: $e');
    }
  }

  Future<void> deleteDailyWorkout(String uid, String dateStr) async {
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('workouts')
            .doc(dateStr)
            .delete()
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] deleteDailyWorkout failed: $e');
    }
  }

  Future<void> updateDailyWorkoutField(String uid, String dateStr, Map<String, dynamic> fields) async {
    try {
      if (_db != null) {
        final updateData = {
          ...fields,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _db!
            .collection('users')
            .doc(uid)
            .collection('workouts')
            .doc(dateStr)
            .update(updateData)
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      // If doc doesn't exist, update fails. We log it and fallback might be needed but mostly it should exist
      debugPrint('[FIRESTORE ERROR] updateDailyWorkoutField failed: $e');
    }
  }

  Stream<DocumentSnapshot> getWorkoutStream(String uid, String dateStr) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(dateStr)
        .snapshots();
  }

  Future<DailyWorkout?> getDailyWorkout(String uid, String dateStr) async {
    try {
      if (_db != null) {
        final doc = await _db!
            .collection('users')
            .doc(uid)
            .collection('workouts')
            .doc(dateStr)
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists && doc.data() != null) {
          return workoutFromMap(doc.data()!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getDailyWorkout failed: $e');
      return null;
    }
  }

  Future<Map<String, DailyWorkout>> getRecentWorkouts(String uid, {int limit = 14}) async {
    try {
      if (_db != null) {
        final snapshot = await _db!
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
      }
      return {};
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getRecentWorkouts failed: $e');
      return {};
    }
  }

  // ─── Nutrition (Split Collection) ───

  Future<void> saveDailyNutrition(String uid, String dateStr, DailyNutrition nutrition) async {
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('nutrition')
            .doc(dateStr)
            .set({
              ...nutritionToMap(nutrition),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyNutrition failed: $e');
    }
  }

  Future<void> updateDailyNutritionField(String uid, String dateStr, Map<String, dynamic> fields) async {
    try {
      if (_db != null) {
        final updateData = {
          ...fields,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _db!
            .collection('users')
            .doc(uid)
            .collection('nutrition')
            .doc(dateStr)
            .update(updateData)
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] updateDailyNutritionField failed: $e');
    }
  }

  Stream<DocumentSnapshot> getNutritionStream(String uid, String dateStr) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('nutrition')
        .doc(dateStr)
        .snapshots();
  }

  Future<DailyNutrition> getDailyNutrition(String uid, String dateStr) async {
    try {
      if (_db != null) {
        final doc = await _db!
            .collection('users')
            .doc(uid)
            .collection('nutrition')
            .doc(dateStr)
            .get()
            .timeout(const Duration(seconds: 10));
        if (doc.exists && doc.data() != null) {
          return nutritionFromMap(doc.data()!);
        }
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
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('recovery')
            .doc(dateStr)
            .set({
              ...recoveryToMap(recovery),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveDailyRecovery failed: $e');
    }
  }

  Stream<DocumentSnapshot> getRecoveryStream(String uid, String dateStr) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('recovery')
        .doc(dateStr)
        .snapshots();
  }

  // ─── Progress (New Collection) ───

  Future<void> saveProgress(String uid, String dateStr, ProgressEntry entry) async {
    try {
      if (_db != null) {
        await _db!
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
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveProgress failed: $e');
    }
  }

  Future<void> deleteProgress(String uid, String dateStr) async {
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('progress')
            .doc(dateStr)
            .delete()
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] deleteProgress failed: $e');
    }
  }

  Future<List<ProgressEntry>> getProgressHistory(String uid, {int limit = 30}) async {
    try {
      if (_db != null) {
        final snapshot = await _db!
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
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getProgressHistory failed: $e');
    }
    return [];
  }

  // ─── Chat Messages (Paginated) ───

  Future<void> saveChatMessage(String uid, ChatMessage message) async {
    try {
      if (_db != null) {
        final docData = <String, dynamic>{
          'id': message.id,
          'sender': message.sender,
          'text': message.text,
          'timestamp': message.timestamp,
          'serverTimestamp': FieldValue.serverTimestamp(),
        };
        if (message.imageUrl != null) {
          docData['imageUrl'] = message.imageUrl;
        } else if (message.imageBytes != null && message.imageBytes!.isNotEmpty) {
          // Legacy support (to be fully removed after migration)
          docData['imageBase64'] = base64Encode(message.imageBytes!);
        }
        await _db!
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc('default_chat')
            .collection('messages')
            .doc(message.id)
            .set(docData)
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveChatMessage failed: $e');
    }
  }

  Stream<QuerySnapshot> getChatMessagesStream(String uid, {int limit = 50}) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc('default_chat')
        .collection('messages')
        .orderBy('serverTimestamp', descending: false)
        .limitToLast(limit)
        .snapshots();
  }

  // ─── Pending Actions (Structural Gate) ───

  Stream<List<PendingAction>> getPendingActionsStream(String uid) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('pending_actions')
        .snapshots()
        .map((snapshot) {
          final list = <PendingAction>[];
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              if (data['status'] == 'pending') {
                list.add(PendingAction.fromJson(data));
              }
            } catch (e) {
              debugPrint('[PENDING ACTION] Skip parsing error for ${doc.id}: $e');
            }
          }
          return list;
        });
  }

  Future<void> resolvePendingAction(String uid, String actionId, String decision) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      const url = 'https://us-central1-aura-coach-ashu-7.cloudfunctions.net/handlePendingAction';
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'actionId': actionId,
          'decision': decision,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('[PENDING ACTION ERROR] Server returned ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('[PENDING ACTION ERROR] resolvePendingAction failed: $e');
    }
  }

  // ─── Weekly Plan ───

  Future<void> saveWeeklyPlan(String uid, WeeklyPlan plan) async {
    try {
      if (_db != null) {
        final planData = {
          ...weeklyPlanToMap(plan),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (plan.weekId.isNotEmpty) {
          await _db!
              .collection('users')
              .doc(uid)
              .collection('weekly_plans')
              .doc(plan.weekId)
              .set(planData)
              .timeout(const Duration(seconds: 15));
        }
        await _db!
            .collection('users')
            .doc(uid)
            .collection('weekly_plans')
            .doc('current')
            .set(planData)
            .timeout(const Duration(seconds: 15));
      }
      await _localRepo.saveWeeklyPlan(plan);
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveWeeklyPlan failed: $e');
    }
  }

  Future<WeeklyPlan?> getWeeklyPlan(String uid, [String? weekId]) async {
    try {
      if (_db != null) {
        // 1. Try reading the 'current' document or specific weekId document
        final targetDocId = (weekId != null && weekId.isNotEmpty) ? weekId : 'current';
        final doc = await _db!
            .collection('users')
            .doc(uid)
            .collection('weekly_plans')
            .doc(targetDocId)
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists && doc.data() != null) {
          final plan = weeklyPlanFromMap(doc.data()!);
          await _localRepo.saveWeeklyPlan(plan);
          return plan;
        }

        // 2. Fallback: Fetch all weekly plans for this user and take the newest
        final snapshot = await _db!
            .collection('users')
            .doc(uid)
            .collection('weekly_plans')
            .get()
            .timeout(const Duration(seconds: 15));
        if (snapshot.docs.isNotEmpty) {
          final sortedDocs = snapshot.docs.toList()
            ..sort((a, b) {
              final aData = a.data();
              final bData = b.data();
              final aTime = aData['updatedAt']?.toString() ?? aData['createdAt']?.toString() ?? a.id;
              final bTime = bData['updatedAt']?.toString() ?? bData['createdAt']?.toString() ?? b.id;
              return bTime.compareTo(aTime);
            });
          final plan = weeklyPlanFromMap(sortedDocs.first.data());
          await _localRepo.saveWeeklyPlan(plan);
          return plan;
        }
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getWeeklyPlan failed: $e');
    }
    return await _localRepo.loadWeeklyPlan();
  }

  Stream<DocumentSnapshot> getCurrentWeeklyPlanStream(String uid) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc('current')
        .snapshots();
  }

  Stream<DocumentSnapshot> getWeeklyPlanStream(String uid, String weekId) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .snapshots();
  }


  // ─── Master Context ───

  Future<void> saveMasterContext(String uid, MasterContext ctx) async {
    try {
      if (_db != null) {
        await _db!
            .collection('users')
            .doc(uid)
            .collection('master_context')
            .doc('current')
            .set({
              ...masterContextToMap(ctx),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] saveMasterContext failed: $e');
    }
  }

  Future<MasterContext?> getMasterContext(String uid) async {
    try {
      if (_db != null) {
        final doc = await _db!
            .collection('users')
            .doc(uid)
            .collection('master_context')
            .doc('current')
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists && doc.data() != null) {
          return masterContextFromMap(doc.data()!);
        }
      }
    } catch (e) {
      debugPrint('[FIRESTORE ERROR] getMasterContext failed: $e');
    }
    return null;
  }

  Stream<DocumentSnapshot> getMasterContextStream(String uid) {
    if (_db == null) return const Stream.empty();
    return _db!
        .collection('users')
        .doc(uid)
        .collection('master_context')
        .doc('current')
        .snapshots();
  }

  // ─── Account Archiving & Deletion ───

  Future<void> archiveAndDeleteUserData(String uid) async {
    final db = _db;
    if (db == null) return;
    debugPrint('[FIRESTORE ARCHIVE] Archiving and deleting data for UID: $uid');
    try {
      final userDocRef = db.collection('users').doc(uid);
      final deletedUserDocRef = db.collection('deleted_users').doc(uid);

      // 1. Fetch & archive the main user profile doc
      final userSnap = await userDocRef.get().timeout(const Duration(seconds: 15));
      if (userSnap.exists && userSnap.data() != null) {
        final userData = Map<String, dynamic>.from(userSnap.data()!);
        userData['archivedAt'] = FieldValue.serverTimestamp();
        await deletedUserDocRef.set(userData, SetOptions(merge: true));
      } else {
        await deletedUserDocRef.set({
          'uid': uid,
          'archivedAt': FieldValue.serverTimestamp(),
          'note': 'User profile document was empty or missing at time of deletion.',
        });
      }

      // 2. Subcollections to migrate:
      final simpleSubcollections = ['workouts', 'nutrition', 'recovery', 'progress', 'weekly_plans', 'master_context'];
      for (final sub in simpleSubcollections) {
        try {
          final querySnap = await userDocRef.collection(sub).get().timeout(const Duration(seconds: 15));
          for (final doc in querySnap.docs) {
            final data = doc.data();
            await deletedUserDocRef.collection(sub).doc(doc.id).set(data);
            await doc.reference.delete();
          }
        } catch (subErr) {
          debugPrint('[FIRESTORE ARCHIVE] Error migrating subcollection $sub: $subErr');
        }
      }

      // 3. Migrate chats subcollection: chats/default_chat/messages
      try {
        final messagesSnap = await userDocRef
            .collection('chats')
            .doc('default_chat')
            .collection('messages')
            .get()
            .timeout(const Duration(seconds: 15));
        for (final msgDoc in messagesSnap.docs) {
          final data = msgDoc.data();
          await deletedUserDocRef
              .collection('chats')
              .doc('default_chat')
              .collection('messages')
              .doc(msgDoc.id)
              .set(data);
          await msgDoc.reference.delete();
        }
        await userDocRef.collection('chats').doc('default_chat').delete();
      } catch (chatErr) {
        debugPrint('[FIRESTORE ARCHIVE] Error migrating chat messages: $chatErr');
      }

      // 4. Delete root user profile doc
      await userDocRef.delete().timeout(const Duration(seconds: 15));
      debugPrint('[FIRESTORE ARCHIVE] Successfully archived user data to deleted_users/$uid and removed source.');
    } catch (e) {
      debugPrint('[FIRESTORE ARCHIVE ERROR] Failed to complete archive and delete: $e');
      rethrow;
    }
  }

  // ─── Serializers: Workout ───

  List<Map<String, dynamic>> mapExercises(List<Exercise> exercises) {
    return exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'targetMuscle': e.targetMuscle,
      'equipmentRequired': e.equipmentRequired,
      'trackingType': e.trackingType.name,
      'notes': e.notes,
      'instructions': e.instructions,
      'videoUrl': e.videoUrl,
      'sets': e.sets.map((s) => {
        'setNumber': s.setNumber,
        'targetReps': s.targetReps,
        'actualReps': s.actualReps,
        'targetWeightKg': s.targetWeightKg,
        'actualWeightKg': s.actualWeightKg,
        'targetDurationSeconds': s.targetDurationSeconds,
        'actualDurationSeconds': s.actualDurationSeconds,
        'completed': s.completed,
      }).toList(),
    }).toList();
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
      'exercises': mapExercises(workout.exercises),
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
          trackingType: ExerciseTrackingType.values.firstWhere(
            (t) => t.name == e['trackingType'],
            orElse: () => ExerciseTrackingType.reps,
          ),
          notes: e['notes'],
          instructions: e['instructions'],
          videoUrl: e['videoUrl'],
          sets: (e['sets'] as List? ?? []).map((s) {
            return ExerciseSet(
              setNumber: s['setNumber'] ?? 1,
              targetReps: s['targetReps'] ?? 10,
              actualReps: s['actualReps'],
              targetWeightKg: (s['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
              actualWeightKg: (s['actualWeightKg'] as num?)?.toDouble(),
              targetDurationSeconds: s['targetDurationSeconds'] ?? 0,
              actualDurationSeconds: s['actualDurationSeconds'],
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
        'plannedExercises': d.plannedExercises.map((p) => p.toJson()).toList(),
        'nutritionFocus': d.nutritionFocus,
      }).toList(),
    };
  }

  WeeklyPlan weeklyPlanFromMap(Map<String, dynamic> map) {
    final startDateStr = map['startDate']?.toString() ?? '';
    DateTime? baseDate;
    if (startDateStr.isNotEmpty) {
      try {
        baseDate = DateTime.parse(startDateStr);
      } catch (_) {}
    }
    if (baseDate == null) {
      final now = DateTime.now();
      baseDate = now.subtract(Duration(days: now.weekday - 1));
    }

    final rawDays = (map['days'] as List? ?? []);
    final days = <WeeklyDayPlan>[];
    for (int i = 0; i < rawDays.length; i++) {
      final d = rawDays[i] as Map? ?? {};
      String dateStr = d['date']?.toString() ?? '';
      if (dateStr.isEmpty) {
        final calculatedDay = baseDate.add(Duration(days: i));
        dateStr = calculatedDay.toIso8601String().split('T')[0];
      }

      final rawPlanned = (d['plannedExercises'] as List? ?? []);
      final plannedExercises = rawPlanned
          .map((p) => PlannedExercise.fromJson(p as Map<String, dynamic>))
          .toList();
      final exerciseNames = (d['exerciseNames'] as List? ?? [])
          .map((e) => e.toString())
          .toList();

      days.add(WeeklyDayPlan(
        dayName: d['dayName']?.toString() ?? '',
        date: dateStr,
        title: d['title']?.toString() ?? '',
        focusArea: d['focusArea']?.toString() ?? '',
        isRestDay: d['isRestDay'] == true,
        exerciseNames: exerciseNames.isNotEmpty
            ? exerciseNames
            : plannedExercises.map((p) => p.name).toList(),
        plannedExercises: plannedExercises,
        nutritionFocus: d['nutritionFocus']?.toString(),
      ));
    }

    return WeeklyPlan(
      weekId: map['weekId']?.toString() ?? '',
      startDate: startDateStr.isNotEmpty ? startDateStr : baseDate.toIso8601String().split('T')[0],
      endDate: map['endDate']?.toString() ?? baseDate.add(const Duration(days: 6)).toIso8601String().split('T')[0],
      overview: map['overview']?.toString() ?? '',
      coachNote: map['coachNote']?.toString(),
      createdAt: map['createdAt']?.toString() ?? '',
      days: days,
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
