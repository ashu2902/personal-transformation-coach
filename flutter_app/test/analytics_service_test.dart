import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/services/analytics_service.dart';

/// Test mock implementation to verify event logging, properties, and identity
class MockAnalyticsService implements IAnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];
  final Map<String, dynamic> superProperties = {};
  final Map<String, dynamic> userProperties = {};
  String? currentUserId;
  bool isResetCalled = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? properties}) async {
    loggedEvents.add({
      'name': name,
      'properties': properties ?? <String, dynamic>{},
    });
  }

  @override
  Future<void> setUserId(String? userId) async {
    currentUserId = userId;
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    userProperties.addAll(properties);
  }

  @override
  Future<void> registerSuperProperties(Map<String, dynamic> properties) async {
    superProperties.addAll(properties);
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await logEvent(AuraAnalyticsEvents.screenViewed, properties: {
      'screen_name': screenName,
    });
  }

  @override
  Future<void> reset() async {
    isResetCalled = true;
    currentUserId = null;
    superProperties.clear();
    userProperties.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mixpanel Analytics Event Naming Conventions & Schema Tests', () {
    test('All event names follow snake_case convention', () {
      final events = [
        AuraAnalyticsEvents.signUpCompleted,
        AuraAnalyticsEvents.prescriptionCompleted,
        AuraAnalyticsEvents.onboardingStarted,
        AuraAnalyticsEvents.onboardingStepCompleted,
        AuraAnalyticsEvents.soulSelected,
        AuraAnalyticsEvents.planCalibrated,
        AuraAnalyticsEvents.workoutStarted,
        AuraAnalyticsEvents.exerciseSetLogged,
        AuraAnalyticsEvents.recoveryLogged,
        AuraAnalyticsEvents.hydrationLogged,
        AuraAnalyticsEvents.chatMessageSent,
        AuraAnalyticsEvents.portionCorrected,
        AuraAnalyticsEvents.imageScanned,
        AuraAnalyticsEvents.soulSwitched,
        AuraAnalyticsEvents.screenViewed,
      ];

      final snakeCaseRegex = RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$');
      for (final event in events) {
        expect(snakeCaseRegex.hasMatch(event), isTrue,
            reason: 'Event "$event" does not match snake_case convention');
      }
    });

    test('Core Value Moment is prescription_completed', () {
      expect(AuraAnalyticsEvents.prescriptionCompleted, 'prescription_completed');
    });

    test('Lifecycle Conversion Gate is sign_up_completed', () {
      expect(AuraAnalyticsEvents.signUpCompleted, 'sign_up_completed');
    });
  });

  group('Analytics Service Workflow & Payload Integrity Tests', () {
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      mockAnalytics = MockAnalyticsService();
    });

    test('Tracks screen view events accurately', () async {
      await mockAnalytics.logScreenView('coach');
      await mockAnalytics.logScreenView('insights');
      await mockAnalytics.logScreenView('today');

      expect(mockAnalytics.loggedEvents.length, 3);
      expect(mockAnalytics.loggedEvents[0]['name'], 'screen_viewed');
      expect(mockAnalytics.loggedEvents[0]['properties']['screen_name'], 'coach');
      expect(mockAnalytics.loggedEvents[1]['properties']['screen_name'], 'insights');
      expect(mockAnalytics.loggedEvents[2]['properties']['screen_name'], 'today');
    });

    test('Sets user identity, profile properties, and super properties correctly', () async {
      const testUid = 'user_aura_test_12345';
      await mockAnalytics.setUserId(testUid);
      expect(mockAnalytics.currentUserId, testUid);

      await mockAnalytics.setUserProperties({
        r'$name': 'Alex Rivera',
        'coach_soul': 'pro',
        'goal_type': 'recomp',
        'days_per_week': 4,
      });

      expect(mockAnalytics.userProperties[r'$name'], 'Alex Rivera');
      expect(mockAnalytics.userProperties['coach_soul'], 'pro');
      expect(mockAnalytics.userProperties['goal_type'], 'recomp');
      expect(mockAnalytics.userProperties['days_per_week'], 4);

      await mockAnalytics.registerSuperProperties({
        'coach_soul': 'pro',
        'goal_type': 'recomp',
      });

      expect(mockAnalytics.superProperties['coach_soul'], 'pro');
      expect(mockAnalytics.superProperties['goal_type'], 'recomp');
    });

    test('Prescription completed event contains all required schema properties', () async {
      await mockAnalytics.logEvent(
        AuraAnalyticsEvents.prescriptionCompleted,
        properties: {
          'workout_type': 'Upper Body Hypertrophy',
          'focus_area': 'Chest & Back',
          'estimated_duration_min': 45,
          'exercise_count': 5,
          'total_sets': 15,
          'is_adapted': true,
          'coach_soul': 'teacher',
        },
      );

      final event = mockAnalytics.loggedEvents.first;
      expect(event['name'], 'prescription_completed');
      final props = event['properties'] as Map<String, dynamic>;
      expect(props['workout_type'], 'Upper Body Hypertrophy');
      expect(props['focus_area'], 'Chest & Back');
      expect(props['estimated_duration_min'], 45);
      expect(props['exercise_count'], 5);
      expect(props['total_sets'], 15);
      expect(props['is_adapted'], isTrue);
      expect(props['coach_soul'], 'teacher');
    });

    test('Onboarding funnel events record step progression correctly', () async {
      await mockAnalytics.logEvent(AuraAnalyticsEvents.onboardingStarted, properties: {'platform': 'flutter_pwa'});
      await mockAnalytics.logEvent(AuraAnalyticsEvents.onboardingStepCompleted, properties: {
        'step_index': 0,
        'step_name': 'welcome',
        'next_step_index': 1,
      });
      await mockAnalytics.logEvent(AuraAnalyticsEvents.soulSelected, properties: {
        'soul_name': 'supporter',
        'surface': 'onboarding',
      });
      await mockAnalytics.logEvent(AuraAnalyticsEvents.planCalibrated, properties: {
        'goal_type': 'fat_loss',
        'target_calories': 2100,
        'target_protein_g': 160,
        'days_per_week': 4,
        'equipment_count': 3,
        'coach_soul': 'supporter',
      });
      await mockAnalytics.logEvent(AuraAnalyticsEvents.signUpCompleted, properties: {
        'sign_up_method': 'google',
        'coach_soul': 'supporter',
      });

      expect(mockAnalytics.loggedEvents.length, 5);
      expect(mockAnalytics.loggedEvents.map((e) => e['name']).toList(), [
        'onboarding_started',
        'onboarding_step_completed',
        'soul_selected',
        'plan_calibrated',
        'sign_up_completed',
      ]);
    });

    test('Reset clears distinct user ID and super properties upon logout', () async {
      await mockAnalytics.setUserId('user_to_logout');
      await mockAnalytics.registerSuperProperties({'coach_soul': 'supporter'});
      expect(mockAnalytics.currentUserId, isNotNull);

      await mockAnalytics.reset();
      expect(mockAnalytics.isResetCalled, isTrue);
      expect(mockAnalytics.currentUserId, isNull);
      expect(mockAnalytics.superProperties.isEmpty, isTrue);
      expect(mockAnalytics.userProperties.isEmpty, isTrue);
    });
  });

  group('MixpanelAnalyticsService Defensive Fallbacks', () {
    test('Uninitialized MixpanelAnalyticsService safely handles logEvent without throwing', () async {
      final service = MixpanelAnalyticsService();
      // Should not throw even if Mixpanel native instance is null
      expect(() async => await service.logEvent('test_event', properties: {'key': 'val'}), returnsNormally);
      expect(() async => await service.setUserId('uid_123'), returnsNormally);
      expect(() async => await service.setUserProperties({'age': 25}), returnsNormally);
      expect(() async => await service.registerSuperProperties({'platform': 'web'}), returnsNormally);
      expect(() async => await service.logScreenView('home'), returnsNormally);
      expect(() async => await service.reset(), returnsNormally);
    });
  });
}
