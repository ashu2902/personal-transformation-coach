import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'transformation_repository.dart';

class FirebaseAuthService {
  bool _isAuthenticated = false;
  String? _uid;

  bool get isAuthenticated => _isAuthenticated;
  String? get uid => _uid;

  Future<String?> signInWithGoogle() async {
    debugPrint('[FIREBASE AUTH] Initiating Google Sign-In...');
    await Future.delayed(const Duration(milliseconds: 1500));
    _isAuthenticated = true;
    _uid = 'firebase_user_vance_77';
    debugPrint('[FIREBASE AUTH] Sign-in successful. UID: $_uid');
    return _uid;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _uid = null;
    debugPrint('[FIREBASE AUTH] User signed out.');
  }
}

class FirebaseFirestoreService {
  final ITransformationRepository _localRepo = LocalTransformationRepository();

  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    debugPrint('[FIRESTORE] Writing to path: users/$uid/profile');
    await _localRepo.saveProfile(profile);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    debugPrint('[FIRESTORE] Reading from path: users/$uid/profile');
    return await _localRepo.loadProfile();
  }

  Future<void> saveDailyLog(String uid, String dateStr, Map<String, dynamic> data) async {
    debugPrint('[FIRESTORE] Writing to path: users/$uid/daily_logs/$dateStr');
  }
}
