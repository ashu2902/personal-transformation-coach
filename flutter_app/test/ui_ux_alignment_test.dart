import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AURA UI/UX Design Direction Alignment Tests', () {
    test('Canonical color tokens are strictly defined', () {
      expect(AuraColors.background, const Color(0xFF0B0C0D));
      expect(AuraColors.surface1, const Color(0xFF121416));
      expect(AuraColors.surface2, const Color(0xFF191C1F));
      expect(AuraColors.actionGreen, const Color(0xFF39E6A3));
      expect(AuraColors.auraPurple, const Color(0xFFA779FF));
      expect(AuraColors.textPrimary, const Color(0xFFF5F6F4));
      expect(AuraColors.textSecondary, const Color(0xFF929797));
    });

    test('All CoachSoul palettes provide distinct primary and secondary colors', () {
      final supporter = AuraColors.getSoulPalette(CoachSoul.supporter);
      final pro = AuraColors.getSoulPalette(CoachSoul.pro);
      final teacher = AuraColors.getSoulPalette(CoachSoul.teacher);

      expect(supporter.primary, const Color(0xFFA779FF));
      expect(pro.primary, const Color(0xFF00E5FF));
      expect(teacher.primary, const Color(0xFF00BFA5));

      expect(supporter.scaffoldBackground, const Color(0xFF0B0C0D));
      expect(pro.scaffoldBackground, const Color(0xFF0B0C0D));
      expect(teacher.scaffoldBackground, const Color(0xFF0B0C0D));
    });

    test('ThemeData generated from CoachSoul correctly embeds AuraThemeExtension', () {
      final theme = getAuraTheme(CoachSoul.supporter);
      final ext = theme.extension<AuraThemeExtension>();

      expect(ext, isNotNull);
      expect(ext!.soul, CoachSoul.supporter);
      expect(ext.primary, const Color(0xFFA779FF));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B0C0D));
    });
  });
}
