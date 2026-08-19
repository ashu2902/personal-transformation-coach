import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Strongly-typed event names following Mixpanel snake_case conventions
class AuraAnalyticsEvents {
  // Core Lifecycle & Value Moments
  static const String signUpCompleted = 'sign_up_completed';
  static const String prescriptionCompleted = 'prescription_completed'; // AURA Value Moment

  // Onboarding Funnel
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String soulSelected = 'soul_selected';
  static const String planCalibrated = 'plan_calibrated';

  // Core Daily Activity & Actions
  static const String workoutStarted = 'workout_started';
  static const String exerciseSetLogged = 'exercise_set_logged';
  static const String recoveryLogged = 'recovery_logged';
  static const String hydrationLogged = 'hydration_logged';

  // Conversational AI & Multi-modal
  static const String chatMessageSent = 'chat_message_sent';
  static const String portionCorrected = 'portion_corrected';
  static const String imageScanned = 'image_scanned';

  // Persona & Profile
  static const String soulSwitched = 'soul_switched';
  static const String goalUpdated = 'goal_updated';
  static const String screenViewed = 'screen_viewed';
}

/// Abstract Analytics Service interface for clean separation of concerns
abstract class IAnalyticsService {
  Future<void> init();
  Future<void> logEvent(String name, {Map<String, dynamic>? properties});
  Future<void> setUserId(String? userId);
  Future<void> setUserProperties(Map<String, dynamic> properties);
  Future<void> registerSuperProperties(Map<String, dynamic> properties);
  Future<void> logScreenView(String screenName);
  Future<void> reset();
}

/// Mixpanel Analytics Service implementation using mixpanel_flutter
class MixpanelAnalyticsService implements IAnalyticsService {
  static const String _projectToken = '0285e0bfe983b61f50aa622f570535af';

  Mixpanel? _mixpanel;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    int attempts = 0;
    while (attempts < 3 && !_isInitialized) {
      attempts++;
      try {
        _mixpanel = await Mixpanel.init(
          _projectToken,
          trackAutomaticEvents: true,
        );
        _isInitialized = true;

        // Register baseline super properties
        await registerSuperProperties({
          'platform': kIsWeb ? 'flutter_pwa' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
          'app_version': '1.0.0',
          'sdk': 'mixpanel_flutter',
        });

        debugPrint('[MIXPANEL] Initialized successfully with project token.');
        return;
      } catch (e) {
        if (attempts >= 3) {
          debugPrint('[MIXPANEL] Initialization error: $e');
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? properties}) async {
    try {
      if (_mixpanel != null) {
        // Sanitize properties: remove nulls or empty strings
        final sanitized = <String, dynamic>{};
        if (properties != null) {
          for (final entry in properties.entries) {
            if (entry.value != null && entry.value != '') {
              sanitized[entry.key] = entry.value;
            }
          }
        }
        _mixpanel!.track(name, properties: sanitized);
        debugPrint('[MIXPANEL] Event tracked: $name -> $sanitized');
      } else {
        debugPrint('[MIXPANEL] (Uninitialized) Event: $name -> $properties');
      }
    } catch (e) {
      debugPrint('[MIXPANEL] logEvent error for $name: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      if (_mixpanel != null) {
        if (userId != null && userId.trim().isNotEmpty) {
          _mixpanel!.identify(userId.trim());
          debugPrint('[MIXPANEL] User identified: $userId');
        } else {
          _mixpanel!.reset();
          debugPrint('[MIXPANEL] User reset');
        }
      }
    } catch (e) {
      debugPrint('[MIXPANEL] setUserId error: $e');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      if (_mixpanel != null) {
        for (final entry in properties.entries) {
          if (entry.value != null) {
            _mixpanel!.getPeople().set(entry.key, entry.value);
          }
        }
        debugPrint('[MIXPANEL] User profile updated: $properties');
      }
    } catch (e) {
      debugPrint('[MIXPANEL] setUserProperties error: $e');
    }
  }

  @override
  Future<void> registerSuperProperties(Map<String, dynamic> properties) async {
    try {
      if (_mixpanel != null) {
        final cleanProps = <String, dynamic>{};
        for (final entry in properties.entries) {
          if (entry.value != null) {
            cleanProps[entry.key] = entry.value;
          }
        }
        _mixpanel!.registerSuperProperties(cleanProps);
        debugPrint('[MIXPANEL] Super properties registered: $cleanProps');
      }
    } catch (e) {
      debugPrint('[MIXPANEL] registerSuperProperties error: $e');
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await logEvent(AuraAnalyticsEvents.screenViewed, properties: {
      'screen_name': screenName,
    });
  }

  @override
  Future<void> reset() async {
    try {
      if (_mixpanel != null) {
        _mixpanel!.reset();
        debugPrint('[MIXPANEL] Reset distinct_id on logout.');
      }
    } catch (e) {
      debugPrint('[MIXPANEL] reset error: $e');
    }
  }
}
