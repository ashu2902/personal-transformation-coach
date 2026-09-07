import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_transformation_engine/models/user_profile.dart';
import 'package:aura_transformation_engine/screens/onboarding_screen.dart';
import 'package:aura_transformation_engine/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PWA Back Gesture & PopScope Tests', () {
    testWidgets('PopScope prevents root exit when canPop is false', (tester) async {
      bool didInvokeCustomHandler = false;
      await tester.pumpWidget(
        MaterialApp(
          home: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              didInvokeCustomHandler = true;
            },
            child: const Scaffold(
              body: Text('Home Screen PWA'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Home Screen PWA'), findsOneWidget);

      final dynamic popScopeWidget = tester.widget(find.byWidgetPredicate((w) => w is PopScope));
      expect(popScopeWidget.canPop, isFalse);

      // Simulate system / gesture back
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pump();

      expect(didInvokeCustomHandler, isTrue);
    });

    testWidgets('OnboardingScreen contains PopScope to handle step rollback safely', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: getAuraTheme(CoachSoul.supporter),
            home: const OnboardingScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsAtLeastNWidgets(1));
    });
  });
}
