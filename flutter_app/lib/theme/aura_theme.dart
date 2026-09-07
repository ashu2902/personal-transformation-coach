import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import 'aura_colors.dart';
import 'aura_theme_extension.dart';

/// Produces a unified ThemeData configured for the given CoachSoul.
ThemeData getAuraTheme(CoachSoul soul) {
  final palette = AuraColors.getSoulPalette(soul);
  final baseTheme = ThemeData.dark();

  return baseTheme.copyWith(
    scaffoldBackgroundColor: palette.scaffoldBackground,
    cardColor: palette.surfaceCard,
    colorScheme: ColorScheme.dark(
      primary: palette.primary,
      secondary: palette.secondary,
      surface: palette.surfaceCard,
      error: AuraColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.scaffoldBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AuraColors.textPrimary),
      titleTextStyle: GoogleFonts.syne(
        color: AuraColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: palette.surfaceCard,
      selectedItemColor: palette.primary,
      unselectedItemColor: AuraColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      baseTheme.textTheme.copyWith(
        displayLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AuraColors.textPrimary),
        displayMedium: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AuraColors.textPrimary),
        displaySmall: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.01, color: AuraColors.textPrimary),
        headlineLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AuraColors.textPrimary),
        headlineMedium: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AuraColors.textPrimary),
        headlineSmall: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.01, color: AuraColors.textPrimary),
        titleLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.01, color: AuraColors.textPrimary),
        titleMedium: GoogleFonts.syne(fontWeight: FontWeight.w600, color: AuraColors.textPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(color: AuraColors.textPrimary, fontSize: 14),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AuraColors.textSecondary, fontSize: 12),
      ),
    ),
    extensions: [
      AuraThemeExtension.fromSoul(soul),
    ],
  );
}
