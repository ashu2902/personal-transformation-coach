import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/theme/theme.dart';
import 'package:aura_transformation_engine/widgets/common/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluid UI & Dynamic Layout System Tests', () {
    testWidgets('AuraCurves are properly defined with valid spring curves', (tester) async {
      expect(AuraCurves.fluidSpring, isA<Cubic>());
      expect(AuraCurves.fluidEaseOut, isA<Cubic>());
      expect(AuraCurves.fluidOrganic, isA<Cubic>());
    });

    testWidgets('AuraFluid clamps values correctly across screen ranges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final valMin = context.fluid(14, 24);
                expect(valMin, equals(14.0));
                expect(context.isMobile, isTrue);
                expect(context.isTablet, isFalse);
                expect(context.isDesktop, isFalse);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 900)),
            child: Builder(
              builder: (context) {
                final valMax = context.fluid(14, 24);
                expect(valMax, equals(24.0));
                expect(context.isDesktop, isTrue);
                expect(context.maxFluidContentWidth, equals(760.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('AuraCard renders fluidly and responds to tap/hover', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: getAuraTheme(CoachSoul.supporter),
          home: Scaffold(
            body: AuraCard(
              onTap: () => tapped = true,
              child: const Text('Fluid Card Test'),
            ),
          ),
        ),
      );

      expect(find.text('Fluid Card Test'), findsOneWidget);
      await tester.tap(find.text('Fluid Card Test'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AuraButton renders fluid tactile scale and handles press', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: getAuraTheme(CoachSoul.pro),
          home: Scaffold(
            body: AuraButton(
              text: 'Execute Session',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Execute Session'), findsOneWidget);
      await tester.tap(find.text('Execute Session'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });
}
