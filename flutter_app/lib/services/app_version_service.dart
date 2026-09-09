import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'web_reload_stub.dart'
    if (dart.library.html) 'web_reload_web.dart';

enum UpdateType { none, soft, force }

class VersionCheckResult {
  final UpdateType type;
  final String currentVersion;
  final String latestVersion;
  final String minRequiredVersion;
  final String? storeUrl;

  const VersionCheckResult({
    required this.type,
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    this.storeUrl,
  });
}

class AppVersionService {
  final FirebaseFirestore _firestore;

  AppVersionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the platform version criteria from Firestore doc `app_config/version`
  /// and compares against running app semver.
  Future<VersionCheckResult> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final doc = await _firestore.collection('app_config').doc('version').get();

      if (!doc.exists || doc.data() == null) {
        return VersionCheckResult(
          type: UpdateType.none,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          minRequiredVersion: currentVersion,
        );
      }

      final data = doc.data()!;
      Map<String, dynamic>? platformConfig;

      if (kIsWeb) {
        platformConfig = data['web'] as Map<String, dynamic>?;
      } else if (Platform.isAndroid) {
        platformConfig = data['android'] as Map<String, dynamic>?;
      } else if (Platform.isIOS) {
        platformConfig = data['ios'] as Map<String, dynamic>?;
      }

      if (platformConfig == null) {
        return VersionCheckResult(
          type: UpdateType.none,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          minRequiredVersion: currentVersion,
        );
      }

      final latestVersion = (platformConfig['latest_version'] as String?)?.trim() ?? currentVersion;
      final minVersion = (platformConfig['min_required_version'] as String?)?.trim() ?? '0.0.0';
      final storeUrl = (platformConfig['store_url'] as String?)?.trim();

      // Check if current version is below hard floor (Force Update)
      if (isVersionLower(currentVersion, minVersion)) {
        return VersionCheckResult(
          type: UpdateType.force,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          minRequiredVersion: minVersion,
          storeUrl: storeUrl,
        );
      }

      // Check if current version is below latest release (Soft Update)
      if (isVersionLower(currentVersion, latestVersion)) {
        return VersionCheckResult(
          type: UpdateType.soft,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          minRequiredVersion: minVersion,
          storeUrl: storeUrl,
        );
      }

      return VersionCheckResult(
        type: UpdateType.none,
        currentVersion: currentVersion,
        latestVersion: currentVersion,
        minRequiredVersion: minVersion,
      );
    } catch (e) {
      debugPrint('[AppVersionService] Check failed: $e');
      return const VersionCheckResult(
        type: UpdateType.none,
        currentVersion: '',
        latestVersion: '',
        minRequiredVersion: '',
      );
    }
  }

  /// Triggers platform action (reloads webpage for web/PWA, opens app store for mobile)
  static Future<void> performUpdate(String? storeUrl) async {
    if (kIsWeb) {
      reloadWebPage();
    } else if (storeUrl != null && storeUrl.isNotEmpty) {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Compares semantic versions: returns true if [current] < [target].
  /// Supports versions like "1.0.0", "1.2", "2.0.1+4" (build metadata stripped).
  static bool isVersionLower(String current, String target) {
    if (current.isEmpty || target.isEmpty) return false;

    // Strip build numbers/metadata e.g. "1.0.0+1" -> "1.0.0"
    final cleanCurrent = current.split('+').first.trim();
    final cleanTarget = target.split('+').first.trim();

    List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> targetParts = cleanTarget.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (targetParts.length < 3) {
      targetParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (currentParts[i] < targetParts[i]) return true;
      if (currentParts[i] > targetParts[i]) return false;
    }
    return false;
  }
}
